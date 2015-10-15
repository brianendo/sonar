//
//  UpdateNameViewController.swift
//  
//
//  Created by Brian Endo on 10/7/15.
//
//

import UIKit
import Parse
import Firebase

class UpdateNameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var name = ""
    
    var friendArray = [String]()
    
    func registerForKeyboardNotifications ()-> Void   {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        self.bottomLayoutConstraint.constant = keyboardFrame.size.height
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
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.loadFriends()
        
        self.nameTextField.text = name
        self.nameTextField.becomeFirstResponder()
        
        self.saveButton.enabled = false
        
        self.nameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidChange(textField: UITextField) {
        if (self.nameTextField.text == name || self.nameTextField.text!.characters.count == 0)  {
            
            self.saveButton.enabled = false
            
        } else {
            self.saveButton.enabled = true
            
        }
    }

    
    @IBAction func saveButtonPressed(sender: UIButton) {
        let userUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/name/"
        let userRef = Firebase(url: userUrl)
        userRef.setValue(self.nameTextField.text)
        
//        for friend in friendArray{
//            let friendUrl = "https://sonarapp.firebaseio.com/users/" + friend + "/friends/" + currentUser + "/name/"
//            let friendRef = Firebase(url: friendUrl)
//            friendRef.setValue(self.nameTextField.text)
//        }
        
        var user = PFQuery(className:"FirebaseUser")
        user.whereKey("firebaseId", equalTo: currentUser)
        
        user.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                    for object in objects! {
                        object.setObject(self.nameTextField.text!, forKey: "name")
                        object.saveInBackground()
                    }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        let alert = UIAlertController(title: nil, message: "Name Changed!", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelButton = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Okay Pressed", terminator: "")
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}
