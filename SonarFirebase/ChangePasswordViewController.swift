//
//  ChangePasswordViewController.swift
//  
//
//  Created by Brian Endo on 10/7/15.
//
//

import UIKit
import Firebase

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var currentPasswordTextField: UITextField!
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    var email = ""
    
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
        
        self.saveButton.enabled = false
        
        self.currentPasswordTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.newPasswordTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if self.currentPasswordTextField.text!.characters.count > 0 && self.newPasswordTextField.text!.characters.count > 0{
            self.saveButton.enabled = true
        } else {
            self.saveButton.enabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        if self.newPasswordTextField.text!.characters.count < 6 {
            var alert = UIAlertController(title: "New password not secure", message: "Make sure it is at least 6 characters", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let ref = Firebase(url: "https://sonarapp.firebaseio.com")
            ref.changePasswordForUser(email, fromOld: self.currentPasswordTextField.text,
                toNew: self.newPasswordTextField.text, withCompletionBlock: { error in
                    if error != nil {
                        // There was an error processing the request
                        var alert = UIAlertController(title: "Current password is incorrect", message: "Please correct it", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        // Password changed successfully
                        let alert = UIAlertController(title: nil, message: "Password Changed!", preferredStyle: UIAlertControllerStyle.ActionSheet)
                        let cancelButton = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                            print("Okay Pressed", terminator: "")
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                        alert.addAction(cancelButton)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
            })
        }
        
    }

    

}
