//
//  SignUpViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 8/24/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet var signUpView: UIView!
    
    
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
        self.navigationController?.navigationBarHidden = false
        
        // Add a tap gesture recognizer to the table view
//        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "viewTapped")
//        self.signUpView.addGestureRecognizer(tapGesture)
        
        self.nameTextField.becomeFirstResponder()
        
        self.nextButton.enabled = false
        
        self.nameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        self.emailTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        self.passwordTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if self.emailTextField.text != "" &&  self.passwordTextField.text != "" && self.nameTextField.text != "" {
            self.nextButton.enabled = true
        } else if self.emailTextField.text == "" || self.passwordTextField.text == "" || self.nameTextField.text == "" {
            self.nextButton.enabled = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRect(x: 0, y: self.emailTextField.frame.size.height - width, width:  self.emailTextField.frame.size.width, height: self.emailTextField.frame.size.height)
        
        border.borderWidth = width
        self.emailTextField.layer.addSublayer(border)
        self.emailTextField.layer.masksToBounds = true
        
        let passwordBorder = CALayer()
        let passwordWidth = CGFloat(0.5)
        passwordBorder.borderColor = UIColor.lightGrayColor().CGColor
        passwordBorder.frame = CGRect(x: 0, y: self.passwordTextField.frame.size.height - passwordWidth, width:  self.passwordTextField.frame.size.width, height: self.emailTextField.frame.size.height)
        
        passwordBorder.borderWidth = passwordWidth
        self.passwordTextField.layer.addSublayer(passwordBorder)
        self.passwordTextField.layer.masksToBounds = true
        
        let nameBorder = CALayer()
        let nameWidth = CGFloat(0.5)
        nameBorder.borderColor = UIColor.lightGrayColor().CGColor
        nameBorder.frame = CGRect(x: 0, y: self.nameTextField.frame.size.height - nameWidth, width:  self.nameTextField.frame.size.width, height: self.nameTextField.frame.size.height)
        
        nameBorder.borderWidth = nameWidth
        self.nameTextField.layer.addSublayer(nameBorder)
        self.nameTextField.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    func viewTapped() {
//        
//        // Force the textfield to end editing
//        self.emailTextField.endEditing(true)
//        self.passwordTextField.endEditing(true)
//        self.nameTextField.endEditing(true)
//    }
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
        if count(self.passwordTextField.text) < 8 {
            var alert = UIAlertController(title: "Password not secure", message: "Make sure it is at least 8 characters", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
        
        ref.createUser(emailTextField.text, password: passwordTextField.text,
            withValueCompletionBlock: { error, result in
                if error != nil {
                    // There was an error creating the account
                    var alert = UIAlertController(title: "Email used", message: "Please use another email address", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let uid = result["uid"] as? String
                    print("Successfully created user account with uid: \(uid)")
                    
                    ref.authUser(self.emailTextField.text, password: self.passwordTextField.text,
                        withCompletionBlock: { error, authData in
                            if error != nil {
                                // There was an error logging in to this account
                            } else {
                                // We are now logged in
                                
                                let newUser = [
                                    "name": self.nameTextField.text!
                                ]
                                
                                ref.childByAppendingPath("users").childByAppendingPath(authData.uid).setValue(newUser)
                                
//                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                                let mainVC = storyboard.instantiateInitialViewController() as! UIViewController
//                                self.presentViewController(mainVC, animated: true, completion: nil)
                            }
                    })

                }
        })
        }
    }


}
