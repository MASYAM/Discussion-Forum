
import Foundation
import UIKit

//MARK:
protocol Collapsable {
    
    var barHeight : CGFloat { get }
    var minimunBarHeight : CGFloat { get }

    func view<T>(_ view: T, shouldUpdateConstraint value: CGFloat)
    func view<T>(_ view: T, shouldUpdateAlpha value: CGFloat)
}

extension Collapsable where Self : UIViewController {
    
    func collapse(with scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        if contentOffset < barHeight && (barHeight - contentOffset) != minimunBarHeight {
            self.view(self, shouldUpdateAlpha: (100 - (barHeight * contentOffset / 100)) * 0.01)
            self.view(self, shouldUpdateConstraint: barHeight - contentOffset >= minimunBarHeight ? barHeight - contentOffset : minimunBarHeight)
        }
    }
}
