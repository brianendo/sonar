//
//  PicturesViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 9/8/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit

class PicturesViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        download()
        
        let text = "hey http://www.google.com"
        let types: NSTextCheckingType = .Link
        var error : NSError?
        
        let detector = NSDataDetector(types: types.rawValue, error: &error)
        var matches = detector!.matchesInString(text, options: nil, range: NSMakeRange(0, count(text)))
        
        for match in matches {
            println(match.URL!)
        }
        
    }

    func download() {
        let downloadingFilePath1 = NSTemporaryDirectory().stringByAppendingPathComponent("temp-download")
        let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        
        let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        readRequest1.bucket = S3BucketName
        readRequest1.key =  "Bat.png"
        readRequest1.downloadingFileURL = downloadingFileURL1
        
        let task = transferManager.download(readRequest1)
        task.continueWithBlock { (task) -> AnyObject! in
            println(task.error)
            if task.error != nil {
            } else {
                dispatch_async(dispatch_get_main_queue()
                    , { () -> Void in
                        self.imageView.image = UIImage(contentsOfFile: downloadingFilePath1)
//                        self.imageView.setNeedsDisplay()
//                        self.imageView.reloadInputViews()
                        
                })
                println("Fetched image")
            }
            return nil
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func uploadButtonPressed(sender: UIButton) {
        
        
    }
    
    
}
