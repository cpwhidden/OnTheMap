//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by Christopher Whidden on 6/28/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import UIKit
import MapKit

class PostLocationViewController: UIViewController, UITextFieldDelegate {
    
    var foundPlacemark: CLPlacemark?
    let geocoder = CLGeocoder()
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var geocodeActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextField.delegate = self
        geocodeActivityIndicator.hidden = true
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text != "" {
            findOnMapButton.enabled = true
        } else {
            findOnMapButton.enabled = false
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        if newText == "" {
            findOnMapButton.enabled = false
        } else {
            findOnMapButton.enabled = true
        }
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func findOnMapTapped(sender: AnyObject) {
        geocodeActivityIndicator.hidden = false
        geocodeActivityIndicator.startAnimating()
        
        geocoder.geocodeAddressString(locationTextField.text, completionHandler: { objects, error in
            if error == nil {
                if objects.count > 0 {
                    let placemark = objects[0] as! CLPlacemark
                    self.foundPlacemark = placemark
                    dispatch_async(dispatch_get_main_queue()) {
                        self.geocodeActivityIndicator.hidden = true
                        self.geocodeActivityIndicator.stopAnimating()
                        self.performSegueWithIdentifier("confirmLocation", sender: self)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.geocodeActivityIndicator.hidden = true
                        self.geocodeActivityIndicator.stopAnimating()
                        let alert = UIAlertView(title: "Could not find results", message: "Could not find this location on the map.  Please try another location.", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.geocodeActivityIndicator.hidden = true
                    self.geocodeActivityIndicator.stopAnimating()
                    let alert = UIAlertView(title: "Unable to find on map", message: "Unable to use mapping service to find the location at this time", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
        })
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        cancel()
    }
    
    func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let id = segue.identifier!
        switch id {
        case "confirmLocation":
            let nav = segue.destinationViewController as! UINavigationController
            let vc = nav.topViewController as! SubmitLocationViewController
            vc.placemark = foundPlacemark
            vc.mapString = locationTextField.text
        default:
            break
        }
    }
}
