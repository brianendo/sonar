//
//  PhoneNumberViewController.swift
//  Sonar
//
//  Created by Brian Endo on 9/30/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Parse

class PhoneNumberViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    @IBOutlet weak var bottomSpaceToLayout: NSLayoutConstraint!
    
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
        self.phoneNumberTextField.becomeFirstResponder()
        self.nextButton.enabled = false
        
        self.phoneNumberTextField.layer.borderWidth = 0.5
        self.phoneNumberTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        self.phoneNumberTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if count(self.phoneNumberTextField.text) == 10 {
            self.nextButton.enabled = true
//            var number = NSMutableString(contentsOfFile: self.phoneNumberTextField.text)
//            number.insertString("(", atIndex: 0)
//            number.insertString(")", atIndex: 4)
//            number.insertString("-", atIndex: 5)
//            number.insertString("-", atIndex: 9)
//            
//            self.phoneNumberTextField.text = String(number)
        }
        else {
            self.nextButton.enabled = false
        }
    }
    
    override func viewDidLayoutSubviews() {
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showVerification" {
            let number = self.phoneNumberTextField.text
            let verificationVC: VerificationViewController = segue.destinationViewController as! VerificationViewController
            verificationVC.phoneNumber = number
        }
    }
    
    
    @IBAction func nextButtonPressed(sender: UIButton) {
        
        PFCloud.callFunctionInBackground("sendVerificationCode", withParameters: ["phoneNumber": self.phoneNumberTextField.text, "firebaseId": currentUser])
        
        self.performSegueWithIdentifier("showVerification", sender: self)
        
    }


}
