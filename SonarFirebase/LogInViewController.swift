//
//  LogInViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 8/24/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase
import Parse

class LogInViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet var logInView: UIView!
    
    @IBOutlet weak var bottomSpaceToLayout: NSLayoutConstraint!
    
    @IBOutlet weak var logInButton: UIButton!
    
    
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
        
        self.emailTextField.becomeFirstResponder()
        self.logInButton.enabled = false
        
        self.emailTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.passwordTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if self.emailTextField.text != "" &&  self.passwordTextField.text != "" {
            self.logInButton.enabled = true
        } else if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            self.logInButton.enabled = false
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logInButtonPressed(sender: UIButton) {
        let email = emailTextField.text
        let emailLowercase = email.lowercaseString
        
        if email.lowercaseString.rangeOfString("@") == nil {
            var user = PFQuery(className:"FirebaseUser")
            user.whereKey("username", equalTo: emailLowercase)
            
            user.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    if objects!.count == 0 {
                        var alert = UIAlertController(title: "Please try again", message: "Username does not exist", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        if let objects = objects as? [PFObject] {
                            for object in objects {
                                let email = object.objectForKey("email") as! String
                                ref.authUser(email, password: self.passwordTextField.text,
                                    withCompletionBlock: { error, authData in
                                        if error != nil {
                                            // There was an error logging in to this account
                                            var alert = UIAlertController(title: "Please try again", message: "Username/Email and password do not match", preferredStyle: UIAlertControllerStyle.Alert)
                                            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default, handler: nil))
                                            self.presentViewController(alert, animated: true, completion: nil)
                                        } else {
                                            // We are now logged in
                                            print(authData.uid)
                                            
                                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                            let mainVC = storyboard.instantiateInitialViewController() as! UIViewController
                                            self.presentViewController(mainVC, animated: true, completion: nil)
                                        }
                                })
                            }
                        }
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        } else {
            ref.authUser(emailLowercase, password: passwordTextField.text,
                withCompletionBlock: { error, authData in
                    if error != nil {
                        // There was an error logging in to this account
                        var alert = UIAlertController(title: "Please try again", message: "Username/Email and password do not match", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        // We are now logged in
                        print(authData.uid)
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainVC = storyboard.instantiateInitialViewController() as! UIViewController
                        self.presentViewController(mainVC, animated: true, completion: nil)
                    }
            })
        }
        
//        ref.authUser(emailLowercase, password: passwordTextField.text,
//            withCompletionBlock: { error, authData in
//                if error != nil {
//                    // There was an error logging in to this account
//                    var alert = UIAlertController(title: "Please try again", message: "Username/Email and password do not match", preferredStyle: UIAlertControllerStyle.Alert)
//                    alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default, handler: nil))
//                    self.presentViewController(alert, animated: true, completion: nil)
//                } else {
//                    // We are now logged in
//                    print(authData.uid)
//                    
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let mainVC = storyboard.instantiateInitialViewController() as! UIViewController
//                    self.presentViewController(mainVC, animated: true, completion: nil)
//                }
//        })
    }
    
    @IBAction func forgotPasswordButtonPressed(sender: UIButton) {
        
        let alertController = UIAlertController(title: "Forgot password?", message: "Please input your email:", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                // store your data
                let email = field.text
                let emailLowercase = email.lowercaseString
                ref.resetPasswordForUser(emailLowercase) { (err) -> Void in
                    if err != nil{
                        println("Didn't work")
                    } else {
                        println("Worked")
                    }
                }
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Email"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    

}
