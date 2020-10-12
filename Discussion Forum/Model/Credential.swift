
import Foundation

struct Credential {
    
    var firstName : String = ""
    var lastName : String = ""
    var email : String = ""
    var password : String = ""
    var token : String = ""
    
    func hasValidData() -> Bool {
        if firstName.isEmpty || lastName.isEmpty
            || email.isEmpty || password.isEmpty {
            return false
        }
        return true
    }
    
}
