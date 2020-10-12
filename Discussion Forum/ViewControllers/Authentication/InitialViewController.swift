
import Foundation
import UIKit

class InitialViewController : UIViewController, Instantiable {
    
    static var nibIdentifier: String = "Authentication"
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var loadingIndicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ApplicationSession.sharedInstance.setup()
        self.setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getNextViewController()
    }
    
    private func setupViews() {
        self.loadingIndicator.type = .ballScale
        self.loadingIndicator.color = UIColor(hex: "#0071FE")
        self.loadingIndicator.startAnimating()
    }
}

//MARK:
extension InitialViewController: AuthenticationHandler {
    func loginHasErrors(_ error: String) {}
    func loginShouldNavigate(to viewController: UIViewController, animated: Bool) {
        self.navigationController?.pushViewController(viewController, animated: false)
    }
}

//MARK:
extension InitialViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
