
import UIKit

class NotificationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var containerView : UIView!
    @IBOutlet private weak var titleLabel : UILabel!
    @IBOutlet private weak var descriptionLabel : UILabel!
    @IBOutlet private weak var imageView : UIImageView!
    
    var notification : UserNotification?
    var delegate : TappableDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 5
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        self.imageView.layer.masksToBounds = true
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(tapGesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.af_cancelImageRequest()
        imageView.image = nil
    }
}

//MARK:
extension NotificationCollectionViewCell {
    
    class func height() -> CGFloat {
        return 90.0
    }
    
    public func configure(with notification: UserNotification) {
        self.notification = notification
        self.setupGestures()
        self.titleLabel.text = notification.title
        let imageCode : String = ImageConstants.imageURL(imageCode: notification.senderID)
        self.imageView.getProfileImage(imageCode)
    }
    
    @objc func imageViewTapped() {
        guard notification != nil else { return }
        self.delegate?.tappableCell(cell: self, didSelectItemWith: notification!.email)
    }
}
