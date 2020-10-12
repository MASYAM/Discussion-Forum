
import Foundation
import IGListKit
import Firebase

struct Question : Codable {

    var id : String = ""
    var sender : String = ""
    var senderID : String = ""
    var email : String = ""
    var timestamp : Int = 0
    var title : String = ""
    var description : String = ""
    var answerCount : Int = 0
    var section : String = ""
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
    
    init(snapshot: DataSnapshot) {
        if let value = snapshot.value as? [String: Any] {
            self.id = snapshot.key
            self.timestamp = value["timestamp"] as? Int ?? 0
            self.title = value["title"] as? String ?? ""
            self.description = value["description"] as? String ?? ""
            self.sender = value["sender"] as? String ?? ""
            self.senderID = value["senderID"] as? String ?? ""
            self.email = value["email"] as? String ?? ""
            self.answerCount = value["answerCount"] as? Int ?? 0
            self.section = value["section"] as? String ?? ""
        }
    }
    
    func hasValidData() -> Bool {
        return !title.isEmpty && !description.isEmpty
    }
}

//MARK:
extension Question : Paginable {
    var lastTimestamp: Int {
        get {
            return self.timestamp
        }
    }
}

//MARK:
extension Question: Diffable {
    var diffIdentifier: String {
        return self.id
    }
    static func ==(lhs: Question, rhs: Question) -> Bool {
        guard lhs.id == rhs.id else {
            return false
        }
        return true
    }
    
    func diffable() -> ListDiffable {
        return DiffableBox(value: self, identifier: self.diffIdentifier as NSObjectProtocol, equal: ==)
    }
}
