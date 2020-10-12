
import Foundation
import UIKit

extension UIImage {
    
    func rotatedImageWithTransform(_ rotation: CGAffineTransform, croppedToRect rect: CGRect) -> UIImage {
        let rotatedImage = rotatedImageWithTransform(rotation)
        
        let scale = rotatedImage.scale
        let cropRect = rect.applying(CGAffineTransform(scaleX: scale, y: scale))
        
        let croppedImage = rotatedImage.cgImage?.cropping(to: cropRect)
        let image = UIImage(cgImage: croppedImage!, scale: self.scale, orientation: rotatedImage.imageOrientation)
        return image
    }
    
    fileprivate func rotatedImageWithTransform(_ transform: CGAffineTransform) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: size.width / 2.0, y: size.height / 2.0)
        context?.concatenate(transform)
        context?.translateBy(x: size.width / -2.0, y: size.height / -2.0)
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage!
    }
    
    static func squareScaleImage(image: UIImage, ToWidth width: CGFloat, maxSize: CGSize) -> UIImage {
        let oldWidth = image.size.width
        let scaleFactor = width / oldWidth
        
        let newHeight = image.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        let canvas = CGRect(origin: CGPoint(x: 0, y: 0), size: maxSize)
        
        UIGraphicsBeginImageContext(maxSize)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(canvas)
        image.draw(in: CGRect(x: (canvas.size.width - newWidth) / 2,
                              y: (canvas.size.height - newHeight) / 2,
                              width: newWidth,
                              height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func scaleRectAccordingToRect(fromRect: CGSize, toRect:CGSize) -> CGSize {
        var newRect:CGSize = CGSize()
        
        let aspectWidth = fromRect.width / toRect.width
        let aspectHeight = fromRect.height / toRect.height
        let aspectRatio = fromRect.width / fromRect.height
        if aspectWidth >= aspectHeight {
            newRect.width = toRect.width
            newRect.height = toRect.height * aspectRatio
        } else {
            newRect.height = toRect.height
            newRect.width = toRect.height / aspectRatio
        }
        return newRect
    }
}
