
import Foundation
import UIKit
import GoogleSignIn
import FirebaseAuth

enum SignInSegment : Int {
    case loginView = 0
    case registerView = 1
}

class SignInViewController : UIViewController, Instantiable, Alertable {
    
    static var nibIdentifier: String = "Authentication"
    
    @IBOutlet private weak var backgroundScrollView: UIScrollView!
    @IBOutlet private weak var segmentedControl: SJFluidSegmentedControl!
    @IBOutlet private weak var submitButton: TKTransitionSubmitButton!
    
    private var loginView: LoginView?
    private var registerView: RegisterView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSegmentedControl()
        self.setupNotifications()
        self.createViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segmentedControl(segmentedControl, didScrollWithXOffset: 0)
        segmentedControl.currentSegment = 0
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SignInViewController.keyboardWillBeShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SignInViewController.keyboardWillBeHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func getRegistrable() -> Credential? {
        guard loginView != nil else { return nil }
        guard registerView != nil else { return nil }
        
        switch segmentedControl.currentSegment {
        case SignInSegment.loginView.rawValue:
            return loginView?.values
        case SignInSegment.registerView.rawValue:
            return registerView?.values
        default:
            return nil
        }
    }
    
    private func setupSegmentedControl() {
        segmentedControl.dataSource = self
        segmentedControl.delegate = self
        segmentedControl.shapeStyle = .roundedRect
        segmentedControl.shadowsEnabled = false
        if let font = UIFont(name: "Montserrat-SemiBold", size: 14) {
            segmentedControl.textFont = font
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        if let registrable = getRegistrable() {
            if registrable.hasValidData() {
                submitButton.startLoadingAnimation()
                submitButton.isEnabled = false
                if segmentedControl.currentSegment == SignInSegment.loginView.rawValue {
                    loginWith(userData: registrable)
                }
                else {
                    registerWith(userData: registrable)
                }
            }
            else {
                self.showAlert(title: "Attention", message: "Complete all fields")
            }
        }
    }
}

//MARK: Initialization
extension SignInViewController : AuthenticationHandler {
    
    func loginHasCompleted() {
        self.submitButton.startFinishAnimation(0) {
            self.submitButton.isEnabled = true
            self.getNextViewController()
        }
    }
    
    func loginHasErrors(_ error: String) {
        self.submitButton.startFinishAnimation(0) {
            self.submitButton.isEnabled = true
            self.showAlert(title: "Error", message: error)
        }
    }
    
    func loginShouldNavigate(to viewController: UIViewController, animated: Bool) {
        self.navigationController?.pushViewController(viewController, animated: false)
    }
}

extension SignInViewController : LoginViewDelegate {
    
    func loginView(loginView: LoginView, didTappedForgotPasswordWith email: String) {
        if !email.isEmpty, email.isValidEmail() {
            self.forgotPassword(email: email, completionBlock: { message in
                self.showAlert(title: "Password", message: message)
            })
        }
        else {
            self.showAlert(title: "Password", message: "Valid user needed")
        }
    }
    
    func loginView(loginView: LoginView, didSignInWithGoogle user: GIDGoogleUser) {
        self.view.endEditing(true)
        self.submitButton.startLoadingAnimation()
        let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken,accessToken: user.authentication.accessToken)
        loginWith(crendential: credential)
    }
}

// DataSource
extension SignInViewController {
    func createViews() {
        let slideCount : Int = 2
        backgroundScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        backgroundScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slideCount), height: view.frame.height)
        backgroundScrollView.isPagingEnabled = true
        
        loginView = (Bundle.main.loadNibNamed("LoginView", owner: self, options: nil)?.first as! LoginView)
        loginView!.configure()
        loginView!.delegate = self
        loginView!.frame = CGRect(x: view.frame.width * CGFloat(0), y: 0, width: view.frame.width, height: view.frame.height)
        backgroundScrollView.addSubview(loginView!)
        
        registerView = (Bundle.main.loadNibNamed("RegisterView", owner: self, options: nil)?.first as! RegisterView)
        registerView!.configure()
        registerView!.frame = CGRect(x: view.frame.width * CGFloat(1), y: 0, width: view.frame.width, height: view.frame.height)
        backgroundScrollView.addSubview(registerView!)
    }
}

//MARK: SegmentedDataSource
extension SignInViewController: SJFluidSegmentedControlDataSource {
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        let numberOfSegments : Int = 2
        return numberOfSegments
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          titleForSegmentAtIndex index: Int) -> String? {
        if index == 0 { return "LOGIN".uppercased() }
        return "REGISTER".uppercased()
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          gradientColorsForSelectedSegmentAtIndex index: Int) -> [UIColor] {
        let blueColor : UIColor = UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 1.0)
        return [blueColor, blueColor]
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          gradientColorsForBounce bounce: SJFluidSegmentedControlBounce) -> [UIColor] {
        let gradientColor : UIColor = UIColor(red: 0 / 255.0, green: 128 / 255.0, blue: 255 / 255.0, alpha: 1.0)
        return [gradientColor, gradientColor]
    }
}

//MARK: SJFluidSegmentedControlDelegate
extension SignInViewController: SJFluidSegmentedControlDelegate {
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, didScrollWithXOffset offset: CGFloat) {
        let maxOffset = segmentedControl.frame.width / CGFloat(segmentedControl.segmentsCount * (segmentedControl.segmentsCount - 1))
        let width = view.frame.width
        let rightDistance = (backgroundScrollView.contentSize.width - width)
        let backgroundScrollViewOffset = ((offset / maxOffset) * (backgroundScrollView.contentSize.width - rightDistance))
        backgroundScrollView.contentOffset = CGPoint(x: backgroundScrollViewOffset, y: 0)
    }
}

//MARK: Keyboard
extension SignInViewController {
    
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
