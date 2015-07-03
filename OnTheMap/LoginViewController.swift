//
//  ViewController.swift
//  OnTheMap
//
//  Created by Christopher Whidden on 6/28/15.
//  Copyright (c) 2015 SelfEdge Software. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let loginCompleteSegueID = "loginComplete"
    
    override func viewDidAppear(animated: Bool) {
        usernameTextField.text = ""
        passwordTextField.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginToUdacity(sender: AnyObject) {
        
        let client = UdacityClient.sharedInstance
        client.loginToUdacity(usernameTextField.text, password: passwordTextField.text) { json, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertView(title: "Login Failed", message: "Connection to Udacity failed", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            } else if let session = json["session"] as? [String:AnyObject],
                    let sessionID = session["id"] as? String,
                    let account = json["account"] as? [String:AnyObject],
                    let key = account["key"] as? String {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        (UIApplication.sharedApplication().delegate as! AppDelegate).currentLogin = .Udacity(key.toInt()!, sessionID)
                        self.usernameTextField.text = ""
                        self.passwordTextField.text = ""
                        self.performSegueWithIdentifier(self.loginCompleteSegueID, sender: self)
                    }
            } else if let error = json["status"] as? Int where error == 400 {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertView(title: "Login Failed", message: "Username or password incorrect", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertView(title: "Login Failed", message: "Login was unsuccessful", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
        }
    }
    
    @IBAction func signInWithFacebook(sender: AnyObject) {
        
    }

}

