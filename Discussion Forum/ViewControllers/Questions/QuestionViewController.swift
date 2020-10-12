
import Foundation
import UITextView_Placeholder
import UIKit

//MARK:
protocol QuestionViewControllerDelegate {
    func questionView(_ questionView: QuestionViewController, didSubmit question: Question)
    func questionView(_ questionView: QuestionViewController, didCancel completed: Bool)
}

//MARK:
class QuestionViewController : UIViewController, Instantiable {
    
    static var nibIdentifier: String = "Questions"
    
    @IBOutlet private weak var titleTextField : UITextView!
    @IBOutlet private weak var segmentedControl: SJFluidSegmentedControl!
    @IBOutlet private weak var descriptionTextField : UITextView!
    @IBOutlet private weak var containerView : UIView!
    @IBOutlet private weak var sendButton : UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    
    var delegate : QuestionViewControllerDelegate?
    var section : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupGestures()
        self.setupSegmentedControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segmentedControl.currentSegment = section
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func setupViews() {
        self.view.backgroundColor = .clear
        self.containerView.layer.cornerRadius = 10
        self.sendButton.layer.cornerRadius = 5
        
        self.titleTextField.delegate = self
        self.descriptionTextField.delegate = self
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 18
        paragraphStyle.maximumLineHeight = 18
        
        let cardTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hex:"#7c8089"),
                                   NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 18),
                                   NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        titleTextField.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        titleTextField.textContainer.lineFragmentPadding = 0
        
        titleTextField.typingAttributes[NSAttributedString.Key.foregroundColor] = UIColor.black // UIColor(hex:"#0071FE")
        titleTextField.typingAttributes[NSAttributedString.Key.font] = UIFont(name: "Montserrat-Regular", size: 18)
        titleTextField.typingAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        
        titleTextField.attributedPlaceholder = NSAttributedString(string: Constants.ask.rawValue,
                                                                  attributes: cardTitleAttributes as [NSAttributedString.Key : Any])
        
        let cardDescriptionAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hex:"#7c8089"),
                                         NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 15)]
        
        descriptionTextField.attributedPlaceholder = NSAttributedString(string: Constants.give.rawValue,
                                                                        attributes: cardDescriptionAttributes as [NSAttributedString.Key : Any])
        
        descriptionTextField.typingAttributes[NSAttributedString.Key.foregroundColor] = UIColor(hex:"##8089B0")
        descriptionTextField.typingAttributes[NSAttributedString.Key.font] = UIFont(name: "Montserrat-Regular", size: 15)
        
        descriptionTextField.textContainerInset = UIEdgeInsets.zero
        descriptionTextField.textContainer.lineFragmentPadding = 0
        
        self.imageView.layer.cornerRadius = imageView.frame.size.width / 2
        self.imageView.layer.masksToBounds = true
        
        if let currentUser = Application.sharedInstance.currentUser {
            let imageCode : String = ImageConstants.imageURL(imageCode: currentUser.id)
            self.imageView.getProfileImage(imageCode)
        }
    }
    
    private func setupSegmentedControl() {
        segmentedControl.dataSource = self
        segmentedControl.delegate = self
        segmentedControl.shapeStyle = .roundedRect
        segmentedControl.shadowsEnabled = false
        if let font = UIFont(name: "Montserrat-Regular", size: 13) {
            segmentedControl.textFont = font
        }
    }
    
    @objc func backgroundViewTapped() {
        if titleTextField.isFirstResponder || descriptionTextField.isFirstResponder {
            self.view.endEditing(true)
        }
        else {
            self.delegate?.questionView(self, didCancel: true)
            self.navigateBack(from: self, animated: true)
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        if let title = titleTextField.text, !title.isEmpty,
            let description = descriptionTextField.text, !description.isEmpty {
            if let currentUser = Application.sharedInstance.currentUser {
                var question = Question(title: title, description: description)
                let timestamp = Int(NSDate().timeIntervalSince1970)
                question.sender = currentUser.firstName + " " + currentUser.lastName
                question.email = currentUser.email
                question.timestamp = -timestamp
                question.senderID = currentUser.id
                question.section = Application.sharedInstance.defaultCategory.uppercased()
                if let currentCategories = Application.sharedInstance.preferences?.sections {
                    question.section = currentCategories[segmentedControl.currentSegment].uppercased()
                }
                self.setQuestion(question: question)
            }
        }
        else {
            // showAlert
        }
    }
}

extension QuestionViewController : AppNavigable {
    func navigateBack(from viewController : UIViewController, animated: Bool) {
        self.dismiss(animated: animated, completion: nil)
    }
}

struct QuestionViewControllerConstants {
    static let maxCharacters : Int = 140
}

//MARK: TextView
extension QuestionViewController : UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        if text.count >= QuestionViewControllerConstants.maxCharacters {
            return false
        }
        return true
    }
}

//MARK
extension QuestionViewController : QuestionHandler {
    func questionWriteCompleted(question: Question) {
        self.delegate?.questionView(self, didSubmit: question)
        self.navigateBack(from: self, animated: true)
    }
    func questionServiceHadAnError(query: QuestionQueries, error: String) {
        print("error")
    }
}

//MARK: SegmentedDataSource
extension QuestionViewController: SJFluidSegmentedControlDataSource {
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        if let currentCategories = Application.sharedInstance.preferences?.sections {
            return currentCategories.count
        }
        return 1
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          titleForSegmentAtIndex index: Int) -> String? {
        if let currentCategories = Application.sharedInstance.preferences?.sections,
            currentCategories.count > 0 {
            if index < currentCategories.count {
                return currentCategories[index].uppercased()
            }
        }
        return Application.sharedInstance.defaultCategory.uppercased()
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          gradientColorsForSelectedSegmentAtIndex index: Int) -> [UIColor] {
        let blueColor : UIColor = UIColor(red: 0 / 255.0, green: 128 / 255.0, blue: 255 / 255.0, alpha: 1.0)
        return [blueColor, blueColor]
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          gradientColorsForBounce bounce: SJFluidSegmentedControlBounce) -> [UIColor] {
        let gradientColor : UIColor = UIColor(red: 0 / 255.0, green: 128 / 255.0, blue: 255 / 255.0, alpha: 1.0)
        return [gradientColor, gradientColor]
    }
}

//MARK: SJFluidSegmentedControlDelegate
extension QuestionViewController: SJFluidSegmentedControlDelegate {
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, didScrollWithXOffset offset: CGFloat) {}
}
