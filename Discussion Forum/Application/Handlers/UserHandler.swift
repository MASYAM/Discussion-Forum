
import Foundation
import UIKit

//MARK: Functions
enum UserQueries {
    case setUser
    case getUser
}

//MARK:
protocol UserHandler {
    
    //MARK:
    func getUser(userID: String)
    func setUser(credential: Credential)
    
    //MARK:
    func userHasArrived(user: User)
    func userWriteCompleted(user: User)
    func userServiceHadAnError(query: UserQueries, error: String)
}

//MARK:
extension UserHandler {
    
    //MARK:
    func userHasArrived(user: User) {}
    func userWriteCompleted(user: User) {}
    func userServiceHadAnError(query: UserQueries, error: String) {}
}

//MARK:
extension UserHandler {
    
    func getUser(userID: String) {
        let service = UserService()
        service.getUserByEmail(email: userID, successBlock: {user in
             self.userHasArrived(user: user)
        }, failBlock: { message in
            self.userServiceHadAnError(query: .getUser, error: message)
        })
    }
}

extension UserHandler {
    
    func setUser(credential: Credential) {
        let service = UserService()
        service.createUser(with: credential, successBlock: { user in
            self.userWriteCompleted(user: user)
        }, failBlock: { message in
            self.userServiceHadAnError(query: .setUser, error: message)
        })
    }
}

