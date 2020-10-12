
import Foundation
import UIKit

let log = Logger.defaultInstance

public enum LogLevel: Int, CustomStringConvertible {
    case debug = 0, warn, error, severe, none
    public var description: String {
        switch self {
        case .debug: return "DEBUG"
        case .error: return "ERROR"
        case .warn: return "WARNING"
        case .severe: return "SEVERE"
        case .none: return "NONE"
        }
    }
}

public enum LogType: CustomStringConvertible {
    case lifecycle, notification, network, api, view, locale, custom, synchronizer
    
    public var description: String {
        switch self {
        case .lifecycle: return "LIFECYCLE"
        case .notification: return "NOTIFICATION"
        case .network: return "NETWORK"
        case .view: return "VIEW"
        case .locale: return "LOCALE"
        case .api: return "API"
        case .custom: return "CUSTOM"
        case .synchronizer: return "SYNCHRONIZER"
        }
    }
    
    public static var allValues: [LogType] {
        return [.lifecycle, .notification, .network, .api, .view, .locale, .custom]
    }
}

public enum LogTag: String {
    case auth, questions, answers, user, notifications, none
    
    public static var allValues: [LogTag] {
        return [.auth, .questions, .answers, .user, .notifications, .none]
    }
}

public struct Verbosity: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
       self.rawValue = rawValue
    }
    public static let date = Verbosity(rawValue: 1 << 0)
    public static let functionScope = Verbosity(rawValue: 1 << 1)
    public static let fileScope = Verbosity(rawValue: 1 << 2)
    public static let lineNumber = Verbosity(rawValue: 1 << 3)
    public static let tags = Verbosity(rawValue: 1 << 4)
    public static let level = Verbosity(rawValue: 1 << 5)

    public static let all: Verbosity = [.date, .functionScope, .fileScope, .lineNumber, .tags, .level]

}

public class Logger : NSObject {
    public static let defaultInstance = Logger()
    private var logLevel: LogLevel = LogLevel.debug
    private var logTypes: [LogType] = LogType.allValues
    private var logTags: [LogTag] = LogTag.allValues
    private var verbosity: Verbosity = .all
    
    private var dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        self.dateFormatter.locale = NSLocale.current
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
   
    // MARK: - Public API
    public func setup(level: LogLevel, tagFilters: [LogTag] = LogTag.allValues, typeFilters: [LogType] = LogType.allValues, verbose: Verbosity = .all){
        self.logTypes = typeFilters
        self.logLevel = level
        self.logTags = tagFilters
        self.verbosity = verbose
    }
    
    // MARK: Priority based logging
    public func debug(_ message: String, type: LogType = .custom, tag: LogTag = .none, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: type, tags: [tag], level: .debug, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    public func error(_ message: String, type: LogType = .custom, tag: LogTag = .none, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: type, tags: [tag], level: .error, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    public func warn(_ message: String, type: LogType = .custom, tag: LogTag = .none, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: type, tags: [tag], level: .warn, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    /// Base logging method
    public func log(_ message: String, type: LogType, tag: LogTag = .none, level: LogLevel, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: type, tags: [tag], level: level, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    // MARK: Type based logging
    public func view(_ message: String, tag: LogTag = .none, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: .view, tags: [tag], level: .debug, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    public func api(_ message: String, tag: LogTag = .none, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: .api, tags: [tag], level: .debug, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    public func network(_ message: String, tag: LogTag = .none, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: .network, tags: [tag], level: .debug, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    public func locale(_ message: String, tag: LogTag = .none, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: .locale, tags: [tag], level: .debug, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    public func push(_ message: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: .notification, tags: [], level: .debug, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    public func lifecycle(_ message: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: .lifecycle, tags: [], level: .debug, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    public func auth(_ message: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: .api, tags: [.auth], level: .debug, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    public func questions(_ message: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: .view, tags: [.questions], level: .debug, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    public func answers(_ message: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: .view, tags: [.answers], level: .debug, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    public func notifications(_ message: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: .network, tags: [.notifications], level: .debug, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    public func users(_ message: String, fileName: String = #file, lineNumber: Int = #line, functionName: String = #function ){
        self.log(message, type: .view, tags: [.user], level: .debug, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
    }
    
    // MARK: Private
    private func log(_ message: String, type: LogType, tags:[LogTag], level: LogLevel = .debug, fileName: String, lineNumber: Int, functionName: String){
        let isAllowedTag = Set(tags).isSubset(of: logTags) /* || tags.count == 0 || (tags.first ?? .none) == .none */
        let isAllowedType = logTypes.contains(type)
        let isAllowedLevel = level.rawValue >= self.logLevel.rawValue
        guard isAllowedType, isAllowedTag , isAllowedLevel else { return  }
        let prefix = linePrefix(level, tags: tags, verbose: verbosity, fileName: fileName, lineNumber: lineNumber, functionName: functionName)
        let logString = "\(prefix) \(type) > \(message)"
        print(logString)
    }
    
    private func linePrefix(_ level: LogLevel, tags: [LogTag], verbose: Verbosity, fileName: String, lineNumber: Int, functionName: String?) -> String {
        var result: String = ""
        let file = fileName.components(separatedBy: "/").last!.components(separatedBy:".").first!
        let functionName = functionName ?? ""
        let dateString = dateFormatter.string(from: Date())

        if verbose.contains(.date) {
           result += "\(dateString) "
        }
        
        if verbose.contains(.level) {
            result += "[\(level)] "
        }
        
        if !verbose.isDisjoint(with: [.fileScope, .functionScope, .lineNumber]) {
            
            result += "[ "
            if verbose.contains(.fileScope) {
                result += "\(file) "
            }
            
            if verbose.contains(.functionScope) {
                result += "\(functionName) "
            }
            
            if verbose.contains(.lineNumber) {
                result += "line: \(lineNumber) "
            }
            result += "]"
        }
        
        if verbose.contains(.tags) {
            let filteredTags = tags.filter({ $0 != .none }).map({ "\($0)".components(separatedBy: ".").last ?? "" })
            result += filteredTags.isEmpty ? "" : " \(filteredTags)"
        }
        return result
    }

}
