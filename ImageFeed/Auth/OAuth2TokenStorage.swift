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
            //KeychainWrapper.standard.removeObject(forKey: "authorizationToken")
            return KeychainWrapper.standard.string(forKey: "authorizationToken")
        }
        
        set {
            guard let token = newValue else { return }
            //KeychainWrapper.standard.removeObject(forKey: "authorizationToken")
            KeychainWrapper.standard.set(token, forKey: "authorizationToken")
        }
    }
}
