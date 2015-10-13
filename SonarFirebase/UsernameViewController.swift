//
//  UsernameViewController.swift
//  Sonar
//
//  Created by Brian Endo on 9/30/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Parse
import Firebase

class UsernameViewController: UIViewController {

    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var usernameStatusLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    @IBOutlet weak var bottomSpacingToLayout: NSLayoutConstraint!
    
    var characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789_")
    
    func registerForKeyboardNotifications ()-> Void   {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.bottomSpacingToLayout.constant = keyboardFrame.size.height
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.nextButton.enabled = false
        self.usernameTextField.becomeFirstResponder()
        
        self.usernameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if count(self.usernameTextField.text) > 2  {
            
            let username = self.usernameTextField.text
            
            let usernameLowercase = username.lowercaseString
            
            var user = PFQuery(className:"FirebaseUser")
            user.whereKey("username", equalTo: usernameLowercase)
            
            user.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    if objects!.count == 0 {
                        
                        if ((usernameLowercase.rangeOfCharacterFromSet(self.characterSet.invertedSet, options: nil, range: nil)) != nil) {
                            println("Could not handle special characters")
                            self.nextButton.enabled = false
                            self.usernameStatusLabel.text = "Username cannot contain special characters"
                        } else {
                            self.nextButton.enabled = true
                            self.usernameStatusLabel.text = "Username Available!"
                        }
                    } else {
                        self.usernameStatusLabel.text = "Username taken"
                        self.nextButton.enabled = false
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        } else {
            self.nextButton.enabled = false
            self.usernameStatusLabel.text = ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func nextButtonPressed(sender: UIButton) {
        let username = self.usernameTextField.text
        let usernameLowercase = username.lowercaseString
        
        let userUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/username/"
        let userRef = Firebase(url: userUrl)
        userRef.setValue(usernameLowercase)
        
        
        var user = PFQuery(className:"FirebaseUser")
        user.whereKey("firebaseId", equalTo: currentUser)
        
        user.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        object.setObject(usernameLowercase, forKey: "username")
                        object.saveInBackground()
                    }
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
        
    }
    

}
