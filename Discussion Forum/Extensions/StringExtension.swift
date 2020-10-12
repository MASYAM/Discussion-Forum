
import Foundation

extension String {
    
    //MARK: - Localized
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func isValidEmail() -> Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", regEx).evaluate(with: self)
    }
    
    func localized(arguments args: CVarArg...) -> String {
        return String(format: self.localized, arguments: args)
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    func timeAgo() -> String {
        guard !self.trim().isEmpty else {
            return ""
        }
        return timeAgoSinceDate(dateStringFormatter: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", numericDates: true)
    }
    
    func hashtagString() -> String {
        return "#" + self.replacingOccurrences(of: "#", with: "")
    }
    
    func contains(find: String) -> Bool {
        return self.range(of: find) != nil
    }
    
    func timeAgoSinceDate(dateStringFormatter: String, numericDates:Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateStringFormatter
        if let date = dateFormatter.date(from: self) {
            return date.timeAgoFromToday(numericDates: numericDates)
        }else{
            return ""
        }
    }
    
    var hashtags : [String]? {
        get{
            let hashtagDetector = try? NSRegularExpression(pattern: "#(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
            let results = hashtagDetector?.matches(in: self, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, self.utf16.count)).map { $0 }
            
            return results?.map({
                (self as NSString).substring(with: $0.range(at: 0))
            })
        }
    }
    
    var mentions: [String]? {
        get {
            let hashtagDetector = try? NSRegularExpression(pattern: "@(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
            let results = hashtagDetector?.matches(in: self, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, self.utf16.count)).map { $0 }
            
            return results?.map({
                (self as NSString).substring(with: $0.range(at: 0))
            })
        }
    }
}
