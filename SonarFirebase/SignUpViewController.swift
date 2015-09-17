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
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet var signUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = false
        // Add a tap gesture recognizer to the table view
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "viewTapped")
        self.signUpView.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewTapped() {
        
        // Force the textfield to end editing
        self.emailTextField.endEditing(true)
        self.passwordTextField.endEditing(true)
        self.firstNameTextField.endEditing(true)
        self.lastNameTextField.endEditing(true)
    }
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
        ref.createUser(emailTextField.text, password: passwordTextField.text,
            withValueCompletionBlock: { error, result in
                if error != nil {
                    // There was an error creating the account
                } else {
                    let uid = result["uid"] as? String
                    println("Successfully created user account with uid: \(uid)")
                    
                    ref.authUser(self.emailTextField.text, password: self.passwordTextField.text,
                        withCompletionBlock: { error, authData in
                            if error != nil {
                                // There was an error logging in to this account
                            } else {
                                // We are now logged in
                                
                                let newUser = [
                                    "firstname": self.firstNameTextField.text,
                                    "lastname": self.lastNameTextField.text
                                ]
                                
                                ref.childByAppendingPath("users").childByAppendingPath(authData.uid).setValue(newUser)
                                
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let mainVC = storyboard.instantiateInitialViewController() as! UIViewController
                                self.presentViewController(mainVC, animated: true, completion: nil)
                            }
                    })

                }
        })
    }


}
