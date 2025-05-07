//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 02.05.2025.
//

import Foundation
import WebKit
import SwiftKeychainWrapper

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    
    private init() { }
    
    func logout() {
        cleanCookies()
        cleanToken()
        cleanSavedValues()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanToken() {
        KeychainWrapper.standard.removeObject(forKey: "authorizationToken")
    }
    
    private func cleanSavedValues() {
        profileService.cleanProfile()
        profileImageService.cleanAvatarURL()
        imagesListService.cleanPhotos()
    }
}

