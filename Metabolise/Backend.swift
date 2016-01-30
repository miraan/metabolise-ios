//
//  Backend.swift
//  Metabolise
//
//  Created by Miraan on 30/01/2016.
//  Copyright © 2016 Miraan. All rights reserved.
//

import Foundation

class Backend {
    class func call(method: String!, params: [String:String]?, completionHandler: (success: Bool, jsonResponse: JSON?, backendError: NSError?) -> Void) {
        call(method, params: params, attempt: 1, HTTPMethod: "GET", contentType: nil, HTTPBody: nil, completionHandler: completionHandler)
    }
    
    class func call(method: String!, var params: [String:String]?, attempt: Int, HTTPMethod: String, contentType: String?, HTTPBody: NSData?, completionHandler: (success: Bool, jsonResponse: JSON?, backendError: NSError?) -> Void) {
        var url = baseUrl.rawValue + method
        
        if params == nil {
            params = [String:String]()
        }
        
        if let infoDictionary = NSBundle.mainBundle().infoDictionary {
            params!["appVersion"] = (infoDictionary ["CFBundleShortVersionString"] as! String)
            params!["appBuild"] = (infoDictionary ["CFBundleVersion"] as! String)
        }
        
        params!["deviceType"] = "ios";
        params!["deviceId"] = UIDevice.currentDevice().identifierForVendor!.UUIDString
        if let deviceToken = Device.get()?.deviceToken {
            params!["deviceToken"] = deviceToken
            #if DEBUG
                params!["development"] = "1"
            #endif
        }
        
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
        
        let authheader = getAuthorisationHeaderValue()
        print(User.get()?.token, terminator: "")
        let token = User.get()?.token
        request.setValue(getAuthorisationHeaderValue(), forHTTPHeaderField: "Authorisation")
        request.setValue(User.get()?.token, forHTTPHeaderField: "Token")
        
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
                        } else if AppDelegate.connectedToInternet {
                            AppDelegate.connectedToInternet = false
                            AppDelegate.refreshConnectionStatus(true)
                        }
                    }
                }
            } else if !AppDelegate.connectedToInternet {
                AppDelegate.connectedToInternet = true
                AppDelegate.refreshConnectionStatus(true)
            }
            if data != nil {
                //var stringResponse = NSString(data: data!, encoding: NSUTF8StringEncoding)
                //print("Backend call string response: \(stringResponse)")
            }
            
            var backendError: NSError?
            var jsonResponse: JSON? = nil
            var success: Bool = true
            
            if let error = error {
                backendError = error
                success = false
                
            }
            
            if data != nil {
                jsonResponse = JSON(data: data!)
                
                if let status = jsonResponse!["status"].int {
                    if status != 1 {
                        if let errorMessageString = jsonResponse!["errorMessage"].string {
                            backendError = NSError(domain: "Backend Error", code: status, userInfo: ["description": errorMessageString])
                            success = false
                            
                        } else {
                            backendError = NSError(domain: "Backend Error", code: status, userInfo: ["description": "No error message received from backend"])
                            success = false
                            
                        }
                    }
                } else {
                    backendError = NSError(domain: "Backend Error", code: 9, userInfo: ["description": "No status received from backend"])
                    success = false
                    
                }
            }
            completionHandler(success: success, jsonResponse: jsonResponse, backendError: backendError)
            
            // debugging
            if jsonResponse != nil {
                print("Backend Call: " + url + ", Response: " + jsonResponse!.description)
            }
        }
    }
}