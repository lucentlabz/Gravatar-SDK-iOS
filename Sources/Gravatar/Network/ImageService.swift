import UIKit

public struct ImageService {
    private let remote: ServiceRemote
    let imageCache: GravatarImageCaching

    public init(urlSession: URLSessionProtocol = URLSession.shared, cache: GravatarImageCaching = GravatarImageCache()) {
        self.remote = ServiceRemote(urlSession: urlSession)
        self.imageCache = cache
    }

    public func retrieveImage(
        with email: String,
        options: GravatarImageDownloadOptions = GravatarImageDownloadOptions(),
        completionHandler: ImageDownloadCompletion? = nil
    ) {
        Task {
            do {
                let result = try await fetchImage(with: email, options: options)
                completionHandler?(Result.success(result))
            } catch {
                completionHandler?(Result.failure(error))
            } 
        }
    }

    public func fetchImage(
        with email: String,
        options: GravatarImageDownloadOptions = GravatarImageDownloadOptions()
    ) async throws -> GravatarImageDownloadResult
    {
        let size = options.preferredSize ?? GravatarImageDownloadOptions.defaultSize
        let targetSize = await max(size.width, size.height) * UIScreen.main.scale

        guard let gravatarURL = GravatarURL.gravatarUrl(for: email, size: Int(targetSize), rating: options.gravatarRating) else {
            throw URLError(.badURL)
        }

        if !options.forceRefresh, let cachedImage = imageCache.getImage(forKey: gravatarURL.absoluteString) {
            return GravatarImageDownloadResult(image: cachedImage, sourceURL: gravatarURL)
        }

        return try await fetchImage(from: gravatarURL)
    }

    private func fetchImage(from url: URL, imageProcressor: ImageProcessing = ImageProcessor()) async throws -> GravatarImageDownloadResult {
        let request = URLRequest.imageRequest(url: url)
        let (data, response) = try await remote.fetchData(with: request)

        guard 
            let responseUrl = response.url,
            let image = imageProcressor.process(data: data)
        else {
            throw URLError(.badServerResponse)
        }

        imageCache.setImage(image, forKey: url.absoluteString)
        return GravatarImageDownloadResult(image: image, sourceURL: responseUrl)
    }

    @discardableResult
    public func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String) async throws -> URLResponse {
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest.imageUploadRequest(with: boundary)
        remote.authenticateRequest(&request, token: accountToken)
        let body = imageUploadBody(with: image.pngData()!, account: accountEmail, boundary: boundary)
        let response = try await remote.uploadData(with: request, data: body)
        return response
    }

    public func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String, completion: ((_ error: NSError?) -> Void)?) {
        Task {
            do {
                try await uploadImage(image, accountEmail: accountEmail, accountToken: accountToken)
                completion?(nil)
            } catch {
                completion?(error as NSError)
            }
        }
    }
}

private func imageUploadBody(with imageData: Data, account: String, boundary: String) -> Data {
    enum UploadParameters {
        static let contentType          = "application/octet-stream"
        static let filename             = "profile.png"
        static let imageKey             = "filedata"
        static let accountKey           = "account"
    }

    var body = Data()

    // Image Payload
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\(UploadParameters.imageKey); ")
    body.append("filename=\(UploadParameters.filename)\r\n")
    body.append("Content-Type: \(UploadParameters.contentType);\r\n\r\n")
    body.append(imageData)
    body.append("\r\n")

    // Account Payload
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"\(UploadParameters.accountKey)\"\r\n\r\n")
    body.append("\(account)\r\n")

    // EOF!
    body.append("--\(boundary)--\r\n")

    return body as Data
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: String.Encoding.utf8) {
            append(data)
        }
    }
}

private extension URLRequest {
    static func imageRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = false
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        return request
    }

    static func imageUploadRequest(with boundary: String) -> URLRequest {
        let url = URL(string: "https://api.gravatar.com/v1/upload-image")!
        var request = URLRequest(url: url)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        return request
    }
}
