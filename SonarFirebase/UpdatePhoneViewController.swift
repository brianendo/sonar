//
//  UpdatePhoneViewController.swift
//  
//
//  Created by Brian Endo on 10/7/15.
//
//

import UIKit
import Parse
import Firebase

class UpdatePhoneViewController: UIViewController {

    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var verifyButton: UIButton!
    
    
    var phoneNumber = ""
    
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
        self.phoneNumberLabel.text = "Your phone number is: \(phoneNumber)"
        self.phoneNumberTextField.becomeFirstResponder()
        
        self.saveButton.enabled = false
        self.verifyButton.enabled = false
        
        self.phoneNumberTextField.addTarget(self, action: "phoneTextFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.verificationCodeTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
    }
    
    func phoneTextFieldDidChange(textField: UITextField) {
        if self.phoneNumberTextField.text!.characters.count == 10 {
            self.verifyButton.enabled = true
        } else {
            self.verifyButton.enabled = false
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        if self.verificationCodeTextField.text!.characters.count > 0 {
            self.saveButton.enabled = true
        } else {
            self.saveButton.enabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func verifyButtonPressed(sender: UIButton) {
        PFCloud.callFunctionInBackground("sendVerificationCode", withParameters: ["phoneNumber": self.phoneNumberTextField.text!, "firebaseId": currentUser])
    }
    
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        PFCloud.callFunctionInBackground("verifyPhoneNumber", withParameters: ["phoneVerificationCode": self.verificationCodeTextField.text!, "phoneNumber": self.phoneNumberTextField.text!, "firebaseId": currentUser]) { (objects:AnyObject?, error:NSError?) -> Void in
            if error == nil {
                let userUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/phoneNumber/"
                let userRef = Firebase(url: userUrl)
                userRef.setValue(self.phoneNumberTextField.text)
                print("Made It")
                let alert = UIAlertController(title: nil, message: "Phone Number Changed!", preferredStyle: UIAlertControllerStyle.ActionSheet)
                let cancelButton = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                    print("Okay Pressed", terminator: "")
                    self.navigationController?.popViewControllerAnimated(true)
                }
                alert.addAction(cancelButton)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                var alert = UIAlertController(title: "Wrong verification code", message: "Please retry", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    
    
    
    

}
