//
//  URLUtilities.swift
//  OnTheMap
//
//  Created by Christopher Whidden on 6/29/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import Foundation


func escapedParameters(parameters: [String : AnyObject]) -> String {
    
    var urlVars = [String]()
    
    for (key, value) in parameters {
        
        /* Make sure that it is a string value */
        let stringValue = "\(value)"
        
        /* Escape it */
        let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        /* Append it */
        urlVars += [key + "=" + "\(escapedValue!)"]
        
    }
    
    return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
}

func substituteKeyInMethod(method: String, key: String, value: String) -> String {
    if method.rangeOfString("{\(key)}") != nil {
        return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
    } else {
        return ""
    }
}