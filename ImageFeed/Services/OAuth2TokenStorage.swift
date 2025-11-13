import Foundation

final class OAuth2TokenStorage {
    
    private enum Keys: String {
        case token = "bearerToken"
    }
    
    private let userDefaults = UserDefaults.standard
    
    var token: String? {
        get {
            return userDefaults.string(forKey: Keys.token.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.token.rawValue)
        }
    }
    
    
}
