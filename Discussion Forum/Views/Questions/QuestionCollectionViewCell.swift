
import UIKit
import AlamofireImage

//MARK:
class QuestionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var containerView : UIView!
    @IBOutlet private weak var questionTagView : UIView!
    @IBOutlet private weak var titleLabel : UILabel!
    @IBOutlet private weak var descriptionLabel : UILabel!
    @IBOutlet private weak var imageView : UIImageView!
    @IBOutlet private weak var countLabel : UILabel!
    @IBOutlet private weak var categoryLabel : UILabel!
    @IBOutlet private weak var fullnameLabel : UILabel!
    
    var question : Question?
    var delegate : TappableDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 5
        questionTagView.layer.cornerRadius = questionTagView.frame.height / 2
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
extension QuestionCollectionViewCell {
    
    class func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    class func height(for question: Question, width: CGFloat) -> CGFloat {
        let fixedHeight : CGFloat = 115
        let font = UIFont(name: "Montserrat-Regular", size: 14)
        let height = QuestionCollectionViewCell.heightForView(text: question.description, font: font!, width: width)
        return height + fixedHeight
    }
    
    public func configure(with question:Question) {
        self.question = question
        self.fullnameLabel.text = question.sender
        self.setupGestures()
        self.titleLabel.text = question.title
        self.descriptionLabel.text = question.description
        self.countLabel.text = "\(question.answerCount)"
        self.categoryLabel.text = question.section.isEmpty ? Application.sharedInstance.defaultCategory : question.section.uppercased()
        let imageCode : String = ImageConstants.imageURL(imageCode: question.senderID)
        self.imageView.getProfileImage(imageCode)
    }
    
    @objc func imageViewTapped() {
        guard question != nil else { return }
        self.delegate?.tappableCell(cell: self, didSelectItemWith: question!.email)
    }
    
}
