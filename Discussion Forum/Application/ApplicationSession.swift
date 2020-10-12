
import Foundation
import UIKit
import Crashlytics
import GoogleSignIn
import FirebaseAuth
import Firebase

struct InitializationError {
    public enum type : String {
        case userNotFound = "USER_NOT_FOUND"
        case authFailed = "AUTH_FAILED"
        case wrongUser = "USER_NOT_EXIST"
        case wrongPassword = "WRONG_PASS"
    }
}

//MARK: Initialization
class ApplicationSession: SessionHandler {
    
    static var sharedInstance = ApplicationSession()
    public var isAppInitialized = false

    func setup() {
        self.refreshObserver()
        self.addUserStateObserver()
    }
    
    func removeAppData() {
        self.removeSession()
        GIDSignIn.sharedInstance().signOut()
        Application.sharedInstance.currentUser = nil
    }
    
    func addUserStateObserver() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let _ = user {
            } else {
                self.removeAppData()
                self.tokenExpiredAndShouldLogout()
            }
        }
    }
    
    func refreshObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification(_:)),
                                               name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification(_:)),
                                               name: ApplicationEvents.tokenRefreshed, object: nil)
    }
    
    //MARK: Firebase Token Refresh
    @objc func tokenRefreshNotification(_ notification: Notification) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                self.removeAppData()
                self.tokenExpiredAndShouldLogout()
                log.debug("error while refreshing token " + error.localizedDescription)
            } else if let result = result {
                if !result.token.isEmpty {
                    if let currentUser = Application.sharedInstance.currentUser {
                        let service = UserService()
                        service.setDeviceToken(token: result.token, user: currentUser, successBlock: { user in
                            self.setToken(result.token)
                        }, failBlock: { error in
                            log.debug("error while setting device token " + error)
                        })
                    }
                }
            }
        }
    }
}

//MARK: Protocol
protocol AuthenticationHandler: SessionHandler {
    func loginHasCompleted()
    func loginHasErrors(_ error: String)
    func loginShouldNavigate(to viewController:UIViewController, animated:Bool)
}

extension AuthenticationHandler where Self : UIViewController {
    func loginHasCompleted() {}
    func loginHasErrors(_ error: String) {}
    func loginShouldNavigate(to viewController:UIViewController, animated:Bool) {}
}

//MARK: Common
extension AuthenticationHandler where Self : UIViewController {
    
    //MARK:
    func loginWith(userData: Credential) {
        Auth.auth().signIn(withEmail: userData.email, password: userData.password, completion: { (user, error) in
            if error != nil {
                ApplicationSession.sharedInstance.removeAppData()
                self.loginHasErrors(error!.localizedDescription)
            }
            else {
                let service = UserService()
                service.getUserByEmail(email: userData.email, successBlock: { user in
                    if let uuid = Auth.auth().currentUser?.uid {
                        Application.sharedInstance.currentUser = user
                        self.setUser(user)
                        self.setToken(uuid)
                        self.loginHasCompleted()
                    }
                    else {
                        ApplicationSession.sharedInstance.removeAppData()
                        self.loginHasErrors(InitializationError.type.wrongUser.rawValue)
                    }
                }, failBlock: {error in
                    ApplicationSession.sharedInstance.removeAppData()
                    self.loginHasErrors(InitializationError.type.wrongUser.rawValue)
                })
            }
        })
    }
    
    //MARK:
    func loginWith(crendential: AuthCredential) {
        Auth.auth().signInAndRetrieveData(with: crendential, completion: {(user, error) in
            if error != nil {
                ApplicationSession.sharedInstance.removeAppData()
                self.loginHasErrors(error!.localizedDescription)
            }
            else {
                if let email = user?.user.email {
                    let service = UserService()
                    service.getUserByEmail(email: email, successBlock: { user in
                        if let uuid = Auth.auth().currentUser?.uid {
                            Application.sharedInstance.currentUser = user
                            self.setUser(user)
                            self.setToken(uuid)
                            self.loginHasCompleted()
                        }
                        else {
                            ApplicationSession.sharedInstance.removeAppData()
                            self.loginHasErrors(InitializationError.type.wrongUser.rawValue)
                        }
                    }, failBlock: {error in
                        ApplicationSession.sharedInstance.removeAppData()
                        self.loginHasErrors(InitializationError.type.wrongUser.rawValue)
                    })
                }
                else {
                    ApplicationSession.sharedInstance.removeAppData()
                    self.loginHasErrors(InitializationError.type.wrongUser.rawValue)
                }
            }
        })
    }
    
    //MARK:
    func registerWith(userData:Credential) {
        Auth.auth().createUser(withEmail: userData.email, password: userData.password, completion: {user, error in
            if error != nil {
                ApplicationSession.sharedInstance.removeAppData()
                self.loginHasErrors(error!.localizedDescription)
            }
            else {
                let service = UserService()
                service.createUser(with: userData, successBlock: { user in
                    self.loginWith(userData: userData)
                    
                }, failBlock: { error in
                    ApplicationSession.sharedInstance.removeAppData()
                    self.loginHasErrors(InitializationError.type.wrongUser.rawValue)
                })
            }
        })
    }
    
    func forgotPassword(email: String, completionBlock: @escaping (_ message: String)->()) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
            OperationQueue.main.addOperation {
                if error != nil {
                    completionBlock("Wrong email")
                    
                } else {
                    completionBlock("Check your email and follow the instructions")
                }
            }})
    }
}

//MARK: ViewController
extension AuthenticationHandler where Self : UIViewController {
    
    func getNextViewController() {
        if let user = getUser() {
            if !user.email.isEmpty {
                let service = UserService()
                service.getUserByEmail(email: user.email, successBlock: { user in
                    
                    if user.token.isEmpty { self.postUserIsLoggedAndShouldRefreshToken() }
                    Application.sharedInstance.currentUser = user
                    
                    let preferenceServices = PreferencesService()
                    preferenceServices.getPreferences(successBlock: { preferences in
                        
                        Application.sharedInstance.preferences = preferences
                        
                        Crashlytics.sharedInstance().setUserName(user.firstName)
                        Crashlytics.sharedInstance().setUserEmail(user.email)
                        Crashlytics.sharedInstance().setObjectValue(user.id, forKey: "userID")
                        
                        self.setUser(user)
                        self.setPreferences(preferences)
                        self.navigateToApp()
                        
                    }, failBlock: { error in
                        if self.isAuthenticated {
                            self.navigateToApp()
                        }
                        else {
                            ApplicationSession.sharedInstance.removeAppData()
                            self.loginHasErrors(error)
                            self.navigateToSignIn()
                        }
                    })
                    
                }, failBlock: { error in
                    if self.isAuthenticated {
                        self.navigateToApp()
                    }
                    else {
                        ApplicationSession.sharedInstance.removeAppData()
                        self.loginHasErrors(error)
                        self.navigateToSignIn()
                    }
                })
            }
            else {
                self.navigateToSignIn()
            }
        }
        else {
            self.navigateToSignIn()
        }
    }
    
    func navigateToApp() {
        self.loginShouldNavigate(to: QuestionsViewController.initFromStoryboard() as QuestionsViewController, animated: true)
    }
    
    func navigateToSignIn() {
        self.loginShouldNavigate(to: SignInViewController.initFromStoryboard() as SignInViewController,animated: false)
    }
}

//MARK: 
extension AuthenticationHandler where Self : UIViewController {
    
    func logoutAction() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance().signOut()
        } catch _ as NSError {
            
        } catch {
            
        }
    }
    
    func logoutAndCloseApp(message: String = "") {
        let alert = UIAlertController(title: "Discussion Forum",
                                      message: "Are you sure want to log out?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Log out",
                                      style: .default,
                                      handler: { action in
                                        self.logoutAction()
                                        ApplicationSession.sharedInstance.removeAppData()
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        appDelegate.resetWindow()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension AuthenticationHandler {
    func postUserIsLoggedAndShouldRefreshToken() {
        NotificationCenter.default.post(name: ApplicationEvents.tokenRefreshed, object: nil, userInfo: nil)
    }
}
