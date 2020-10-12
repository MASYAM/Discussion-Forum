
import Foundation
import UIKit
import IGListKit

protocol QuestionsSectionControllerDelegate {
    func questionSection(_ questionSection: QuestionsSectionController, didSelect question: Question)
}

//MARK:
final class QuestionsSectionController: ListSectionController {
    
    var question : Question?
    var delegate : QuestionsSectionControllerDelegate?
    var tappableDelegate : TappableDelegate?
    
    init(delegate: QuestionsSectionControllerDelegate,
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
        if let question = self.question {
            height = QuestionCollectionViewCell.height(for: question, width: width)
        }
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: "QuestionCollectionViewCell",
                                                          bundle: Bundle.main,
                                                          for: self, at: index) as! QuestionCollectionViewCell
        if let question = self.question {
            cell.configure(with: question)
            cell.delegate = tappableDelegate
        }
        return cell
    }
    
    override func didUpdate(to object: Any) {
        let boxed = object as! DiffableBox<Question>
        self.question = boxed.value
    }
    
    @objc func sectionShouldReloadContext() {
        self.collectionContext?.performBatch(animated: false, updates: { (batchContext) in
            batchContext.reload(self)
        })
    }
    
    override func didSelectItem(at index: Int) {
        guard question != nil else { return }
        delegate?.questionSection(self, didSelect: question!)
    }
}
