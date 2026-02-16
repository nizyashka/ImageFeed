import Foundation
import SwiftKeychainWrapper

class OAuth2TokenStorage {
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: "authorizationToken")
        }
        
        set {
            guard let token = newValue else { return }
            
            KeychainWrapper.standard.set(token, forKey: "authorizationToken")
        }
    }
}
