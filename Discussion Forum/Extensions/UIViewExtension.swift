
import Foundation
import UIKit

extension UIView {
    func dropSoftShadow() {
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.16
        self.layer.shadowRadius = 2
    }
    
    func dropHardShadow() {
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.24
        self.layer.shadowRadius = 4
    }
}
