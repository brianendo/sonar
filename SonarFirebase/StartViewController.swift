//
//  StartViewController.swift
//  
//
//  Created by Brian Endo on 8/24/15.
//
//

import UIKit
import Firebase

class StartViewController: UIViewController {

    let ref = Firebase(url: "https://sonarapp.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                println(authData)
                self.performSegueWithIdentifier("segueToPulse", sender: self)
            } else {
                // No user is signed in
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logInButtonPressed(sender: UIButton) {
    }
    
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
    }
    

}
