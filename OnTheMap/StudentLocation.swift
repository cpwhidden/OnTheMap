//
//  PersonPin.swift
//  OnTheMap
//
//  Created by Christopher Whidden on 6/28/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import Foundation

struct StudentLocation {
    let objectID: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    
    struct Keys {
        static let objectID = "objectId"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    
    init(dictionary: [String:AnyObject]) {
        objectID = dictionary[Keys.objectID] as! String
        uniqueKey = dictionary[Keys.uniqueKey] as! String
        firstName = dictionary[Keys.firstName] as! String
        lastName = dictionary[Keys.lastName] as! String
        mapString = dictionary[Keys.mapString] as! String
        mediaURL = dictionary[Keys.mediaURL] as! String
        latitude = dictionary[Keys.latitude] as! Double
        longitude = dictionary[Keys.longitude] as! Double
    }
    
    static func studentLocationsFromJSON(json: [String:AnyObject]) -> [StudentLocation] {
        if let results = json["results"] as? [[String:AnyObject]] {
            let studentLocations: [StudentLocation?] = map(results) { (result: [String:AnyObject]) -> StudentLocation? in
                return StudentLocation(dictionary: result)
            }
            return studentLocations.filter({$0 != nil}).map({$0!})
        }
        return []
    }
}