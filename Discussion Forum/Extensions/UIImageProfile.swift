
import Foundation
import UIKit
import AlamofireImage
import Alamofire
import ObjectiveC

//MARK: Alamofire
extension UIImageView {
    
    convenience init(baseImageView: UIImageView, frame: CGRect) {
        self.init(frame: CGRect.zero)
        image = baseImageView.image
        contentMode = baseImageView.contentMode
        clipsToBounds = true
        self.frame = frame
    }
    
    func makeCircular() {
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.layer.masksToBounds = true
    }
    
    func clearImageFromCache(imageCode: String) {
        let url = URL(string: imageCode)!
        let urlRequest = URLRequest(url: url)
        let imageDownloader = UIImageView.af_sharedImageDownloader
        let _ = imageDownloader.imageCache?.removeImage(for: urlRequest, withIdentifier: nil)
        imageDownloader.sessionManager.session.configuration.urlCache?.removeCachedResponse(for: urlRequest)
    }

    //MARK: Profile
    func getProfileImage(_ imageCode:String, makeCircular:Bool = true) {
        guard !imageCode.isEmpty else {
            self.image = UIImage(named: "avatar_blue")!
            print("WARNING: Profile Image Code is Empty.")
            return
        }
        let urlRequest = URLRequest(url: URL(string: imageCode)!)
        let placeholder:UIImage = UIImage(named: "avatar_blue")!
        loadImage(urlRequest: urlRequest, makeCircular: makeCircular, placeholderImage: placeholder)
    }
    
    //MARK: Call
    fileprivate func loadImage(urlRequest: URLRequest, makeCircular:Bool, placeholderImage:UIImage? = nil){
        Alamofire.DataRequest.addAcceptableImageContentTypes(["image/png"])
        if makeCircular { self.makeCircular() }
        DispatchQueue.main.async {
            self.af_setImage(withURLRequest: urlRequest,
                             placeholderImage: placeholderImage,
                             filter: nil,
                             progress: nil,
                             progressQueue: DispatchQueue.global(qos: .background),
                             imageTransition: .crossDissolve(0.2),
                             runImageTransitionIfCached: true,
                             completion: { dataResponse in
                                DispatchQueue.main.async {
                                    if makeCircular { self.makeCircular() }
                                    if let image : UIImage = dataResponse.result.value {
                                        self.contentMode = .scaleAspectFill
                                        self.image = image
                                        self.contentMode = .scaleAspectFill
                                    }
                                }
            })
        }
    }
}
