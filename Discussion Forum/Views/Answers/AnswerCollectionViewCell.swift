
import UIKit

class AnswerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var containerView : UIView!
    @IBOutlet private weak var titleLabel : UILabel!
    @IBOutlet private weak var descriptionLabel : UILabel!
    @IBOutlet private weak var imageView : UIImageView!
    @IBOutlet private weak var dateLabel : UILabel!
    
    var answer : Answer?
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

//MARK: Section
extension AnswerCollectionViewCell {
    
    class func height(for question: Answer) -> CGFloat {
        return 150.0
    }
    
    public func configure(with answer:Answer) {
        self.answer = answer
        self.setupGestures()
        self.titleLabel.text = answer.sender
        self.descriptionLabel.text = answer.comment
        let imageCode : String = ImageConstants.imageURL(imageCode: answer.senderID)
        self.imageView.getProfileImage(imageCode)
        let timestamp = abs(answer.timestamp)
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        dateLabel.text = date.timeAgoFromToday()
    }
    
    @objc func imageViewTapped() {
        guard answer != nil else { return }
        self.delegate?.tappableCell(cell: self, didSelectItemWith: answer!.email)
    }
    
}
