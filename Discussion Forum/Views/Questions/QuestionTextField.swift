
import Foundation
import UIKit

struct QuestionTextFieldParamenters {
    static let leftMargin : CGFloat = 15
    static let cornerRadius : CGFloat = 5
}

class QuestionTextField : UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: QuestionTextFieldParamenters.leftMargin, bottom: 0, right: 5)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = QuestionTextFieldParamenters.cornerRadius
        self.dropSoftShadow()
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
}
