
import Foundation
import UIKit
import IGListKit

class NotificationViewController : UIViewController, Instantiable, Alertable {
    
    static var nibIdentifier: String = "Notifications"
    
    @IBOutlet private weak var segmentedControl: SJFluidSegmentedControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var imageView: UIImageView!
    
    var dataSource : [UserNotification] = [UserNotification]()
    var paginationControl:Pagination = Pagination()
    
    var isRequestMoreData : Bool = false
    var isFirstDataRequest : Bool = true
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(),
                           viewController: self, workingRangeSize: 1)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.view("viewDidLoad")
        self.setupViews()
        self.setupCollectionView()
        self.setupNotifications()
        self.setupGestures()
        self.setupSegmentedControl()
        self.getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log.view("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segmentedControl(segmentedControl, didScrollWithXOffset: 0)
        segmentedControl.currentSegment = 0
        log.view("viewDidAppear")
    }
    
    fileprivate func setupViews() {
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
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sectionShouldReloadProfile),
                                               name: ApplicationEvents.userUpdateProfileData, object: nil)
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
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func getData() {
        if !self.isRequestMoreData {
            self.isRequestMoreData = true
            paginationControl.gettingMoreData()
            if let currentUser = Application.sharedInstance.currentUser {
                getNotifications(userID: currentUser.id)
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
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigateBack(from: self, animated: true)
    }
    
    @objc func imageViewTapped() {
        if let currentUser = Application.sharedInstance.currentUser {
            showWaitingCircleAndBlockUserInteraction()
            navigateToUserProfile(userID: currentUser.email)
        }
    }
}

//MARK: Adaptar
extension NotificationViewController : ListAdapterDataSource {
    
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
        case is DiffableBox<UserNotification>:
            return NotificationSectionController(delegate: self, tappableDelegate: self)
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
            view.backgroundMode = .notifications
            return view
        }
        return nil
    }
}

//MARK: Cell
extension NotificationViewController : TappableDelegate {
    func tappableCell<T>(cell: T, didSelectItemWith userID: String) {
        showWaitingCircleAndBlockUserInteraction()
        navigateToUserProfile(userID: userID)
    }
}

//MARK:
extension NotificationViewController : NotificationSectionControllerDelegate {
    func notificationSection(_ notificationSection: NotificationSectionController, didTapped notification: UserNotification) {
        showWaitingCircleAndBlockUserInteraction()
        setNotificationSeen(notificationID: notification.id)
        navigateToAnswer(from: notification)
    }
}

//MARK:
extension NotificationViewController : AppNavigable {
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

//MARK: DataSource
extension NotificationViewController {
    func filterDatasource(dataSource: [UserNotification], filter: String) -> [UserNotification] {
        return dataSource.filter{ $0.status.contains(filter) }
    }
}

//MARK: Questions
extension NotificationViewController : NotificationHandler {
    
    func notificationHasUpdated() {
        self.refreshData()
        self.reloadData()
    }
    
    func notificationsHasArrived(notifications: [UserNotification]) {
        self.isRequestMoreData = false
        self.isFirstDataRequest = false
        if paginationControl.pageNumber == 0 {
            dataSource.removeAll()
        }
        paginationControl.process(data: notifications)
        let filter = segmentedControl.currentSegment == 0 ? "UNREAD" : "SEEN"
        let filteredDataSource = self.filterDatasource(dataSource: notifications, filter: filter)
        dataSource.append(contentsOf: filteredDataSource)
        reloadData()
    }
    
    func notificationServiceHadAnError(query: NotificationQueries, error: String) {
        self.isRequestMoreData = false
        self.isFirstDataRequest = false
        print(error)
        self.reloadData()
    }
}

//MARK: SegmentedDataSource
extension NotificationViewController: SJFluidSegmentedControlDataSource {
    
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        let numberOfSegments : Int = 2
        return numberOfSegments
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          titleForSegmentAtIndex index: Int) -> String? {
        if index == 0 { return "NEW".uppercased() }
        return "READ".uppercased()
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
extension NotificationViewController: SJFluidSegmentedControlDelegate {
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          didChangeFromSegmentAtIndex fromIndex: Int,
                          toSegmentAtIndex toIndex:Int) {
        self.refreshData()
        self.reloadData()
    }
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, didScrollWithXOffset offset: CGFloat) {}
}
