//
//  Backend.swift
//  Metabolise
//
//  Created by Miraan on 30/01/2016.
//  Copyright © 2016 Miraan. All rights reserved.
//

import UIKit

class Backend {
    static var baseUrl = "http://192.168.43.173:3000/"
    
    class func query(text: String, completionHandler: (success: Bool, calories: Int?, units: String?, queryError: NSError?) -> Void) {
        call("", params: ["dish": text]) { (success: Bool, jsonResponse: JSON?, backendError: NSError?) in
            if !success {
                completionHandler(success: false, calories: nil, units: nil, queryError: backendError)
            } else {
                let calories = jsonResponse!["calories"].int
                let units = jsonResponse!["units"].string
                completionHandler(success: true, calories: calories, units: units, queryError: nil)
            }
        }
    }
    
    class func call(method: String!, params: [String:String]?, completionHandler: (success: Bool, jsonResponse: JSON?, backendError: NSError?) -> Void) {
        call(method, params: params, attempt: 1, HTTPMethod: "GET", contentType: nil, HTTPBody: nil, completionHandler: completionHandler)
    }
    
    class func call(method: String!, var params: [String:String]?, attempt: Int, HTTPMethod: String, contentType: String?, HTTPBody: NSData?, completionHandler: (success: Bool, jsonResponse: JSON?, backendError: NSError?) -> Void) {
        var url = baseUrl + method
        
        if params == nil {
            params = [String:String]()
        }
        
        params!["deviceType"] = "ios";
        params!["deviceId"] = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        if params != nil {
            url += "?"
            for (key, value) in params! {
                url += key + "=" + value + "&"
            }
            url = url.substringToIndex(url.endIndex.predecessor())
        }
        url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        print("Backend call: " + url)
        
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = HTTPMethod
        
        if contentType != nil {
            request.addValue(contentType!, forHTTPHeaderField: "Content-Type")
        }
        if HTTPBody != nil {
            request.HTTPBody = HTTPBody
        }
        
        switch attempt {
        case 2:
            request.timeoutInterval *= 2
        case 3:
            request.timeoutInterval *= 10
        default:
            break
        }
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response: NSURLResponse?, data: NSData?, error: NSError?) in
            if error != nil {
                if error!.domain == "NSURLErrorDomain" {
                    if error!.code == NSURLErrorTimedOut {
                        print("Request timed out (attempt #\(attempt))")
                        if attempt < 3 {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.call(method, params: params, attempt: attempt + 1, HTTPMethod: HTTPMethod, contentType: contentType, HTTPBody: HTTPBody, completionHandler: completionHandler)
                            })
                            return
                        }
                    }
                }
            }
//            if data != nil {
//                var stringResponse = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                print("Backend call string response: \(stringResponse)")
//            }
            
            var backendError: NSError?
            var jsonResponse: JSON? = nil
            var success: Bool = true
            
            if let error = error {
                backendError = error
                success = false
                
            }
            
            if data != nil {
                jsonResponse = JSON(data: data!)
                completionHandler(success: success, jsonResponse: jsonResponse, backendError: backendError)
            }
            
            // debugging
            if jsonResponse != nil {
                print("Backend Call: " + url + ", Response: " + jsonResponse!.description)
            }
        }
    }
}