
import Foundation
import UIKit
import IGListKit

class UserViewController : UIViewController, Instantiable, Alertable {
    
    static var nibIdentifier: String = "Users"
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var fullNameLabel : UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var answersCount: UILabel!
    @IBOutlet private weak var questionCount: UILabel!
    @IBOutlet private weak var photoButton : UIButton!
    
    var user : User?
    
    var dataSource : [Question] = [Question]()
    var paginationControl:Pagination = Pagination()
    
    var isRequestMoreData : Bool = false
    var isFirstDataRequest : Bool = true
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(),
                           viewController: self, workingRangeSize: 1)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.users("viewDidLoad")
        self.setupViews()
        self.setupCollectionView()
        self.setupGestures()
        self.getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getCountData()
        log.users("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log.users("viewDidAppear")
    }
    
    fileprivate func setupViews() {
        guard user != nil else { return }
        self.fullNameLabel.text = user!.fullName
        self.photoButton.isHidden = false
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        self.imageView.layer.masksToBounds = true
        if let currentUser = Application.sharedInstance.currentUser {
            if user?.email != currentUser.email { photoButton.isHidden = true }
            let imageCode : String = ImageConstants.imageURL(imageCode: user!.id)
            self.imageView.getProfileImage(imageCode)
        }
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func setupCollectionView() {
        if #available(iOS 10.0, *) { collectionView.isPrefetchingEnabled = false }
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        adapter.dataSource = self
        adapter.collectionView = collectionView
        adapter.scrollViewDelegate = self
    }
    
    fileprivate func getData() {
        guard user != nil else { return }
        if !self.isRequestMoreData {
            self.isRequestMoreData = true
            paginationControl.gettingMoreData()
            getQuestionsBy(email: user!.email,
                           pageSize: paginationControl.pageSize,
                           lastTimestamp: paginationControl.lastTimestamp)
        }
    }
    
    fileprivate func reloadProfile() {
        guard user != nil else { return }
        let imageCode : String = ImageConstants.imageURL(imageCode: user!.id)
        self.imageView.clearImageFromCache(imageCode: imageCode)
        self.broadcastProfileUpdated()
        getUser(userID: user!.email)
    }
    
    fileprivate func broadcastProfileUpdated() {
        NotificationCenter.default.post(name: ApplicationEvents.userUpdateProfileData, object: self)
    }
    
    fileprivate func getCountData() {
        guard user != nil else { return }
        getAnswersCount(userID: user!.email)
        getQuestionCount(userID: user!.email)
    }
    
    fileprivate func refreshData() {
        dataSource.removeAll()
        paginationControl.reset()
        getData()
    }
    
    fileprivate func reloadData() {
        adapter.performUpdates(animated: true, completion: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigateBack(from: self, animated: true)
    }
    
    @IBAction func photoButtonTapped(_ sender: UIButton) {
        cameraPressed()
    }
    
    @objc func imageViewTapped() {
        guard user != nil else { return }
        if let currentUser = Application.sharedInstance.currentUser {
            if currentUser.email != user!.email {
                showWaitingCircleAndBlockUserInteraction()
                navigateToUserProfile(userID: user!.email)
            }
        }
    }
}

//MARK:
extension UserViewController : AnswerViewControllerDelegate {
    func answerView(answerView: AnswerViewController, didUpdate question: Question) {
        if let index = dataSource.index(where: {$0.id == question.id}) {
            dataSource[index] = question
            reloadData()
        }
    }
}

//MARK: Adaptar
extension UserViewController : ListAdapterDataSource {
    
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
        case is DiffableBox<Question>:
            return QuestionsSectionController(delegate: self, tappableDelegate: self)
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
            return view
        }
        return nil
    }
}

//MARK:
extension UserViewController : AuthenticationHandler { }

//MARK:
extension UserViewController : QuestionViewControllerDelegate {
    func questionView(_ questionView: QuestionViewController, didSubmit question: Question) {
        refreshData()
    }
    
    func questionView(_ questionView: QuestionViewController, didCancel completed: Bool) {}
}

//MARK:
extension UserViewController : QuestionsSectionControllerDelegate {
    func questionSection(_ questionSection: QuestionsSectionController, didSelect question: Question) {
        navigateToAnswer(question: question)
    }
}

//MARK:
extension UserViewController : AppNavigable {
    func navigate(to viewController: UIViewController, animated: Bool) {
        self.hideWaitingCircleAndEnableUserInteraction()
        self.navigationController?.pushViewController(viewController, animated: animated)
    }
    func navigateBack(from viewController: UIViewController, animated: Bool) {
        self.hideWaitingCircleAndEnableUserInteraction()
        self.navigationController?.popViewController(animated: animated)
    }
    func navigateHasError(message: String) {
        self.hideWaitingCircleAndEnableUserInteraction()
    }
}

//MARK: Questions
extension UserViewController : QuestionHandler {
    
    func questionCountHasArrived(count: Int) {
        self.questionCount.text = "\(count)"
    }
    
    func questionsHasArrived(questions: [Question]) {
        self.isRequestMoreData = false
        self.isFirstDataRequest = false
        if paginationControl.pageNumber == 0 {
            dataSource.removeAll()
        }
        paginationControl.process(data: questions)
        
        for question in questions {
            if !dataSource.contains(where: {($0.timestamp == question.timestamp)}){
                dataSource.append(question)
            }
        }
        reloadData()
    }
    
    func questionServiceHadAnError(query: QuestionQueries, error: String) {
        log.debug("\(query) ERROR \(error)")
        self.isRequestMoreData = false
        self.isFirstDataRequest = false
    }
}

//MARK: Answers
extension UserViewController : AnswerHandler {
    func answerCountHasArrived(count: Int) {
        answersCount.text = "\(count)"
    }
}

//MARK: User
extension UserViewController : UserHandler {
    func userHasArrived(user: User) {
        if let user = self.user {
            if Application.sharedInstance.currentUser?.email == user.email {
                Application.sharedInstance.currentUser = user
                self.setUser(user)
            }
        }
        self.user = user
    }
}

//MARK: Cell events
extension UserViewController : TappableDelegate {
    func tappableCell<T>(cell: T, didSelectItemWith userID: String) {
        if let currentUser = Application.sharedInstance.currentUser {
            if currentUser.email != user!.email {
                showWaitingCircleAndBlockUserInteraction()
                navigateToUserProfile(userID: user!.email)
            }
        }
    }
}

//MARK: - UIScrollViewDelegate
extension UserViewController : UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if !paginationControl.isRequestingMoreData && distance < 120 {
            DispatchQueue.global(qos: .default).async {
                DispatchQueue.main.async {
                    if self.paginationControl.shouldTryToGetMoreData {
//                        self.getData()
                    }
                }
            }
        }
    }
}

//MARK: Avatar
extension UserViewController {
    func cameraPressed() {
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Choose a photo", preferredStyle: .actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        actionSheetController.addAction(cancelAction)
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Take a photo", style: .default) { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let myPickerController = UIImagePickerController()
                myPickerController.delegate = self
                myPickerController.sourceType = .camera
                self.present(myPickerController, animated: true, completion: nil)
            }
            else {
                let actionController: UIAlertController = UIAlertController(title: "Camera no disponible", message: "", preferredStyle: .alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel) { action -> Void in }
                actionController.addAction(cancelAction)
                self.present(actionController, animated: true, completion: nil)
            }
        }
        actionSheetController.addAction(takePictureAction)
        
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Choose from gallery", style: .default) { action -> Void in
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.allowsEditing = false
            myPickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }
        actionSheetController.addAction(choosePictureAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
}

struct ComposerConstants {
    static let imageMaxSize = CGSize(width: 128, height: 128)
    static let kImageUploadCompression:CGFloat = 0.7
}

//MARK: UIImagePickerControllerDelegate
extension UserViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imageFromPicker = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let newSize = UIImage.scaleRectAccordingToRect(fromRect: imageFromPicker.size, toRect: ComposerConstants.imageMaxSize)
        let image = UIImage.squareScaleImage(image: imageFromPicker, ToWidth: newSize.width, maxSize: ComposerConstants.imageMaxSize)
        let imageService = ImageService()
        if let user = user {
            self.showWaitingCircle()
            imageService.setImage(image: image, userID: user.id, successBlock: { url in
                self.imageView.image = image
                self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
                self.imageView.layer.masksToBounds = true
                self.reloadProfile()
                self.hideAlertMessage()
            }, failBlock: { error in
                self.hideAlertMessage()
                log.users("error uploading photo")
            })
        }
        self.dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        self.dismiss(animated: true, completion:{})
    }
}

