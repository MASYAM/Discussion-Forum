
import Foundation

struct Timestamp {
    static let kBackendDateFormat = "MMM dd, yyyy hh:mm:ss a XXXXX" //"MMM dd, yyyy hh:mm:ss a"
    static let kImageNameDateFormat = "yyyyMMddHHmmss"
}

extension Date {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()
    
    static func shortString(fromDate date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    static func date(fromShortString string: String) -> Date? {
        return dateFormatter.date(from: string)
    }
    
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    func timeAgoFromToday(numericDates : Bool = false) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        
        let earliest = now.earlierDate(self)
        let latest = (earliest == now as Date) ? self : now as Date
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest)
        
        if (components.year! >= 2) {
            return "%d years ago".localized(arguments: components.year!)
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"//.localized
            } else {
                return "Last year"//.localized
            }
        } else if (components.month! >= 2) {
            return "%d months ago".localized(arguments:components.month!)
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"//.localized
            } else {
                return "Last month"//.localized
            }
        } else if (components.weekOfYear! >= 2) {
            return "Last two week"//.localized
        } else if (components.weekOfYear! >= 1){
            return "Last week"//.localized
        } else if (components.day! >= 2) {
            return "%d days ago".localized(arguments: components.day!)
        } else if (components.day! >= 1){
            if (numericDates){
                return "Yesterday"//.localized
            } else {
                return "Yesterday"//.localized
            }
        } else if (components.hour! >= 2) {
            return "%d hours ago".localized(arguments: components.hour!)
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"//.localized
            } else {
                return "An hour ago"//.localized
            }
        } else if (components.minute! >= 2) {
            return "%d minutes ago".localized(arguments: components.minute!)
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"//.localized
            } else {
                return "A minute ago"//.localized
            }
        } else if (components.second! >= 3) {
            return "%d seconds ago".localized(arguments: components.second!)
        } else {
            return "Just now"//.localized
        }
    }
    
    static func imageName() -> String {
        let dateFormatter = DateFormatter()
        let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPOSIXLocale
        dateFormatter.dateFormat = Timestamp.kImageNameDateFormat
        
        return dateFormatter.string(from: Date())
    }
}
