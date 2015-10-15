//
//  ProfileViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 9/4/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import MobileCoreServices
import MapKit
import Firebase
import AWSS3
import Parse

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imageCache = NSCache()
    
    @IBOutlet weak var imageView: UIImageView!
    
    var profileImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageView.frame = CGRectMake(0, 0, 100, 100)
        self.imageView.layer.borderWidth=1.0
        self.imageView.layer.masksToBounds = false
        self.imageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.imageView.layer.cornerRadius = 13
        self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2
        self.imageView.clipsToBounds = true
        self.download()
//        self.queryImageFromParse()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Download profile image from S3
    func download() {
        
        
        if let image = self.imageCache.objectForKey(currentUser) as? UIImage {
            self.imageView.image = image
        } else {
            // 3
            self.imageView.image = nil
            
            // 4
            let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
            let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            
            
            let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
            readRequest1.bucket = S3BucketName
            readRequest1.key =  currentUser
            readRequest1.downloadingFileURL = downloadingFileURL1
            
            let task = transferManager.download(readRequest1)
            task.continueWithBlock { (task) -> AnyObject! in
                if task.error != nil {
                    print(task.error, terminator: "")
                } else {
                    dispatch_async(dispatch_get_main_queue()
                        , { () -> Void in
                            let image = UIImage(contentsOfFile: downloadingFilePath1)
                            
                            self.imageCache.setObject(image!, forKey: currentUser)
                            self.imageView.image = UIImage(contentsOfFile: downloadingFilePath1)
                            
                    })
                    print("Fetched image", terminator: "")
                }
                return nil
            }
            
        }
        
//        let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
//        let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
//        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
//        
//        
//        let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
//        readRequest1.bucket = S3BucketName
//        readRequest1.key =  currentUser
//        readRequest1.downloadingFileURL = downloadingFileURL1
//        
//        let task = transferManager.download(readRequest1)
//        task.continueWithBlock { (task) -> AnyObject! in
//            if task.error != nil {
//                print(task.error)
//            } else {
//                dispatch_async(dispatch_get_main_queue()
//                    , { () -> Void in
//                        
//                        self.imageView.image = UIImage(contentsOfFile: downloadingFilePath1)
//                        
//                })
//                print("Fetched image")
//            }
//            return nil
//        }
        
    }
    
    func queryImageFromParse() {
        var query = PFQuery(className: "profilePicture")
        query.whereKey("userID", equalTo: currentUser)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                    for object in objects! {
                        let userImageFile = object.objectForKey("profilePicture") as! PFFile
                        userImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                            if error == nil {
                                if let imageData = imageData {
                                    self.imageView.image = UIImage(data: imageData)
                                }
                            }
                        })
                    }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    

    
    // Open Camera or Upload image from Camera Roll
    @IBAction func changePictureButtonPressed(sender: UIButton) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let libButton = UIAlertAction(title: "Select photo from library", style: UIAlertActionStyle.Default) { (alert) -> Void in
            let photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            let mediaTypes:[String] = [kUTTypeImage as String]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = false
            
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        }
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            let cameraButton = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.Default) { (alert) -> Void in
                print("Take Photo", terminator: "")
                let cameraController = UIImagePickerController()
                //if it is then create an instance of UIImagePickerController
                cameraController.delegate = self
                cameraController.sourceType = UIImagePickerControllerSourceType.Camera
                
                let mediaTypes:[String] = [kUTTypeImage as String]
                //pass in the image as data
                
                cameraController.mediaTypes = mediaTypes
                cameraController.allowsEditing = false
                
                self.presentViewController(cameraController, animated: true, completion: nil)
                
            }
            alert.addAction(cameraButton)
        } else {
            print("Camera not available", terminator: "")
            
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Cancel Pressed", terminator: "")
        }
        
        alert.addAction(libButton)
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    

    // UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Save image in S3 with the userID
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let testFileURL1 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        
        let data = UIImageJPEGRepresentation(image, 0.01)
        data!.writeToURL(testFileURL1, atomically: true)
        uploadRequest1.bucket = S3BucketName
        uploadRequest1.key =  currentUser
        uploadRequest1.body = testFileURL1
        
        
        let task = transferManager.upload(uploadRequest1)
        task.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                print("Error: \(task.error)", terminator: "")
            } else {
                self.download()
                print("Upload successful", terminator: "")
            }
            return nil
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    
    @IBAction func logOutButtonPressed(sender: UIButton) {
        
        ref.unauth()
        
        let login = UIStoryboard(name: "LogIn", bundle: nil)
        let loginVC = login.instantiateInitialViewController()
        self.presentViewController(loginVC!, animated: true, completion: nil)
    }
    
    
    @IBAction func addPersonButtonPressed(sender: UIButton) {
    }
    
    
    
    
    
}
