//
//  PicturesViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 9/8/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import AWSS3

class PicturesViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        download()
        
        let text = "hey http://www.google.com"
        let types: NSTextCheckingType = .Link
        var error : NSError?
        
//        let detector: NSDataDetector?
//        do {
//            detector = try NSDataDetector(types: types.rawValue)
//        } catch let error1 as NSError {
//            error = error1
//            detector = nil
//        }
//        let matches = detector!.matchesInString(text, options: [], range: NSMakeRange(0, text.characters.count))
//        
//        for match in matches {
//            print(match.URL!)
//        }
        
    }

    func download() {
        let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
        let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        readRequest1.bucket = S3BucketName
        readRequest1.key =  "Bat.png"
        readRequest1.downloadingFileURL = downloadingFileURL1
        
        let task = transferManager.download(readRequest1)
        task.continueWithBlock { (task) -> AnyObject! in
            print(task.error)
            if task.error != nil {
            } else {
                dispatch_async(dispatch_get_main_queue()
                    , { () -> Void in
                        self.imageView.image = UIImage(contentsOfFile: downloadingFilePath1)
                })
                print("Fetched image")
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
