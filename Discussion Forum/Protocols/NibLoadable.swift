
import Foundation
import UIKit

protocol NibLoadable: class {}

extension NibLoadable where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
    static func initFromNib() -> Self {
        return Bundle.main.loadNibNamed(self.nibName, owner: self, options: nil)?.first as! Self
    }
}
