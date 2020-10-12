
import Foundation
import CoreLocation
import UIKit

//MARK: Parameters
struct SessionParameters {
    static let user : String = "user"
    static let token : String = "token"
    static let preferences : String = "preferences"
}

//MARK:
protocol SessionHandler {
    func tokenExpiredAndShouldLogout()
}

//MARK: User
extension SessionHandler {
    
    func setUser(_ user: User) {
        do {
            let userData = try JSONEncoder().encode(user)
            UserDefaults.standard.set(userData, forKey:SessionParameters.user)
            UserDefaults.standard.synchronize()
        } catch { print(error) }
    }
    
    func getUser() -> User? {
        var retValue : User?
        do {
            if let userData = UserDefaults.standard.object(forKey: SessionParameters.user) as? Data {
                if let user = try? JSONDecoder().decode(User.self, from: userData) {
                    retValue = user
                }
            }
        }
        return retValue
    }
}

//MARK: User
extension SessionHandler {
    
    func setPreferences(_ preferences: Preferences) {
        do {
            let userData = try JSONEncoder().encode(preferences)
            UserDefaults.standard.set(userData, forKey:SessionParameters.preferences)
            UserDefaults.standard.synchronize()
        } catch { print(error) }
    }
    
    func getPreferences() -> Preferences? {
        var retValue : Preferences?
        do {
            if let preferencesData = UserDefaults.standard.object(forKey: SessionParameters.preferences) as? Data {
                if let preferences = try? JSONDecoder().decode(Preferences.self, from: preferencesData) {
                    retValue = preferences
                }
            }
        }
        return retValue
    }
    
}

//MARK: Token
extension SessionHandler {
    
    func setToken(_ token: String) {
        
        if !token.isEmpty {
            UserDefaults.standard.set(token, forKey: SessionParameters.token)
            UserDefaults.standard.synchronize()
        }
    }
    
    func getToken() -> String {
        
        if let tokenValue = UserDefaults.standard.object(forKey: SessionParameters.token) as? String {
            return tokenValue
        } else {
            return ""
        }
    }
}

//MARK: Session
extension SessionHandler {
    var isAuthenticated: Bool {
        get {
            var retValue : Bool = false
            if !getToken().isEmpty {
                if let _ = getUser() {
                    retValue = true
                }
            }
            return retValue
        }
    }
    
    func removeSession() {
        UserDefaults.standard.removeObject(forKey: SessionParameters.user)
        UserDefaults.standard.removeObject(forKey: SessionParameters.token)
        UserDefaults.standard.removeObject(forKey: SessionParameters.preferences)
    }
}

//MARK: Session
extension SessionHandler {
    func tokenExpiredAndShouldLogout() {
        
    }
}

extension UIViewController {
    @objc func tokenIsExpired() {}
}

extension SessionHandler where Self: UIViewController {
    func registerTokenExpiredAppEvent() {
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(tokenIsExpired),
//                                               name: ApplicationEvents.invalidTokenDetected, object: nil)
    }
}
