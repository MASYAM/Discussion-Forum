
import Foundation
import UIKit

//MARK:
protocol TappableDelegate {
    func tappableCell<T>(cell: T, didSelectItemWith userID: String)
}
