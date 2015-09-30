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
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        ref.unauth()
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
