//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Christopher Whidden on 6/28/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import Foundation

private let sharedUdacityClient = UdacityClient()

class UdacityClient: NSObject {
    let session = NSURLSession.sharedSession()
    let baseURLString = "https://www.udacity.com/api/"
    static let sharedInstance = sharedUdacityClient
    
    struct Methods {
        static let session = "session"
        static let userData = "users/{userID}"
    }
    
    private override init() {}
    
    func loginToUdacity(userName: String, password: String, completionHandler: (data: NSDictionary!, error: NSError?)->Void) {
        let urlString = baseURLString + Methods.session
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(data: nil, error: error)
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            var jsonError: NSError? = nil
            let json = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as! NSDictionary
            println(json)
            completionHandler(data: json, error: jsonError)
        }
        task.resume()
    }
    
    func logoutOfUdacity(completionHandler: (success: Bool) -> Void) {
        let urlString = baseURLString + Methods.session
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(success: false)
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            var jsonError: NSError? = nil
            let json = NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments, error: &jsonError) as! NSDictionary
            completionHandler(success: true)
        }
        task.resume()
    }
    
    func getDataForUser(userID: Int, completionHandler: (data: NSDictionary!, error: NSError?)->Void) {
        let urlString = baseURLString + substituteKeyInMethod(Methods.userData, "userID", String(userID))
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completionHandler(data: nil, error: error)
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            var jsonError: NSError? = nil
            let json = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as! NSDictionary
            println(json)
            completionHandler(data: json, error: nil)
        }
        task.resume()
    }
    
    
}