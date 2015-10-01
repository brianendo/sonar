//
//  VerificationViewController.swift
//  Sonar
//
//  Created by Brian Endo on 9/30/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Parse
import Firebase

extension String {
    func insert(string:String,ind:Int) -> String {
        return  prefix(self,ind) + string + suffix(self,count(self)-ind)
    }
}

class VerificationViewController: UIViewController {

    
    @IBOutlet weak var verificationTextField: UITextField!
    
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    @IBOutlet weak var bottomSpaceToLayout: NSLayoutConstraint!
    
    @IBOutlet weak var topLabel: UILabel!
    
    
    var phoneNumber = ""
    
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

        var number = phoneNumber
//        number.insert("(", ind: 0)
//        number.insert(")", ind: 4)
//        number.insert("-", ind: 9)
        
        let formattedNumber = number
        
        self.topLabel.text = "The code was sent to +1 \(formattedNumber)"
        
        // Do any additional setup after loading the view.
        self.verificationTextField.becomeFirstResponder()
        
        self.verificationTextField.layer.borderWidth = 0.5
        self.verificationTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        self.verificationTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if count(self.verificationTextField.text) > 0 {
            self.nextButton.enabled = true
        }
        else {
            self.nextButton.enabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func nextButtonPressed(sender: UIButton) {
        
        PFCloud.callFunctionInBackground("verifyPhoneNumber", withParameters: ["phoneVerificationCode": self.verificationTextField.text, "phoneNumber": phoneNumber, "firebaseId": currentUser]) { (objects:AnyObject?, error:NSError?) -> Void in
            if error == nil {
                let userUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/phoneNumber/"
                let userRef = Firebase(url: userUrl)
                userRef.setValue(self.phoneNumber)
                println("Made It")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainVC = storyboard.instantiateInitialViewController() as! UIViewController
                self.presentViewController(mainVC, animated: true, completion: nil)

            } else {
                var alert = UIAlertController(title: "Wrong verification code", message: "Please retry", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func resendCodeButtonPressed(sender: UIButton) {
        let alertController = UIAlertController(title: "Code not working?", message: "Please input your phone number with your country code:", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                // store your data
                PFCloud.callFunctionInBackground("sendVerificationCode", withParameters: ["phoneNumber": field.text, "firebaseId": currentUser])
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Phone Number"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    

}
