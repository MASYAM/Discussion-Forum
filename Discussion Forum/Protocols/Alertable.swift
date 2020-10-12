
import Foundation
import UIKit
import SVProgressHUD

protocol Alertable {}

extension Alertable where Self: UIViewController {
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertMessage(message:String, seconds: Double = 0.0, completionBlock: (()->())? = nil) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show(withStatus: message)
        if seconds > 0.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds ) {
                SVProgressHUD.dismiss()
                if completionBlock != nil {
                    completionBlock!()
                }
            }
        }
    }
    
    func showOKMessage(message:String, seconds: Double = 0.0, completionBlock: (()->())? = nil) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.showSuccess(withStatus: message)
        if seconds > 0.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds ) {
                SVProgressHUD.dismiss()
                if completionBlock != nil {
                    completionBlock!()
                }
            }
        }
    }
    
    func showErrorMessage(message:String, seconds: Double = 0.0, completionBlock: (()->())? = nil) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.showError(withStatus: message)
        if seconds > 0.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds ) {
                SVProgressHUD.dismiss()
                if completionBlock != nil {
                    completionBlock!()
                }
            }
        }
    }
    
    func showWaitingCircle() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
    }
    
    func showWaitingCircleAndBlockUserInteraction() {
        self.view.isUserInteractionEnabled = false
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
    }
    
    func hideWaitingCircleAndEnableUserInteraction(){
        self.view.isUserInteractionEnabled = true
        SVProgressHUD.dismiss()
    }
    
    func showProgress(message:String, progress:Float) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.showProgress(progress, status: message)
    }
    
    func hideAlertMessage(){
        SVProgressHUD.dismiss()
    }
    
}
