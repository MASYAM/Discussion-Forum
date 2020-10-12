
import Foundation
import UIKit
import TweeTextField

//MARK: 
class RegisterView : UIView, NibLoadable {
    
    @IBOutlet private weak var nameField: TweeActiveTextField!
    @IBOutlet private weak var surnameField: TweeActiveTextField!
    @IBOutlet private weak var emailField: TweeActiveTextField!
    @IBOutlet private weak var passwordField: TweeActiveTextField!
    
    public var values : Credential {
        get {
            var registrable = Credential()
            registrable.email = emailField.text ?? ""
            registrable.password = passwordField.text ?? ""
            registrable.firstName = nameField.text ?? ""
            registrable.lastName = surnameField.text ?? ""
            return registrable
        }
    }
    
    func configure() {
        emailField.delegate = self
        nameField.delegate = self
        surnameField.delegate = self
        passwordField.delegate = self
        nameField.autocorrectionType = .no
        surnameField.autocorrectionType = .no
        emailField.autocorrectionType = .no
        passwordField.autocorrectionType = .no
        nameField.textContentType = .oneTimeCode
        surnameField.textContentType = .oneTimeCode
        emailField.textContentType = .oneTimeCode
        passwordField.textContentType = .oneTimeCode
    }
    
}

//MARK: TextView
extension RegisterView : UITextFieldDelegate {
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
