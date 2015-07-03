//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Christopher Whidden on 6/28/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import Foundation
import MapKit

private let sharedParseClient = ParseClient()

class ParseClient: NSObject {
    let session = NSURLSession.sharedSession()
    let baseURLString = "https://api.parse.com/1/classes/"
    static let sharedInstance = sharedParseClient
    
    struct Methods {
        static let studentLocation = "StudentLocation"
        static let updateLocation = "StudentLocation/{objectID}"
    }
    
    private override init() {}
    
    func getStudentLocations(completionHandler: (studentLocations: [StudentLocation]?, error: NSError?) -> Void) {
        let params = ["limit" : 100]
        let urlString = baseURLString + Methods.studentLocation + escapedParameters(params)
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(studentLocations: nil, error: error)
                return
            }
            var jsonError: NSError?
            let json = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &jsonError) as! [String:AnyObject]
            if jsonError == nil {
                let studentLocations = StudentLocation.studentLocationsFromJSON(json)
                completionHandler(studentLocations: studentLocations, error: nil)
            } else {
                completionHandler(studentLocations: nil, error: jsonError)
            }
        }
        task.resume()
    }
    
    func postStudentLocation(key: Int, firstName: String, lastName: String, mapString: String, location: CLLocationCoordinate2D, userLink: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        let urlString = baseURLString + Methods.studentLocation
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(key)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(userLink)\",\"latitude\": \(location.latitude), \"longitude\": \(location.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, error: error)
            } else {
                completionHandler(success: true, error: error)
            }
            
        }
        task.resume()
    }
}