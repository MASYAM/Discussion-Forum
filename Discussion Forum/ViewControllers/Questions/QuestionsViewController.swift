
import Foundation
import UIKit
import IGListKit
import Photos

class QuestionsViewController : UIViewController, Instantiable, Alertable {

    static var nibIdentifier: String = "Questions"
    
    @IBOutlet private weak var answerTextField : QuestionTextField!
    @IBOutlet private weak var segmentedControl: SJFluidSegmentedControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var topViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var overlayView: UIView!
    
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
        log.questions("viewDidLoad")
        self.setupSegmentedControl()
        self.setupViews()
        self.setupCollectionView()
        self.setupGestures()
        self.setupNotifications()
        self.getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log.questions("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segmentedControl(segmentedControl, didScrollWithXOffset: 0)
        segmentedControl.currentSegment = 0
        log.questions("viewDidAppear")
    }
    
    fileprivate func setupViews() {
        self.answerTextField.delegate = self
        self.imageView.layer.cornerRadius = imageView.frame.size.width / 2
        self.imageView.layer.masksToBounds = true
        if let currentUser = Application.sharedInstance.currentUser {
            let imageCode : String = ImageConstants.imageURL(imageCode: currentUser.id)
            self.imageView.getProfileImage(imageCode)
        }
    }
    
    fileprivate func setupCollectionView() {
        if #available(iOS 10.0, *) { collectionView.isPrefetchingEnabled = false }
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        adapter.dataSource = self
        adapter.collectionView = collectionView
        adapter.scrollViewDelegate = self
    }
    
    private func setupSegmentedControl() {
        segmentedControl.dataSource = self
        segmentedControl.delegate = self
        segmentedControl.shapeStyle = .liquid
        segmentedControl.shadowsEnabled = false
        if let font = UIFont(name: "Montserrat-Regular", size: 13) {
            segmentedControl.textFont = font
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sectionShouldReloadProfile),
                                               name: ApplicationEvents.userUpdateProfileData, object: nil)
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func getData() {
        if !self.isRequestMoreData {
            self.isRequestMoreData = true
            paginationControl.gettingMoreData()
            if let currentCategories = Application.sharedInstance.preferences?.sections {
                getQuestions(filter: currentCategories[segmentedControl.currentSegment],
                             pageSize: paginationControl.pageSize,
                             lastTimestamp: paginationControl.lastTimestamp)
            }
            else {
                getQuestions(filter: Application.sharedInstance.defaultCategory,
                             pageSize: paginationControl.pageSize,
                             lastTimestamp: paginationControl.lastTimestamp)
            }
        }
    }
    
    fileprivate func refreshData() {
        dataSource.removeAll()
        paginationControl.reset()
        getData()
    }
    
    @objc func sectionShouldReloadProfile() {
        if let currentUser = Application.sharedInstance.currentUser {
            let imageCode : String = ImageConstants.imageURL(imageCode: currentUser.id)
            self.imageView.getProfileImage(imageCode)
        }
    }
    
    fileprivate func reloadData() {
        adapter.performUpdates(animated: true, completion: nil)
    }
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        logoutAndCloseApp()
    }
    
    @IBAction func questionButtonTapped(_ sender: UIButton) {
        transitionToBlack()
        navigateToAskQuestion(section: segmentedControl.currentSegment)
    }
    
    @IBAction func notificationButtonTapped(_ sender: UIButton) {
        navigateToNotifications()
    }
    
    @objc func imageViewTapped() {
        if let currentUser = Application.sharedInstance.currentUser {
            showWaitingCircleAndBlockUserInteraction()
            navigateToUserProfile(userID: currentUser.email)
        }
    }
}

extension QuestionsViewController {
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

//MARK: 
extension QuestionsViewController : AnswerViewControllerDelegate {
    func answerView(answerView: AnswerViewController, didUpdate question: Question) {
        if let index = dataSource.index(where: {$0.id == question.id}) {
            dataSource[index] = question
            reloadData()
        }
    }
}

//MARK: Adaptar
extension QuestionsViewController : ListAdapterDataSource {
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        
        var objects : [ListDiffable] = []
        objects.append(SpacerSection(id: "Spacer", size:  CGSize(width: 0, height: 230)))
        
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
        return nil
    }
}

//MARK:
extension QuestionsViewController : AuthenticationHandler { }

//MARK: Cell events
extension QuestionsViewController : TappableDelegate {
    func tappableCell<T>(cell: T, didSelectItemWith userID: String) {
        showWaitingCircleAndBlockUserInteraction()
        navigateToUserProfile(userID: userID)
    }
}

//MARK:
extension QuestionsViewController : QuestionViewControllerDelegate {
    func questionView(_ questionView: QuestionViewController, didSubmit question: Question) {
        transitionToAlpha()
        refreshData()
    }
    
    func questionView(_ questionView: QuestionViewController, didCancel completed: Bool) {
        transitionToAlpha()
    }
}

//MARK:
extension QuestionsViewController : QuestionsSectionControllerDelegate {
    func questionSection(_ questionSection: QuestionsSectionController, didSelect question: Question) {
        navigateToAnswer(question: question)
    }
}

//MARK:
extension QuestionsViewController : AppNavigable {
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
extension QuestionsViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}

//MARK: Questions
extension QuestionsViewController : QuestionHandler {

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
        self.isRequestMoreData = false
        self.isFirstDataRequest = false
        print(error)
    }
}

//MARK: Collapsable
extension QuestionsViewController : Collapsable  {
    var barHeight: CGFloat { return 100 }
    var minimunBarHeight: CGFloat { return 98 }
    
    func view<T>(_ view: T, shouldUpdateAlpha value: CGFloat) {
//        self.segmentedControl.alpha = value
    }
    func view<T>(_ view: T, shouldUpdateConstraint value: CGFloat) {
//        self.topViewConstraint.constant = value
    }
}

//MARK: - UIScrollViewDelegate
extension QuestionsViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collapse(with: scrollView)
    }

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

//MARK: SegmentedDataSource
extension QuestionsViewController: SJFluidSegmentedControlDataSource {
    
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        if let currentCategories = Application.sharedInstance.preferences?.sections {
            if currentCategories.count > 0 {
                return currentCategories.count
            }
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
        let blueColor : UIColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.2)
        return [blueColor, blueColor]
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          gradientColorsForBounce bounce: SJFluidSegmentedControlBounce) -> [UIColor] {
        let gradientColor : UIColor = UIColor(red: 0 / 255.0, green: 128 / 255.0, blue: 255 / 255.0, alpha: 1.0)
        return [gradientColor, gradientColor]
    }
}

//MARK: SJFluidSegmentedControlDelegate
extension QuestionsViewController: SJFluidSegmentedControlDelegate {
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          didChangeFromSegmentAtIndex fromIndex: Int,
                          toSegmentAtIndex toIndex:Int) {
        self.refreshData()
        self.reloadData()
    }
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, didScrollWithXOffset offset: CGFloat) {}
}

