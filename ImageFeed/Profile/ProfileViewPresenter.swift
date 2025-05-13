//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 13.05.2025.
//

import Foundation

enum ProfileItems {
    case name
    case loginName
    case bio
}

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func getProfileDetails(for item: ProfileItems) -> String?
    func getAvatarURL() -> URL?
    func logout()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    private var profileService = ProfileService.shared
    private var profileImageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    func getProfileDetails(for item: ProfileItems) -> String? {
        guard let profile = profileService.profile else {
            print("[ProfileViewPresenter]: No profile details found.")
            return nil
        }
        
        switch item {
        case .name:
            return profile.name
        case .loginName:
            return profile.loginName
        case .bio:
            return profile.bio
        }
    }
    
    func getAvatarURL() -> URL? {
        guard let profileImage = profileImageService.avatarURL else { return nil }
        
        guard let profileImageURL = URL(string: profileImage) else { return nil }
        
        return profileImageURL
    }
    
    func logout() {
        profileLogoutService.logout()
    }
}
