import Foundation

/// The user's public payment information. This is only provided in authenticated API requests.
///
public struct ProfilePayments: Codable, Hashable, Sendable {
    /// A list of payment URLs the user has added to their profile.
    public private(set) var links: [Link]
    /// A list of crypto currencies the user accepts.
    public private(set) var cryptoWallets: [CryptoWalletAddress]

    @available(*, deprecated, message: "init will become internal on the next release")
    public init(links: [Link], cryptoWallets: [CryptoWalletAddress]) {
        self.links = links
        self.cryptoWallets = cryptoWallets
    }

    @available(*, deprecated, message: "CodingKeys will become internal on the next release.")
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case links
        case cryptoWallets = "crypto_wallets"
    }

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case links
        case cryptoWallets = "crypto_wallets"
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encode(links, forKey: .links)
        try container.encode(cryptoWallets, forKey: .cryptoWallets)
    }

    // Decodable protocol methods

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InternalCodingKeys.self)

        links = try container.decode([Link].self, forKey: .links)
        cryptoWallets = try container.decode([CryptoWalletAddress].self, forKey: .cryptoWallets)
    }
}
