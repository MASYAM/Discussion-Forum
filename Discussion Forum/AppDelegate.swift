
import UIKit
import Fabric
import Crashlytics
import Firebase
import GoogleSignIn
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            Messaging.messaging().delegate = self
            Messaging.messaging().shouldEstablishDirectChannel = true
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        registerCustomLogger()
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}

}

extension AppDelegate {
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
}

//MARK: Log
extension AppDelegate {
    func registerCustomLogger(){
        log.setup(level: .none)
    }
}

//MARK: Notifications
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}
}

//MARK: Messaging
extension AppDelegate : MessagingDelegate, SessionHandler {
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        NotificationCenter.default.post(name: ApplicationEvents.tokenRefreshed, object: nil, userInfo: nil)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        log.notifications("Received data message: \(remoteMessage.appData)")
    }
    
}

//MARK: Handle notifications
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.notifications(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        log.notifications("didReceiveRemoteNotification")
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        let dict = notification.request.content.userInfo["aps"] as! NSDictionary
        var messageBody:String?
        var messageTitle:String = "Alert"
        
        if let alertDict = dict["alert"] as? Dictionary<String, String> {
            messageBody = alertDict["body"]!
            if alertDict["title"] != nil {
                messageTitle  = alertDict["title"]! }
        } else {
            messageBody = dict["alert"] as? String
        }
        
        log.notifications("Message body is \(messageBody!) ")
        log.notifications("Message messageTitle is \(messageTitle)")
        log.notifications("Handle push from foreground \(notification.request.content.userInfo)")
        
        completionHandler([.alert,.sound, .badge])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        log.notifications("Message \(response.notification.request.content.userInfo)")
        completionHandler()
    }
    
}

//MARK: Logout
extension AppDelegate {
    func resetWindow() {
        if window == nil { window = UIWindow(frame: UIScreen.main.bounds) }
        let viewController = SignInViewController.initFromStoryboard() as SignInViewController
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.isHidden = true
        navigationController.isNavigationBarHidden = true
        UIView.transition(with: window!, duration: 1.0,
                          options: UIView.AnimationOptions.transitionFlipFromRight,
                          animations: { self.window?.rootViewController = navigationController }, completion: nil)
        window?.makeKeyAndVisible()
    }
}
