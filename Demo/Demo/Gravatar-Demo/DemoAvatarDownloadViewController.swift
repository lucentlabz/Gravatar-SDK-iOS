//
//  DemoAvatarDownloadViewController.swift
//  Gravatar-Demo
//
//  Created by Pinar Olguc on 24.01.2024.
//

import UIKit
import Gravatar

class DemoAvatarDownloadViewController: UIViewController {
    static let imageViewSize: CGSize = .init(width: 300, height: 300)
    
    private lazy var emailInputField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Gravatar email"
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private lazy var preferredAvatarLengthInputField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Preferred avatar length (optional)"
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private lazy var gravatarRatingInputField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Gravatar rating (optional). [0|1|2|3]"
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private lazy var igonreCacheSwitchWithLabel: SwitchWithLabel = {
        let view = SwitchWithLabel(labelText: "Ignore Cache")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var fetchAvatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Fetch Avatar", for: .normal)
        button.addTarget(self, action: #selector(fetchAvatarButtonHandler), for: .touchUpInside)
        return button
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: Self.imageViewSize.height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: Self.imageViewSize.width).isActive = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emailInputField, preferredAvatarLengthInputField, gravatarRatingInputField, igonreCacheSwitchWithLabel, fetchAvatarButton, avatarImageView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    private let imageRetriever = GravatarImageRetriever()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        view.backgroundColor = .white
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),
            view.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            view.rightAnchor.constraint(equalTo: stackView.rightAnchor)
        ])
    }
    
    private var preferredSize: CGSize? {
        if let preferredLenghtStr = preferredAvatarLengthInputField.text,
           !preferredLenghtStr.isEmpty,
           let preferredLength = Int(preferredLenghtStr) {
            return CGSize(width: preferredLength, height: preferredLength)
        }
        return Self.imageViewSize
    }
    
    private var preferredRating: GravatarRating? {
        if let ratingStr = gravatarRatingInputField.text,
           !ratingStr.isEmpty,
           let ratingNo = Int(ratingStr)
        {
            return GravatarRating(rawValue: ratingNo)
        }
        return nil
    }
    
    @objc private func fetchAvatarButtonHandler() {
        
        let options: GravatarImageDownloadOptions = .init(gravatarRating: preferredRating ?? .default, 
                                                          preferredSize: preferredSize,
                                                          forceRefresh: igonreCacheSwitchWithLabel.isOn)
        
        avatarImageView.image = nil // Setting to nil to make the effect of `forceRefresh more visible
        
        imageRetriever.retrieveImage(with: emailInputField.text ?? "",
                                      options: options) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let value):
                    self?.avatarImageView.image = value.image
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

