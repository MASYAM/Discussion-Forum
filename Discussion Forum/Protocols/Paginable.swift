
import Foundation
import UIKit

//MARK:
struct Pagination {
    
    var isFirstDataRequest:Bool = true
    var isRequestingMoreData:Bool = false
    var shouldTryToGetMoreData:Bool = true
    var pageSize:Int = 10
    var pageNumber:Int = 0
    var lastTimestamp:Int = -5552529482
    
    mutating func process(data:Array<Any>) {
        self.isFirstDataRequest = false
        self.isRequestingMoreData = false
        if let item = data.last as? Paginable {
            self.lastTimestamp = item.lastTimestamp
        }
        if data.count > 0 && data.count % self.pageSize == 0 {
            self.shouldTryToGetMoreData = true
            self.pageNumber += 1
        } else {
            self.shouldTryToGetMoreData = false
        }
    }
}

//MARK:
extension Pagination {
    mutating func gettingMoreData() {
        self.isRequestingMoreData = true
    }
    mutating func reset() {
        self.isFirstDataRequest = true
        self.isRequestingMoreData = false
        self.shouldTryToGetMoreData = true
        self.pageNumber = 0
        self.lastTimestamp = -5552529482
    }
}

//MARK:
protocol Paginable {
    var lastTimestamp : Int { get }
    func paginatorShouldUpdate(timestamp:Int)
}

extension Paginable {
    func paginatorShouldUpdate(timestamp:Int) {}
}
