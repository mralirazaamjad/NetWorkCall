//
//  ParsingDicFunctions.swift
//  PrimeTimeTrainers
//
//  Created by Ali Raza on 18/04/2019.
//  Copyright © 2019 Ali Raza Amjad. All rights reserved.
//
import Foundation
import UIKit

@objcMembers class APICaller: NSObject, NSURLConnectionDelegate
{
    
    var responseData:Data? = nil
    let apiRequestTimeOut : TimeInterval    = 20 //seconds
    
    func sendAPICall(_ type : String, methodNameWithBaseURL method : String, key: String?, params param: AnyObject?, completed : @escaping (_ succeeded: Bool, _ result: AnyObject?) -> Void) {
        
        if(Utility.HelperFuntions.connectionStatus == "reachable"){
            
            switch type {
            case "POST":
                print("post")
                
                sendPostCall(param!, url:method, method: type, postCompleted: {(succeeded: Bool, msg: AnyObject) -> () in
                    
                    if(succeeded) {
                        completed(true, msg)
//                        let responseResult  = msg as! NSDictionary
//
//                        if let isSuccess        = responseResult.object(forKey: "success") as? Bool {
//
//                            if(isSuccess) {
//
//                                completed(true, responseResult)
//
//                            }else {
//
//                                completed(false, responseResult)
//
//                            }
//                        } else {
//
//                            // pop to root
//                            completed(false, responseResult)
//
//                        }
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            if  msg is Dictionary<String, Int> {
                                
                                if let errorCode = msg.object(forKey: "Error") as? Int {
                                    
                                    if errorCode == 401 {
                                        Utility.HelperFuntions.showAlert("Session Expired!", withMessage:Utility.HelperFuntions.sessionIDExpireMessage)
                                        
                                    } else {
                                        
                                        Utility.HelperFuntions.showAlert("", withMessage:Utility.HelperFuntions.serverMessage)
                                    }
                                } else {
                                    
                                    Utility.HelperFuntions.showAlert("", withMessage:Utility.HelperFuntions.serverMessage)
                                }
                                
                            } else {
                                
                                Utility.HelperFuntions.showAlert("", withMessage:Utility.HelperFuntions.serverMessage)
                            }
                            
                        }
                        
                        completed(false, msg)
                    }
                })
                
            case "DELETE":
                print("delete")
                
            case "UPDATE":
                print("update")
                
            default:
                print("GET")
                print(method)
                
                sendGetCall(method, key: key, postCompleted: {(succeeded: Bool, msg: AnyObject) -> () in
                    
                    if(succeeded) {
                        completed(true, msg)
//                        let responseResult  = msg as! NSDictionary
//                        if let isSuccess        = responseResult.object(forKey: "success") as? Bool {
//
//                            if(isSuccess) {
//
//                                completed(true, responseResult)
//
//                            }else {
//
//                                completed(false, responseResult)
//
//                            }
//                        } else {
//
//                            completed(false, responseResult)
//
//                        }
                    }
                        
                    else {
                        
                        DispatchQueue.main.async { 
                            
                            if  msg is Dictionary<String, Int> {
                                
                                if let errorCode = msg.object(forKey: "Error") as? Int {
                                    
                                    if errorCode == 401 {
                                        
                                        Utility.HelperFuntions.showAlert("Session Expired!", withMessage:Utility.HelperFuntions.sessionIDExpireMessage)
                                        
                                    } else {
                                        
                                        Utility.HelperFuntions.showAlert("", withMessage:Utility.HelperFuntions.serverMessage)
                                    }
                                } else {
                                    
                                    Utility.HelperFuntions.showAlert("", withMessage:Utility.HelperFuntions.serverMessage)
                                }
                                
                            } else {
                                
                                Utility.HelperFuntions.showAlert("", withMessage:Utility.HelperFuntions.serverMessage)
                            }
                            
                        }
                        
                        completed(false, msg)
                    }
                })
            }
            
        }else {
            
            //network issue
            completed(false, nil)
            Utility.HelperFuntions.showAlert("Connection Issue!", withMessage: Utility.HelperFuntions.internetMessage)
        }
    }
    
    //POST and PUT
    func getPostString(params:[String:String]) -> String
    {
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    
    func sendPostCall(_ params : AnyObject, url : String, method: String,postCompleted : @escaping (_ succeeded: Bool, _ result: AnyObject) -> ()) {
        var request = URLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        request.httpMethod = method
        request.timeoutInterval = apiRequestTimeOut
        
        let postString = self.getPostString(params: params as! [String : String])
        request.httpBody = postString.data(using: .utf8)
//        request.addValue("Bearer \(Utility.HelperFuntions.getLoginValues("token"))", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            print("Response: \(String(describing: response))")
            
            let httpURLResponse =  response as? HTTPURLResponse;
            if let statusCode = httpURLResponse?.statusCode {
                
                switch (statusCode) {
                    
                case 200:                   // Authorized
                    
                    break;
                case 401:                   // Unauthorized
                    
                    postCompleted(false, ["Error" : 401] as AnyObject)
                    return
                default:
                    
                    break;
                }
            }
            
            if (data == nil) {
                
                if error?._code ==  401 {
                    print("Time Out")
                    //Call your method here.
                }
                
                postCompleted(false, "Error" as AnyObject)
                
            } else {
                
                // Print reponse in String on console
                if let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                    print("Body: \(strData)") }
                
                let responseResult = self.parseDataToJSON(data!)
                
                if responseResult == nil {
                    
                    postCompleted(false, "Error" as AnyObject)
                    
                }else{
                    
                    postCompleted(true, responseResult!)
                }
            }
        })
        
        task.resume()
        
    }
    
    //GET
    func sendGetCall( _ url : String, key: String?, postCompleted : @escaping (_ succeeded: Bool, _ result: AnyObject) -> ()) {
        
        var request = URLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        request.httpMethod = "GET"
        request.timeoutInterval = apiRequestTimeOut
        
        //var err: NSError?
        if (key != nil){
//            request.addValue("Bearer \(Utility.HelperFuntions.getLoginValues("token"))", forHTTPHeaderField: key!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }else{
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
    
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            print("Response: \(String(describing: response))")
            
            let httpURLResponse =  response as? HTTPURLResponse;
            if let statusCode = httpURLResponse?.statusCode {
                
                switch (statusCode) {
                    
                case 200:                   // Authorized
                    
                    break;
                case 401:                   // Unauthorized
                    
                    postCompleted(false, ["Error" : 401] as AnyObject)
                    return
                case 404:                   // Unauthorized when URL Changed
                    
                    postCompleted(false, ["Error" : 404] as AnyObject)
                    return
                default:
                    
                    break;
                }
            }
            
            if (data == nil) {
                
                postCompleted(false, "Error" as AnyObject)
                
            } else {
                
                let responseResult = self.parseDataToJSON(data!)
                
                if responseResult == nil {
                    
                    postCompleted(false, "Error" as AnyObject)
                    
                }else{
                    
                    postCompleted(true, responseResult!)
                }
            }
            
            
            
        })
        
        task.resume()
    }
    
    private func parseDataToJSON(_ data:Data) -> AnyObject? {
        
        //var err: NSError?
        //var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                print(json)
                
                if let success = json["success"] as? Bool {
                    print("Succes: \(success)")
                    
                }
                
                return json
            }else if let arrayJson = try JSONSerialization.jsonObject(with: data, options: []) as? [NSDictionary] {
                print(arrayJson)
                
                return arrayJson as AnyObject
            } else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print("Error could not parse JSON: \(String(describing: jsonStr))")
                return nil
            }
            
        } catch {
            
            print(error)
            let jsonStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            print("Error could not parse JSON: '\(String(describing: jsonStr))'")
            return nil
            
        }

    }
    
    func sendGetDownloadCall( _ url : String, postCompleted : @escaping (_ succeeded: Bool, _ result: AnyObject, _ header: AnyObject) -> ()) {
        
        var request = URLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        request.httpMethod = "GET"
        request.timeoutInterval = apiRequestTimeOut
        
        //var err: NSError?
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            print("Response: \(String(describing: response))")
            
            let httpURLResponse =  response as? HTTPURLResponse;
            if let statusCode = httpURLResponse?.statusCode {
                
                switch (statusCode) {
                    
                case 200:                   // Authorized
                    
                    break;
                case 401:                   // Unauthorized
                    
                    postCompleted(false, ["Error" : 401] as AnyObject, "" as AnyObject)
                    return
                default:
                    
                    break;
                }
            }
            
            if (data == nil) {
                
                postCompleted(false, "Error" as AnyObject, "" as AnyObject)
                
            } else {
                
                if let header = httpURLResponse?.allHeaderFields {
                    
                    postCompleted(true, data! as AnyObject, header as AnyObject)
                }
            }
            
        })
        
        task.resume()
    }
    
    //MARK: Image POST Call
    func sendPostCallIncludeMedia(_ type : String, methodNameWithBaseURL method : String, params param:AnyObject?, key: String?, completed : @escaping (_ succeeded: Bool, _ result: AnyObject?) -> Void) {
        
        if(Utility.HelperFuntions.connectionStatus == "reachable"){
            
            let session = URLSession.shared
            var request  = URLRequest(url: URL(string:method)!)
            request.timeoutInterval = apiRequestTimeOut
            request.httpMethod = "POST"
            request.timeoutInterval = apiRequestTimeOut
            
            let boundary = "Boundary-\(UUID().uuidString)"
            if (key != nil){
//                request.addValue("Bearer \(Utility.HelperFuntions.getLoginValues("token"))", forHTTPHeaderField: key!)
            }
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            if let parameter = param as? NSDictionary {
                request.httpBody = createBody(parameters: parameter as! [String : Any],
                                              boundary: boundary,
                                              mimeType: "image/png",
                                              filename:Utility.HelperFuntions.currentDateTimeForPhoto())
            }
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                print("Response: \(String(describing: response))")
                
                let httpURLResponse =  response as? HTTPURLResponse;
                if let statusCode = httpURLResponse?.statusCode {
                    
                    switch (statusCode) {
                        
                    case 200:                   // Authorized
                        
                        break;
                    case 401:                   // Unauthorized
                        
                        completed(false, ["Error" : 401] as AnyObject)
                        return
                    default:
                        
                        break;
                    }
                }
                
                if (data == nil) {
                    
                    if error?._code ==  401 {
                        print("Time Out")
                        //Call your method here.
                    }
                    
                    completed(false, "Error" as AnyObject)
                    
                } else {
                    
                    // Print reponse in String on console
                    if let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                        print("Body: \(strData)") }
                    
                    let responseResult = self.parseDataToJSON(data!)
                    
                    if responseResult == nil {
                        
                        completed(false, "Error" as AnyObject)
                        
                    }else{
                        
                        completed(true, responseResult!)
                    }
                }
            })
            
            task.resume()
            
            
            
        }else {
            
            //network issue
            completed(false, nil)
            
        }
    }
    
    func createBody(parameters: [String: Any],
                    boundary: String,
                    mimeType: String,
                    filename: String) -> Data {
        let body = NSMutableData()
        
        ///////////
        for (key, value) in parameters {
            
            print("\(key)")
            
            if let val = value as? String {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(val)\r\n")
            }
            else if let val = value as? Int {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(val)\r\n")
            }
            else if let val = value as? UIImage {
                
                let upload_image = val
                let filename = "image_\(Utility.HelperFuntions.currentDateTimeForPhoto()).png"
                let data = upload_image.pngData()
                
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n")
                body.appendString("Content-Type: \(mimeType)\r\n\r\n")
                body.append(data!)
                body.appendString("\r\n")
                
            }
            else if let val = value as? URL {
                // upload Video
                let movieData = NSData(contentsOf: val)
                let filename = "trainer_\(Utility.HelperFuntions.currentDateTimeForPhoto()).mp4"
                let mimetyp = "video/mov"
                
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition:form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Type: \(mimetyp)\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append(movieData! as Data)
                body.appendString("\r\n")
            }
        }
        
        body.appendString("--\(boundary)--\r\n")
        
        return body as Data
    }
}
