
import Foundation
import Firebase
import FirebaseDatabase
import CodableFirebase

//MARK:
enum NotificationServiceError : String {
    case emptySnapshot = "SNAPSHOT_NOT_FOUND"
    case emptyParameter = "INCORRECT_PARAMETER"
}

class NotificationService {
    func getNotifications(userID:String,
                          successBlock: @escaping (_ answers: [UserNotification])->(),
                          failBlock: @escaping (_ error: String)->()) {
        
        var retValue = [UserNotification]()
        let ref = Database.database().reference()
        ref.child(FirebaseConstants.notifications)
            .queryOrdered(byChild: "receiverID")
            .queryEqual(toValue: userID)
            .queryLimited(toLast: UInt(10))
            .observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        for (i, _) in snapshot.enumerated() {
                            // Reversed response
                            retValue.append(UserNotification(snapshot: snapshot[(snapshot.count - 1) - i]))
                        }
                        successBlock(retValue)
                    }
                } else { failBlock(NotificationServiceError.emptySnapshot.rawValue) }
                
            })
    }
    
    func setNotificationSeen(notificationID: String,
                             successBlock: @escaping (_ completed: Bool)->(),
                             failBlock: @escaping (_ error: String)->()) {
        let ref = Database.database().reference()
        let questionsCount = ref.child(FirebaseConstants.notifications)
            .child("\(notificationID)").child("status")
        questionsCount.setValue("SEEN")
        successBlock(true)
    }
}
