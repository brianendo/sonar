//
//  WebViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 9/9/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    var urlToLoad: NSURL?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        println(urlToLoad!)
//        let requesturl = NSURL(string: url)
        let request = NSURLRequest(URL: urlToLoad!)
        println(request)
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    

}
