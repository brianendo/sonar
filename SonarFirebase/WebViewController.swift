//
//  WebViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 9/9/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//



import UIKit

class WebViewController: UIViewController {
    
    
    // Accessed from RadarVC
    var urlToLoad: NSURL?
    
    var isPresented = true
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Set up webView, conver NSURL to request
        let request = NSURLRequest(URL: urlToLoad!)
        webView.loadRequest(request)
    }

//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.All
//    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        isPresented = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    

}
