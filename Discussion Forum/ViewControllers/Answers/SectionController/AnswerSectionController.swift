
import Foundation
import UIKit
import IGListKit

protocol AnswersSectionControllerDelegate {
    func answerSection(_ answerSection: AnswersSectionController, didSelectItemAt index: Int)
}

//MARK:
final class AnswersSectionController: ListSectionController {
    
    var answer : Answer?
    var delegate : AnswersSectionControllerDelegate?
    var tappableDelegate : TappableDelegate?
    
    init(delegate: AnswersSectionControllerDelegate,
         tappableDelegate: TappableDelegate) {
        super.init()
        self.delegate = delegate
        self.setupNotifications()
        self.tappableDelegate = tappableDelegate
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sectionShouldReloadContext),
                                               name: ApplicationEvents.userUpdateProfileData, object: nil)
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext!.containerSize.width
        var height : CGFloat = 0
        if let answer = self.answer {
            height = AnswerCollectionViewCell.height(for: answer)
        }
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: "AnswerCollectionViewCell",
                                                          bundle: Bundle.main,
                                                          for: self, at: index) as! AnswerCollectionViewCell
        if let answer = self.answer {
            cell.configure(with: answer)
            cell.delegate = tappableDelegate
        }
        return cell
    }
    
    @objc func sectionShouldReloadContext() {
        self.collectionContext?.performBatch(animated: false, updates: { (batchContext) in
            batchContext.reload(self)
        })
    }
    
    override func didUpdate(to object: Any) {
        let boxed = object as! DiffableBox<Answer>
        self.answer = boxed.value
    }
    
    override func didSelectItem(at index: Int) {
        delegate?.answerSection(self, didSelectItemAt: index)
    }
}
