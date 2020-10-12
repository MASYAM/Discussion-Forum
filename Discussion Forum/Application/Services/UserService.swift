
import Foundation
import Firebase
import FirebaseDatabase

//MARK:
enum UserServiceError : String {
    case emptySnapshot = "SNAPSHOT_NOT_FOUND"
    case emptyParameter = "INCORRECT_PARAMETER"
}

//MARK:
class UserService {
    
    func getUserByEmail(email: String,
                        successBlock: @escaping (_ user: User)->(),
                        failBlock: @escaping (_ error: String)->()) {
        
        if !email.isEmpty {
            let ref = Database.database().reference()            
            ref.child(FirebaseConstants.users)
                .queryOrdered(byChild: "email")
                .queryEqual(toValue: email)
                .queryLimited(toLast: 1)
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot);
                    if snapshot.exists() {
                        if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                            if let snap = snapshot.first {
                                successBlock(User(snapshot: snap))
                            }
                        }
                    } else { failBlock(UserServiceError.emptySnapshot.rawValue) }
                })
        }
        else {
            failBlock(UserServiceError.emptyParameter.rawValue)
        }
    }
}

//MARK: Create
extension UserService {
    
    func createUser(with userData: Credential,
                    successBlock: @escaping (_ user: User)->(),
                    failBlock: @escaping (_ error: String)->()) {
        
        if userData.hasValidData() {
            let ref = Database.database().reference()
            let mData: NSDictionary = ["firstName" : userData.firstName,
                                       "lastName" : userData.lastName,
                                       "imageURL" : "",
                                       "token" : userData.token,
                                       "email" : userData.email]
            
            ref.child(FirebaseConstants.users).childByAutoId().setValue(mData)
            
            let user = User(credentials: userData)
            successBlock(user)
        }
        else {
            failBlock(UserServiceError.emptyParameter.rawValue)
        }
    }
    
    func setDeviceToken(token: String,
                        user: User,
                        successBlock: @escaping (_ user: User)->(),
                        failBlock: @escaping (_ error: String)->()) {
        
        if !user.id.isEmpty {
            let ref = Database.database().reference()
            ref.child(FirebaseConstants.users).child(user.id).child("token").setValue(token)
            var user = user
            user.token = token
            successBlock(user)
        }
        else {
            failBlock(UserServiceError.emptyParameter.rawValue)
        }
    }
}
