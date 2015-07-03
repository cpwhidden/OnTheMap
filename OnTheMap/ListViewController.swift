//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Christopher Whidden on 6/28/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var studentLocations: [StudentLocation] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        
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
                    self.studentLocations = studentLocations!
                    self.tableView.reloadData()
                }
            }
        }
        
        
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
                    let alert = UIAlertView(title: "Logout Failed", message: "Failed to log out of Udacity", delegate: nil, cancelButtonTitle: nil)
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentLocation", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = "\(studentLocations[indexPath.row].firstName) \(studentLocations[indexPath.row].lastName)"
        cell.detailTextLabel?.text = studentLocations[indexPath.row].mediaURL
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = studentLocations[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: studentLocation.mediaURL)!)
    }
    
    
}
