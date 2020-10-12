
import Foundation
import IGListKit
import UIKit

//MARK:
class SpacerSection {
    var id:String = "IGListKitSpacer"
    var size: CGSize = CGSize.zero
    var color: UIColor = .clear
    
    init() {}
    init(id:String, size:CGSize, color: UIColor = .clear) {
        self.id = id
        self.size = size
        self.color = color
    }
}

extension SpacerSection: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        
        guard let object = object as? SpacerSection else {
            return false
        }
        
        if object.id == self.id {
            return true
        }
        return false
    }
    
    static func ==(lhs: SpacerSection, rhs: SpacerSection) -> Bool {
        guard lhs.id == rhs.id else {
            return false
        }
        return true
    }
}

//MARK:
final class SpacerSectionController: ListSectionController {
    
    var spacer:SpacerSection?
    
    convenience init(spacer:SpacerSection) {
        self.init()
        self.spacer = spacer
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        if let spacer = self.spacer {
            var width:CGFloat = 0
            if spacer.size.width != 0 {
                width = spacer.size.width
            } else {
                width = collectionContext!.containerSize.width
            }
            let height:CGFloat = spacer.size.height
            return CGSize(width: width, height: height)
        }
        return CGSize.zero
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: "SpacerCollectionViewCell",
                                                          bundle: Bundle.main,
                                                          for: self, at: index) as! SpacerCollectionViewCell
        if self.spacer != nil {
            cell.backgroundColor = spacer!.color
        }
        return cell
    }
    
    override func didUpdate(to object: Any) {}
    
    override func didSelectItem(at index: Int) {}
    
}
