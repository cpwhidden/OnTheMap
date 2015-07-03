//
//  SubmitLocationViewController.swift
//  OnTheMap
//
//  Created by Christopher Whidden on 6/28/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import UIKit
import MapKit

class SubmitLocationViewController: UIViewController {
    var placemark: CLPlacemark?
    var mapString: String?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var URLTextField: UITextField!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let region = MKCoordinateRegionMake(placemark!.location.coordinate, MKCoordinateSpanMake(0.5, 0.5))
        mapView.region = region
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitTapped(sender: AnyObject) {
        let url = NSURL(string: URLTextField.text)
        if url == nil || URLTextField.text == "" {
            let alert = UIAlertView(title: "Enter a valid URL", message: "The above text does not contain a valid url.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        let key = getUserKey()!
        var firstName: String = ""
        var lastName: String = ""
        let udacityClient = UdacityClient.sharedInstance
        udacityClient.getDataForUser(key, completionHandler: { data, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertView(title: "Post failed", message: "Could not retrieve data for the currently logged in user", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
            let userData = data["user"] as! [String:AnyObject]
            firstName = userData["first_name"] as! String
            lastName = userData["last_name"] as! String
            let parseClient = ParseClient.sharedInstance
            parseClient.postStudentLocation(key, firstName: firstName, lastName: lastName, mapString: self.mapString!, location: self.placemark!.location.coordinate, userLink: self.URLTextField.text, completionHandler: { success, error in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        let alert = UIAlertView(title: "Posting failed", message: "Could not submit the location at this time", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
        })
    }
    
    func getUserKey() -> Int? {
        switch appDelegate.currentLogin {
        case .Udacity(let key, let sessionID):
            return key
        default:
            return nil
        }
    }
}