
import Foundation
import UIKit
import IGListKit

protocol AnswerViewControllerDelegate {
    func answerView(answerView: AnswerViewController, didUpdate question: Question)
}

class AnswerViewController : UIViewController, Instantiable, Alertable {
    
    static var nibIdentifier: String = "Answer"
    
    @IBOutlet private weak var answerTextField : QuestionTextField!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var overlayView: UIView!
    @IBOutlet private weak var questionTagView : UIView!
    @IBOutlet private weak var questionTagLabel : UILabel!
    
    var question : Question?
    var delegate : AnswerViewControllerDelegate?
    
    var dataSource : [Answer] = [Answer]()
    var paginationControl:Pagination = Pagination()
    
    var isRequestMoreData : Bool = false
    var isFirstDataRequest : Bool = true
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(),
                           viewController: self, workingRangeSize: 1)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.answers("viewDidLoad")
        self.setupViews()
        self.setupCollectionView()
        self.setupNotifications()
        self.setupGestures()
        self.getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log.answers("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log.answers("viewDidAppear")
    }
    
    fileprivate func setupViews() {
        answerTextField.delegate = self
        answerTextField.dropHardShadow()
        guard question != nil else { return }
        titleLabel.text = question?.title
        descriptionLabel.text = question?.description
        
        self.imageView.layer.cornerRadius = imageView.frame.size.width / 2
        self.imageView.layer.masksToBounds = true
        self.questionTagView.layer.cornerRadius = questionTagView.frame.height / 2
        self.questionTagLabel.text = question!.section.isEmpty ? Application.sharedInstance.defaultCategory : question!.section.uppercased()
        
        let imageCode : String = ImageConstants.imageURL(imageCode: question!.senderID)
        self.imageView.getProfileImage(imageCode)
    }
    
    fileprivate func setupCollectionView() {
        if #available(iOS 10.0, *) { collectionView.isPrefetchingEnabled = false }
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        adapter.dataSource = self
        adapter.collectionView = collectionView
        adapter.scrollViewDelegate = self
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(tapGesture)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SignInViewController.keyboardWillBeShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SignInViewController.keyboardWillBeHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sectionShouldReloadProfile),
                                               name: ApplicationEvents.userUpdateProfileData, object: nil)
    }
    
    fileprivate func getData() {
        guard question != nil else { return }
        if !self.isRequestMoreData {
            self.isRequestMoreData = true
            paginationControl.gettingMoreData()
            getAnswers(pageSize: paginationControl.pageSize,
                       lastTimestamp: paginationControl.lastTimestamp,
                       questionID: question!.id)
        }
    }
    
    fileprivate func refreshData() {
        dataSource.removeAll()
        paginationControl.reset()
        getData()
    }
    
    fileprivate func reloadData() {
        adapter.performUpdates(animated: true, completion: nil)
    }
    
    fileprivate func clearViews() {
        self.transitionToAlpha()
        self.view.endEditing(true)
        self.answerTextField.text = ""
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        guard question != nil else { return }
        if let comment = answerTextField.text, !comment.isEmpty {
            if let currentUser = Application.sharedInstance.currentUser {
                self.transitionToBlack()
                var answer = Answer(email: currentUser.email, sender: currentUser.firstName+" "+currentUser.lastName, comment: comment)
                let timestamp = Int(NSDate().timeIntervalSince1970)
                answer.timestamp = -timestamp
                answer.questionID = question!.id
                answer.senderID = currentUser.id
                answer.section = question!.section
                answer.receiverID = question!.senderID
                self.setAnswer(answer: answer)
            }
        }
        else {
            // showAlert
            self.clearViews()
        }
    }
    
    @objc func sectionShouldReloadProfile() {
        if let currentUser = Application.sharedInstance.currentUser {
            let imageCode : String = ImageConstants.imageURL(imageCode: currentUser.id)
            self.imageView.getProfileImage(imageCode)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigateBack(from: self, animated: true)
    }
    
    @objc func imageViewTapped() {
        guard question != nil else { return }
        showWaitingCircleAndBlockUserInteraction()
        navigateToUserProfile(userID: question!.email)
    }
}

extension AnswerViewController {
    func transitionToBlack() {
        UIView.animate(withDuration: 0.5, animations: {
            self.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }, completion: { completed in
            
        })
    }
    func transitionToAlpha() {
        UIView.animate(withDuration: 0.5, animations: {
            self.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        }, completion: { completed in
            
        })
    }
}

//MARK: Adaptar
extension AnswerViewController : ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var objects : [ListDiffable] = []
        if dataSource.count > 0 {
            for item in dataSource {
                objects.append(item.diffable())
            }
        }
        return objects
    }
    
    func listAdapter(_ listAdapter: ListAdapter,
                     sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is DiffableBox<Answer>:
            return AnswersSectionController(delegate: self, tappableDelegate: self)
        case is SpacerSection:
            return SpacerSectionController(spacer: object as! SpacerSection)
        default:
            break
        }
        return ListSectionController()
    }
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        if !isFirstDataRequest && !self.isRequestMoreData {
            let view = CustomEmptyView.initFromNib()
            view.backgroundMode = .comments
            return view
        }
        return nil
    }
}

//MARK:
extension AnswerViewController : AuthenticationHandler { }

//MARK: Cell events
extension AnswerViewController : TappableDelegate {
    func tappableCell<T>(cell: T, didSelectItemWith userID: String) {
        showWaitingCircleAndBlockUserInteraction()
        navigateToUserProfile(userID: userID)
    }
}

//MARK:
extension AnswerViewController : AnswersSectionControllerDelegate {
    func answerSection(_ answerSection: AnswersSectionController, didSelectItemAt index: Int) {}
}

//MARK:
extension AnswerViewController : AppNavigable {
    func navigate(to viewController: UIViewController, animated: Bool) {
        self.hideWaitingCircleAndEnableUserInteraction()
        self.navigationController?.pushViewController(viewController, animated: animated)
    }
    func navigateBack(from viewController : UIViewController, animated: Bool) {
        self.hideWaitingCircleAndEnableUserInteraction()
        self.navigationController?.popViewController(animated: animated)
    }
    func navigateHasError(message: String) {
        self.hideWaitingCircleAndEnableUserInteraction()
    }
}

//MARK: UITextFieldDelegate
extension AnswerViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}

//MARK: Answer
extension AnswerViewController : AnswerHandler {
    
    func answerWriteCompleted(answer: Answer) {
        self.isRequestMoreData = false
        self.isFirstDataRequest = false
        self.clearViews()
        refreshData()
        guard question != nil else { return }
        question!.answerCount = question!.answerCount+1
        delegate?.answerView(answerView: self, didUpdate: question!)
    }
    
    func answersHasArrived(answers: [Answer]) {
        self.isRequestMoreData = false
        self.isFirstDataRequest = false
        if paginationControl.pageNumber == 0 {
            dataSource.removeAll()
        }
        paginationControl.process(data: answers)
        
        for answer in answers {
            if !dataSource.contains(where: {($0.timestamp == answer.timestamp)}){
                dataSource.append(answer)
            }
        }
        
        reloadData()
    }
    
    func answerServiceHadAnError(query: AnswerQueries, error: String) {
        self.isRequestMoreData = false
        self.isFirstDataRequest = false
        self.clearViews()
        self.reloadData()
        print(error)
    }
}

//MARK: - UIScrollViewDelegate
extension AnswerViewController : UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if !paginationControl.isRequestingMoreData && distance < 120 {
            DispatchQueue.global(qos: .default).async {
                DispatchQueue.main.async {
                    if self.paginationControl.shouldTryToGetMoreData {
                        self.getData()
                    }
                }
            }
        }
    }
}

//MARK: Keyboard
extension AnswerViewController {
    
    // puede ocasionar problemas con la sugerencia de password (aumenta el tamaño del teclado)
    @objc func keyboardWillBeShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardFrame.height
        }
        
    }
    @objc func keyboardWillBeHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += keyboardFrame.height
        }
    }
}
