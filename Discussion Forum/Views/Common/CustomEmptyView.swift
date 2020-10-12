
import UIKit

enum CustomEmptyViewMode : Int {
    case comments
    case notifications
}

class CustomEmptyView: UIView, NibLoadable {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var backgroundMode : CustomEmptyViewMode = .notifications {
        didSet {
            if backgroundMode == .notifications {
                textLabel.textColor = .white
                subtitleLabel.textColor = .white
                textLabel.text = "---"
                subtitleLabel.text = "No results found"
            }
            else {
                textLabel.textColor = UIColor(hex: "#8089B0")
                subtitleLabel.textColor = UIColor(hex: "#8089B0")
                textLabel.text = "---"
                subtitleLabel.text = "No results found"
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    
}
