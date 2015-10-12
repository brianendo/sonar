//
//  EmailViewController.swift
//  
//
//  Created by Brian Endo on 10/7/15.
//
//

import UIKit
import Parse
import Firebase

class EmailViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var bottomSpaceToLayout: NSLayoutConstraint!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var email = ""
    
    func registerForKeyboardNotifications ()-> Void   {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.bottomSpaceToLayout.constant = keyboardFrame.size.height
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.emailTextField.text = email
        self.emailTextField.becomeFirstResponder()
        
        self.saveButton.enabled = false
        
        self.emailTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.passwordTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if self.emailTextField.text == email {
            self.statusLabel.text = ""
            self.saveButton.enabled = false
            
        } else {
            let emailField = self.emailTextField.text
            
            var user = PFQuery(className:"FirebaseUser")
            user.whereKey("email", equalTo: emailField)
            
            user.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    if objects!.count == 0 {
                        self.statusLabel.text = "Email Available!"
                        if count(self.passwordTextField.text) > 0 {
                            self.saveButton.enabled = true
                        }
                    } else {
                        self.statusLabel.text = "Email taken"
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
        
        let ref = Firebase(url: "https://sonarapp.firebaseio.com")
        ref.changeEmailForUser(self.email, password: self.passwordTextField.text,
            toNewEmail: self.emailTextField.text, withCompletionBlock: { error in
                if error != nil {
                    // There was an error processing the request
                    var alert = UIAlertController(title: "Please try again", message: "Wrong password", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    // Email changed successfully
                    let userUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/email/"
                    let userRef = Firebase(url: userUrl)
                    userRef.setValue(self.emailTextField.text)
                    
                    
                    var user = PFQuery(className:"FirebaseUser")
                    user.whereKey("firebaseId", equalTo: currentUser)
                    
                    user.findObjectsInBackgroundWithBlock {
                        (objects: [AnyObject]?, error: NSError?) -> Void in
                        
                        if error == nil {
                            // The find succeeded.
                            if let objects = objects as? [PFObject] {
                                for object in objects {
                                    object.setObject(self.emailTextField.text!, forKey: "email")
                                    object.saveInBackground()
                                }
                            }
                        } else {
                            // Log details of the failure
                            println("Error: \(error!) \(error!.userInfo!)")
                        }
                    }
                    let alert = UIAlertController(title: nil, message: "Email Changed!", preferredStyle: UIAlertControllerStyle.ActionSheet)
                    let cancelButton = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                        print("Okay Pressed")
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                    
                    alert.addAction(cancelButton)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
        })
        
            }
    
    

}
