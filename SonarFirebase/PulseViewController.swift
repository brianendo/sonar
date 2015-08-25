//
//  PulseViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 8/24/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase

class PulseViewController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                println(authData)
            } else {
                // No user is signed in
                let login = UIStoryboard(name: "LogIn", bundle: nil)
                let loginVC = login.instantiateInitialViewController() as! UIViewController
                self.presentViewController(loginVC, animated: true, completion: nil)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logOutButtonPressed(sender: UIBarButtonItem) {
        
        ref.unauth()
        
        let login = UIStoryboard(name: "LogIn", bundle: nil)
        let loginVC = login.instantiateInitialViewController() as! UIViewController
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    

}
