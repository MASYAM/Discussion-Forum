
import Foundation
import UIKit

//MARK: Functions
enum NotificationQueries {
    case getNotifications
}

//MARK:
protocol NotificationHandler {
    
    //MARK:
    func getNotifications(userID: String)
    func setNotificationSeen(notificationID: String)
    
    //MARK:
    func notificationHasUpdated()
    func notificationsHasArrived(notifications: [UserNotification])
    func notificationServiceHadAnError(query: NotificationQueries, error: String)
}

//MARK:
extension NotificationHandler {
    
    //MARK:
    func notificationHasUpdated() {}
    func notificationsHasArrived(notifications: [UserNotification]) {}
    func notificationServiceHadAnError(query: NotificationQueries, error: String) {}
}

//MARK:
extension NotificationHandler {
    
    func getNotifications(userID: String) {
        let service = NotificationService()
        service.getNotifications(userID: userID, successBlock: { notifications in
            self.notificationsHasArrived(notifications: notifications)
        }, failBlock: { message in
            self.notificationServiceHadAnError(query: .getNotifications, error: message)
        })
    }
    
    func setNotificationSeen(notificationID: String) {
        let service = NotificationService()
        service.setNotificationSeen(notificationID: notificationID, successBlock: { notifications in
            self.notificationHasUpdated()
        }, failBlock: { message in
            self.notificationServiceHadAnError(query: .getNotifications, error: message)
        })
    }
}
