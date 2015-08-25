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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                                println(authData.uid)
                                
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
