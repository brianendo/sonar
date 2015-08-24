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
    
    let ref = Firebase(url: "https://sonarapp.firebaseio.com/")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logOutButtonPressed(sender: UIBarButtonItem) {
        ref.unauth()
        self.performSegueWithIdentifier("segueToStart", sender: self)
    }
    

}
