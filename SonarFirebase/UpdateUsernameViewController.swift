//
//  UpdateUsernameViewController.swift
//  
//
//  Created by Brian Endo on 10/7/15.
//
//

import UIKit
import Parse
import Firebase

class UpdateUsernameViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    var username = ""
    
    func registerForKeyboardNotifications ()-> Void   {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.bottomLayoutConstraint.constant = keyboardFrame.size.height
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.usernameTextField.text = username
        self.usernameTextField.becomeFirstResponder()
        
        self.saveButton.enabled = false
        
        self.usernameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }

    func textFieldDidChange(textField: UITextField) {
        if self.usernameTextField.text == username || count(self.usernameTextField.text) < 2  {
            
            self.saveButton.enabled = false
            
        } else {
            let username = self.usernameTextField.text
            
            var user = PFQuery(className:"FirebaseUser")
            user.whereKey("username", equalTo: username)
            
            user.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    if objects!.count == 0 {
                        self.saveButton.enabled = true
                        self.statusLabel.text = "Username Available!"
                    } else {
                        self.statusLabel.text = "Username taken"
                        self.saveButton.enabled = false
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        
        let userUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/username/"
        let userRef = Firebase(url: userUrl)
        userRef.setValue(self.usernameTextField.text)
        
        
        var user = PFQuery(className:"FirebaseUser")
        user.whereKey("firebaseId", equalTo: currentUser)
        
        user.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        object.setObject(self.usernameTextField.text!, forKey: "username")
                        object.saveInBackground()
                    }
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
        let alert = UIAlertController(title: nil, message: "Username Changed!", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelButton = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Okay Pressed")
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

}
