
import Foundation
import UIKit

//MARK: Storyboard Instance
protocol Instantiable {
    static var nibIdentifier: String { get }
}

extension Instantiable {
    static func initFromStoryboard<T>() -> T where T : UIViewController, T : Instantiable {
        let storyboard = UIStoryboard(name: Self.nibIdentifier, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! T
        return controller
    }
}
