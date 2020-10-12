
import Foundation
import IGListKit
import Firebase

struct Answer {
    
    var id : String = ""
    var email : String = ""
    var sender : String = ""
    var timestamp : Int = 0
    var comment : String = ""
    var senderID : String = ""
    var questionID : String = ""
    var section : String = ""
    var receiverID : String = ""
    
    func hasValidData() -> Bool {
        return !email.isEmpty
    }
    
    init(snapshot: DataSnapshot) {
        if let value = snapshot.value as? [String: Any] {
            self.id = snapshot.key
            self.timestamp = value["timestamp"] as? Int ?? 0
            self.email = value["email"] as? String ?? ""
            self.comment = value["comment"] as? String ?? ""
            self.sender = value["sender"] as? String ?? ""
            self.senderID = value["senderID"] as? String ?? ""
            self.section = value["section"] as? String ?? ""
            self.receiverID = value["receiverID"] as? String ?? ""
        }
    }
    
    init(email: String, sender: String, comment: String) {
        self.email = email
        self.sender = sender
        self.comment = comment
    }
}

//MARK:
extension Answer: Diffable {
    var diffIdentifier: String {
        return id
    }
    
    static func ==(lhs: Answer, rhs: Answer) -> Bool {
        guard lhs.id == rhs.id else {
            return false
        }
        return true
    }
    
    func diffable() -> ListDiffable {
        return DiffableBox(value: self, identifier: self.diffIdentifier as NSObjectProtocol, equal: ==)
    }
}
