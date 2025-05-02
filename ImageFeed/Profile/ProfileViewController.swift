//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 03.03.2025.
//

import Foundation
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private var profileImageView: UIImageView?
    private var nameLabel: UILabel?
    private var loginLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var exitButton: UIButton?
    private var profileService = ProfileService.shared
    private var profileImageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "YP Black")
        addProfileImageView()
        addNameLabel()
        addLoginLabel()
        addDescriptionLabel()
        addExitButton()
        
        guard let authToken = oauth2TokenStorage.token else {
            print("No authorization token found.")
            return
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        
        updateProfileDetails()
        updateAvatar()
        //profileService.fetchProfile(authToken, completion: updateProfile)
    }
    
    func addProfileImageView() {
        let profileImage = UIImage(named: "profile_photo")
        profileImageView = UIImageView(image: profileImage)
        guard let profileImageView = profileImageView else { return }
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    func addNameLabel() {
        nameLabel = UILabel()
        guard let nameLabel = nameLabel else { return }
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.systemFont(ofSize: 23)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        guard let profileImageView = profileImageView else { return }
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    func addLoginLabel() {
        loginLabel = UILabel()
        guard let loginLabel = loginLabel else { return }
        loginLabel.text = "@ekaterina_nov"
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        loginLabel.textColor = UIColor(named: "YP Gray")
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)
        
        guard let nameLabel = nameLabel else { return }
        
        NSLayoutConstraint.activate([
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    func addDescriptionLabel() {
        descriptionLabel = UILabel()
        guard let descriptionLabel = descriptionLabel else { return }
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        guard let loginLabel = loginLabel else { return }
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    func addExitButton() {
        exitButton = UIButton(type: .custom)
        exitButton?.setImage(UIImage(resource: .exit), for: .normal)
        guard let exitButton = exitButton else { return }
        exitButton.tintColor = .red
        
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        guard let profileImageView = profileImageView else { return }
        
        NSLayoutConstraint.activate([
            exitButton.widthAnchor.constraint(equalToConstant: 24),
            exitButton.heightAnchor.constraint(equalToConstant: 24),
            exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 99),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            exitButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
    
    func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        
        guard let nameLabel = nameLabel else { return }
        nameLabel.text = profile.name
        
        guard let loginLabel = loginLabel else { return }
        loginLabel.text = profile.loginName
        
        guard let descriptionLabel = descriptionLabel else { return }
        descriptionLabel.text = profile.bio
    }
    
    private func updateAvatar() {
        //        guard
        //            let profileImageURL = ProfileImageService.shared.avatarURL,
        //            let url = URL(string: profileImageURL)
        //        else { return }
        // TODO [Sprint 11] Обновить аватар, используя Kingfisher
        guard let profileImage = profileImageService.avatarURL else { return }
        
        if let profileImageURL = URL(string: profileImage) {
            guard let profileImageView = profileImageView else { return }
            profileImageView.kf.setImage(with: profileImageURL,
                                         placeholder: UIImage(named: "placeholder"))
        }
    }
    
    @objc private func exitButtonTapped() {
        profileLogoutService.logout()
        switchToAuthViewController()
    }
    
    private func switchToAuthViewController() {
        let splashViewController = SplashViewController()
        splashViewController.modalPresentationStyle = .fullScreen
        self.present(splashViewController, animated: true)
    }
}
