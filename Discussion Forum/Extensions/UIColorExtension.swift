
import Foundation
import UIKit

extension UIColor {
    
    convenience init(hex: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if hex.hasPrefix("#") {
            let index   = hex.index(hex.startIndex, offsetBy: 1)
            let hex     = hex[index...]
            let scanner = Scanner(string: String(hex))
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
                switch (hex.count) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8", terminator: "")
                }
            } else {
                //                print("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix", terminator: "")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    class func clearGrayColor() -> UIColor {
        return UIColor(hex: "#E5E5E5")
    }
    
    class func cyanStarMeUpColor() -> UIColor {
        return UIColor(hex: "#00BCD4")
    }
    
    class func blueStarMeUpColor() -> UIColor {
        return UIColor(hex: "#0E5A69")
    }
    class func clearSilverColor() -> UIColor {
        return UIColor(red: 204/255, green: 215/255, blue: 223/255, alpha: 0.4)
    }
    
    
    class func lighterColorForColor(color: UIColor) -> UIColor {
        
        var red : CGFloat = 0
        var green : CGFloat = 0
        var blue : CGFloat = 0
        var alpha : CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: min(red + 0.2, 1.0), green: min(green + 0.2, 1.0), blue: min(blue + 0.2, 1.0), alpha: alpha)
    }
    
    class func darkerColorForColor(color: UIColor) -> UIColor {
        
        var red : CGFloat = 0
        var green : CGFloat = 0
        var blue : CGFloat = 0
        var alpha : CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: max(red - 0.2, 0.0), green: max(green - 0.2, 0.0), blue: max(blue - 0.2, 0.0), alpha: alpha)
    }
    func darkerColor() -> UIColor {
        
        return UIColor.darkerColorForColor(color: self)
    }
    
    func lighterColor() -> UIColor {
        return UIColor.lighterColorForColor(color: self)
    }
    
    // red, green and blue components values: 0 - 255.0
    class func colorWithComponents(red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat = 1.0) -> UIColor
    {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    
}
