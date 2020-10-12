
import Foundation
import TweeTextField
import UIKit
import GoogleSignIn
import Firebase

//MARK:
protocol LoginViewDelegate {
    func loginView(loginView: LoginView, didSignInWithGoogle user:GIDGoogleUser)
    func loginView(loginView: LoginView, didTappedForgotPasswordWith email:String)
}

//MARK:
class LoginView : UIView, NibLoadable {
    
    @IBOutlet private weak var emailField: TweeActiveTextField!
    @IBOutlet private weak var passwordField: TweeActiveTextField!
    @IBOutlet private weak var googleButton: GIDSignInButton!
    @IBOutlet private weak var forgotPassword: UILabel!
    
    var delegate : LoginViewDelegate?
    
    public var values : Credential {
        get {
            var registrable = Credential()
            registrable.firstName = "registeredUser"
            registrable.lastName = "registeredUser"
            registrable.email = emailField.text ?? ""
            registrable.password = passwordField.text ?? ""
            return registrable
        }
    }
    
    func setupGoogleSignIn() {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() { print("hasAuthInKeychain found!") }
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true;
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().scopes = ["email"]
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordTapped))
        self.forgotPassword.isUserInteractionEnabled = true
        self.forgotPassword.addGestureRecognizer(tapGesture)
    }
    
    func configure() {
        emailField.text = ""
        emailField.delegate = self
        passwordField.text = ""
        passwordField.delegate = self
        googleButton.dropSoftShadow()
        emailField.autocorrectionType = .no
        passwordField.autocorrectionType = .no
        emailField.textContentType = .oneTimeCode
        passwordField.textContentType = .oneTimeCode
        self.setupGoogleSignIn()
        self.setupGestures()
    }
    
    @objc func forgotPasswordTapped() {
        guard let email = emailField.text else { return }
        delegate?.loginView(loginView: self, didTappedForgotPasswordWith: email)
    }
    
    @IBAction func googleButtonTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
}

//MARK: Google
extension LoginView : GIDSignInDelegate {
    
    @nonobjc public func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        print("GIDSignIn inWillDispatch")
    }
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        print("present viewController")
    }
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        print("dismiss viewController")
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
        print("didDisconnectWith")
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil { return }
        guard user.authentication != nil else { return }
        self.delegate?.loginView(loginView: self, didSignInWithGoogle: user)
    }
}

//MARK: Google UI
extension LoginView : GIDSignInUIDelegate {
    
}

//MARK: TextView
extension LoginView : UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
