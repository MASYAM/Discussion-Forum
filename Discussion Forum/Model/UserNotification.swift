
import Foundation
import Firebase
import FirebaseDatabase
import IGListKit

//MARK:
struct UserNotification {
    
    var id : String = ""
    var email : String = ""
    var message : String = ""
    var title : String = ""
    var status : String = ""
    var senderID : String = ""
    var questionID : String = ""
    var section : String = ""
    
    init(snapshot: DataSnapshot) {
        if let value = snapshot.value as? [String: Any] {
            self.id = snapshot.key
            self.email = value["email"] as? String ?? ""
            self.message = value["message"] as? String ?? ""
            self.title = value["title"] as? String ?? ""
            self.status = value["status"] as? String ?? ""
            self.senderID = value["senderID"] as? String ?? ""
            self.questionID = value["questionID"] as? String ?? ""
            self.section = value["section"] as? String ?? ""
        }
    }
}

//MARK:
extension UserNotification: Diffable {
    var diffIdentifier: String {
        return self.id
    }
    static func ==(lhs: UserNotification, rhs: UserNotification) -> Bool {
        guard lhs.id == rhs.id else {
            return false
        }
        return true
    }
    
    func diffable() -> ListDiffable {
        return DiffableBox(value: self, identifier: self.diffIdentifier as NSObjectProtocol, equal: ==)
    }
}
