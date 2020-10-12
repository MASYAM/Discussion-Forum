
import Foundation

struct ApplicationEvents {
    static let pushNotificationReceived = NSNotification.Name(rawValue: "pushNotificationReceived")
    static let userUpdateProfileData = NSNotification.Name(rawValue: "userUpdateProfileData")
    static let tokenRefreshed = NSNotification.Name(rawValue: "tokenRefreshed")
}

enum Constants : String {
    case website = "http://www.your_website.com"
    case ask = "Give a title of your question"
    case give = "Description"
}

class Application {
    
    static var sharedInstance = Application()
    
    var currentUser : User?
    
    var preferences : Preferences?
    
    var defaultCategory : String = "GENERAL"
    
}


struct FirebaseConstants {
    static let users : String = "users"
    static let questions : String = "questions"
    static let questionsBy : String = "questionsBy"
    static let answers : String = "answers"
    static let notifications : String = "notifications"
    static let preferences : String = "preferences"
}

struct ImageConstants {
    
    static let baseURL = "https://firebasestorage.googleapis.com/v0/b/discussion-forum-31aa0.appspot.com/o/"
    
    static let parameters = "?alt=media"
    
    static func imageURL(imageCode:String) -> String {
        return self.baseURL + imageCode + "_avatar.png" + self.parameters
    }
}

extension Application {
    
    var versionFull:String {
        let shortBundleVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let shortBundleName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return "\(shortBundleName) Version: \(shortBundleVersion) Build: \(bundleVersion)"
    }
    
    var versionAbout:String {
        let shortBundleVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let shortBundleName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return "\(shortBundleName) \(shortBundleVersion) Build: \(bundleVersion)"
    }
    
    var appIconName: String? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
            let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String:Any],
            let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last else { return nil }
        return lastIcon
    }
}

extension Application {
    var bundleName:String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    }
    var versionShort:String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    var language: String {
        return Locale.preferredLanguages.first!
    }
}
