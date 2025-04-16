//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Алексей Непряхин on 23.03.2025.
//

import Foundation
import SwiftKeychainWrapper

class OAuth2TokenStorage {
    var token: String? {
        get {
            //UserDefaults.standard.removeObject(forKey: "authorizationToken")
            //return UserDefaults.standard.string(forKey: "authorizationToken")
            return KeychainWrapper.standard.string(forKey: "authorizationToken")
        }
        
        set {
            //UserDefaults.standard.removeObject(forKey: "authorizationToken")
            //UserDefaults.standard.set(newValue, forKey: "authorizationToken")
            guard let token = newValue else { return }
            KeychainWrapper.standard.set(token, forKey: "authorizationToken")
        }
    }
}
