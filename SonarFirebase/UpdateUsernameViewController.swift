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
    
    var friendArray = [String]()
    
    var username = ""
    
    var characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789_")
    
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

        self.loadFriends()
        
        // Do any additional setup after loading the view.
        self.usernameTextField.text = username
        self.usernameTextField.becomeFirstResponder()
        
        self.saveButton.enabled = false
        
        self.usernameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }

    func textFieldDidChange(textField: UITextField) {
        if self.usernameTextField.text == username || self.usernameTextField.text!.characters.count < 2  {
            
            self.saveButton.enabled = false
            
        } else {
            let username = self.usernameTextField.text
            
            let usernameLowercase = username!.lowercaseString
            
            var user = PFQuery(className:"FirebaseUser")
            user.whereKey("username", equalTo: usernameLowercase)
            
//            user.findObjectsInBackgroundWithBlock {
//                (objects: [AnyObject]?, error: NSError?) -> Void in
//                
//                if error == nil {
//                    // The find succeeded.
//                    if objects!.count == 0 {
//                        if ((usernameLowercase.rangeOfCharacterFromSet(self.characterSet.invertedSet, options: [], range: nil)) != nil) {
//                            print("Could not handle special characters")
//                            self.saveButton.enabled = false
//                            self.statusLabel.text = "Username cannot contain special characters"
//                        } else {
//                            self.saveButton.enabled = true
//                            self.statusLabel.text = "Username Available!"
//                        }
//                    } else {
//                        self.statusLabel.text = "Username taken"
//                        self.saveButton.enabled = false
//                    }
//                } else {
//                    // Log details of the failure
//                    print("Error: \(error!) \(error!.userInfo!)")
//                }
//            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFriends() {
        let friendsUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/friends/"
        let friendsRef = Firebase(url: friendsUrl)
        
        friendsRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            let id = snapshot.key as? String
            print(id)
            self.friendArray.append(id!)
            print(self.friendArray)
            
        })
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        
        let usernameLowercase = self.usernameTextField.text!.lowercaseString
        
        let userUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/username/"
        let userRef = Firebase(url: userUrl)
        userRef.setValue(usernameLowercase)
        
        for friend in friendArray{
            let friendUrl = "https://sonarapp.firebaseio.com/users/" + friend + "/friends/" + currentUser + "/username/"
            let friendRef = Firebase(url: friendUrl)
            friendRef.setValue(usernameLowercase)
        }
        
        var user = PFQuery(className:"FirebaseUser")
        user.whereKey("firebaseId", equalTo: currentUser)
        
        user.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                    for object in objects! {
                        object.setObject(usernameLowercase, forKey: "username")
                        object.saveInBackground()
                    }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        let alert = UIAlertController(title: nil, message: "Username Changed!", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelButton = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Okay Pressed", terminator: "")
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

}
