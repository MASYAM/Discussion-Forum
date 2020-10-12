
import Foundation
import UIKit
import IGListKit

protocol NotificationSectionControllerDelegate {
    func notificationSection(_ notificationSection: NotificationSectionController, didTapped notification: UserNotification)
}

//MARK:
final class NotificationSectionController: ListSectionController {
    
    var notification : UserNotification?
    var delegate : NotificationSectionControllerDelegate?
    var tappableDelegate : TappableDelegate?
    
    init(delegate: NotificationSectionControllerDelegate,
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
        let height = NotificationCollectionViewCell.height()
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(withNibName: "NotificationCollectionViewCell",
                                                          bundle: Bundle.main,
                                                          for: self, at: index) as! NotificationCollectionViewCell
        if let notification = self.notification {
            cell.configure(with: notification)
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
        let boxed = object as! DiffableBox<UserNotification>
        self.notification = boxed.value
    }
    
    override func didSelectItem(at index: Int) {
        guard notification != nil else { return }
        delegate?.notificationSection(self, didTapped: notification!)
    }
    
}
