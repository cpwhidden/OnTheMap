//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Christopher Whidden on 6/28/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        

        let pinButton = UIBarButtonItem(image: UIImage(named: "Pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "pinButtonTapped")
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshTapped:")
        self.navigationItem.rightBarButtonItems = [refreshButton, pinButton]
        
        refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    
    func pinButtonTapped() {
        self.performSegueWithIdentifier("findOnMap", sender: self)
    }
    
    
    @IBAction func refreshTapped(sender: AnyObject) {
        refresh()
    }
    
    func refresh() {
        var userID: String
        
        let client = ParseClient.sharedInstance
        client.getStudentLocations { studentLocations, error in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                self.mapView.removeAnnotations(self.mapView.annotations)
                    for studentLocation in studentLocations! {
                        let coordinate = CLLocationCoordinate2D(latitude: studentLocation.latitude, longitude: studentLocation.longitude)
                        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
                        annotation.subtitle = "\(studentLocation.mediaURL)"
                        self.mapView.addAnnotation(annotation)
                    }
                }
            }
        }
        
        
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let view =  MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        view.animatesDrop = true
        view.canShowCallout = true
        let button = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
        view.rightCalloutAccessoryView = button
        return view
    }   
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        let urlString = view.annotation.subtitle!
        let url = NSURL(string: urlString)!
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func logoutTapped(sender: AnyObject) {
        logout()
    }
    
    func logout() {
        switch appDelegate.currentLogin {
        case .Udacity(let userID):
            let client = UdacityClient.sharedInstance
            client.logoutOfUdacity() { success in
                if !success {
                    let alert = UIAlertView(title: "Logout Failed", message: "Could not log out of Udacity", delegate: nil, cancelButtonTitle: nil)
                    alert.show()
                } else {
                    self.appDelegate.currentLogin = .None
                    self.tabBarController!.dismissViewControllerAnimated(true, completion: nil)
                }
            }

        case .None:
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}