
import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

//MARK:
enum ImageServiceError : String {
    case emptySnapshot = "SNAPSHOT_NOT_FOUND"
    case emptyParameter = "INCORRECT_PARAMETER"
    case errorUploading = "UPLOAD_ERROR"
    case errorDownloading = "DOWNLOAD_ERROR"
}

//MARK:
class ImageService {
    
    func setImage(image: UIImage,
                  userID: String,
                  successBlock: @escaping (_ imageCode: String)->(),
                  failBlock: @escaping (_ error: String)->()) {
        let childName : String = userID + "_avatar.png"
        let ref = Storage.storage().reference().child(childName)
        if let imageData = image.pngData() {
            ref.putData(imageData, metadata: nil, completion: { metaData, error in
                if error != nil{
                    failBlock(ImageServiceError.errorUploading.rawValue)
                }
                else {
                    ref.downloadURL(completion: { url, error in
                        if error != nil {
                            failBlock(ImageServiceError.errorUploading.rawValue)
                        }
                        else {
                            let databaseRef = Database.database().reference()
                            databaseRef.child(FirebaseConstants.users).child(userID).child("imageURL").setValue(url!.absoluteString)
                            successBlock(url!.absoluteString)
                        }
                    })
                }
            })
        }
    }
    
    func getImage(imageURL: String,
                  userID: String,
                  successBlock: @escaping (_ image: UIImage)->(),
                  failBlock: @escaping (_ error: String)->()) {
        let childName : String = userID + "_avatar.png"
        let ref = Storage.storage().reference().child(childName)
        ref.getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
            if error != nil {
                failBlock(ImageServiceError.errorDownloading.rawValue)
            }
            else {
                guard data != nil else { failBlock("Error"); return }
                if let image = UIImage(data: data!) {
                    successBlock(image)
                }
                else {
                    failBlock(ImageServiceError.errorDownloading.rawValue)
                }
                
            }
        })
    }
}
