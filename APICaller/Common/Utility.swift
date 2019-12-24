//
//  Utility.swift
//  OneTaxBariPhone
//
//  Created by Ali Raza on 06/10/2019.
//  Copyright © 2019 Ali Raza. All rights reserved.
//

import UIKit

var GlobalBackgroundQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
}

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    
    var idx = items.startIndex
    let endIdx = items.endIndex
    
    repeat {
        Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
        idx += 1
    }
        while idx < endIdx
}

class Utility: NSObject {
    
    struct HelperFuntions {
        
        static var sessionIDExpireMessage   = "Your session expired. Please login again."
        static var codeSessionExpire        = 401
        static let deviceToken              = ""
        static let source                   = "ios"
        static var _delegate: AppDelegate?  = nil
        static let camCardLanguage          = "en"
        static let internetMessage          = "Internet is not available. Please check your connection."
        static let internetReconnect        = "Your network connection is re-established successfully"
        static let serverMessage            = "Unable to process request. Please try again."
        static var connectionStatus        : String?
        static var reachability            : Reachability?
        static var storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        static var delegate:AppDelegate {
            if (_delegate == nil) {
                _delegate = UIApplication.shared.delegate as? AppDelegate
            }
            return _delegate!
        }
        
        static func showAlert(_ title: String, withMessage message: String) {
            DispatchQueue.main.async(execute: {
                let alertWindow = UIWindow(frame: UIScreen.main.bounds)
                alertWindow.rootViewController = UIViewController()
                alertWindow.windowLevel = UIWindow.Level.alert + 1
                
                let alert2 = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let defaultAction2 = UIAlertAction(title: "OK", style: .default, handler: { action in
                })
                alert2.addAction(defaultAction2)
                
                alertWindow.makeKeyAndVisible()
                
                alertWindow.rootViewController?.present(alert2, animated: true, completion: nil)
            })
        }
        
        static func setDateForPicker (_ setDate: String?, format: String = "dd/MM/yyyy") -> Date {
            
            let dateFormater:DateFormatter = DateFormatter()
            dateFormater.dateFormat = format
            
            return dateFormater.date(from: setDate!)!
            
        }
    
        static func currentDateTimeForPhoto()-> String{
            
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd-HH:mm:ss"
            let date = Date()
            let setDate = dateFormatter.string(from: date) as String
            
            return setDate
        }
        
        static func toDosListDC() -> [String]{
            return ["userId", "todos_id", "title", "completed"]
        }
        
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = self.index(startIndex, offsetBy: r.lowerBound)
        let end = self.index(start, offsetBy: r.upperBound - r.lowerBound)
        
        return String(self[(start ..< end)])
    }
    
    func textTrim () -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func validateRequiredField() -> Bool {
        var isValid = true
        let strText = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (strText == "") {
            
            isValid = false
        }
        return isValid
    }
    
    func validateEmail()-> Bool{
        let email = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let emailRegex = "[A-Z0-9a-z._%+-]+[A-Z0-9a-z]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let isValidate = emailTest.evaluate(with: email)
        return isValidate
    }
    
    func insert(_ string:String,index:Int) -> String {
        return  String(self.prefix(index)) + string + String(self.suffix(self.count-index))
    }
    
    func NICNumberFormat(enterChar char : String) -> String {
        var text = self
        if char != "" {
            if text.count == 13 {
                text = text + "-"
            } else if text.count > 13 {
                if text[13] != "-" {
                    _ = text.insert("-", index: 13)
                }
            }else if text.count == 5 {
                text = text + "-"
            } else if text.count > 5 {
                if text[5] != "-" {
                    _ = text.insert("-", index: 5)
                }
            }
        } 
        return text
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizedTo1MB() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        
        while imageSizeKB > 1000 { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.7),
                let imageData = resizedImage.pngData()
                else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1000.0 // ! Or devide for 1024 if you need KB but not kB
        }
        
        return resizingImage
    }
    
}
