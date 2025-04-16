//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 27.03.2025.
//

import Foundation
import UIKit

final class SplashViewController: UIViewController {
    private var splashScreenImageView: UIImageView?
    
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "YP Black")
        addImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            let authViewController = AuthViewController()
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }
    
    private func switchToTabBarController() {
        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
    
    private func addImage() {
        let splashScreenImage = UIImage(named: "Vector")
        splashScreenImageView = UIImageView(image: splashScreenImage)
        guard let splashScreenImageView = splashScreenImageView else { return }
        splashScreenImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashScreenImageView)
        
        NSLayoutConstraint.activate([
            splashScreenImageView.widthAnchor.constraint(equalToConstant: 75),
            splashScreenImageView.heightAnchor.constraint(equalToConstant: 78),
            splashScreenImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashScreenImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = storage.token else { return }
        
        fetchProfile(token: token)
    }
    
    func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                guard let username = profile.username else { return }
                ProfileImageService.shared.fetchProfileImageURL(username: username) { result in
                    //Что тут вообще должно происходить???
                    switch result {
                    case .success(let profileImageURL):
                        print(profileImageURL)
                    case .failure(let error):
                        print("[SplashViewController]: NetworkOrDecodingError - \(error.localizedDescription)")
                    }
                }
                switchToTabBarController()
            case .failure:
                print("Unable to load profile")
                break
            }
        }
    }
}
