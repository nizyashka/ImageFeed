//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 23.03.2025.
//

import Foundation

class OAuth2TokenStorage {
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "authorizationToken")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "authorizationToken")
        }
    }
}
