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

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    
    var profileImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        var newUrl = "https://sonarapp.firebaseio.com/images/" + currentUser
//        var newRef = Firebase(url: newUrl)
//        newRef.observeEventType(.Value, withBlock: { snapshot in
//            var baseString = snapshot.value as! String
//            var decodedData = NSData(base64EncodedString: baseString, options: NSDataBase64DecodingOptions())
//            var decodedImage = UIImage(data: decodedData!)
//            self.imageView.image = decodedImage
//        })
        self.download()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Download profile image from S3
    func download() {
        let downloadingFilePath1 = NSTemporaryDirectory().stringByAppendingPathComponent("temp-download")
        let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        
        let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        readRequest1.bucket = S3BucketName
        readRequest1.key =  currentUser
        readRequest1.downloadingFileURL = downloadingFileURL1
        
        let task = transferManager.download(readRequest1)
        task.continueWithBlock { (task) -> AnyObject! in
            println(task.error)
            if task.error != nil {
            } else {
                dispatch_async(dispatch_get_main_queue()
                    , { () -> Void in
                        self.imageView.image = UIImage(contentsOfFile: downloadingFilePath1)
                        
                })
                println("Fetched image")
            }
            return nil
        }
        
    }
    

    
    // Open Camera or Upload image from Camera Roll
    @IBAction func changePictureButtonPressed(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            // checking to see if the camera is available
            var cameraController = UIImagePickerController()
            //if it is then create an instance of UIImagePickerController
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            // set the cameraController to the Camera
            
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            //pass in the image as data
            
            cameraController.mediaTypes = mediaTypes
            cameraController.allowsEditing = false
            
            self.presentViewController(cameraController, animated: true, completion: nil)
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            
            var photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = false
            
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        } else {
            var alertController = UIAlertController(title: "Alert", message: "Your device does not support the camera or photo library", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
    }
    

    // UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Save image into base64 String and save in Firebase
//        let imageData = UIImageJPEGRepresentation(image, 1.0)
//        let thumbNailData = UIImageJPEGRepresentation(image, 0.1)
        
//        var base64 = imageData.base64EncodedStringWithOptions(.allZeros)
        
        
        // Save image in S3 with the userID
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let testFileURL1 = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("temp"))
        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        
        let data = UIImageJPEGRepresentation(image, 0.01)
        data.writeToURL(testFileURL1!, atomically: true)
        uploadRequest1.bucket = S3BucketName
        uploadRequest1.key =  currentUser
        uploadRequest1.body = testFileURL1
        
        
        let task = transferManager.upload(uploadRequest1)
        task.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                println("Error: \(task.error)")
            } else {
                self.download()
                println("Upload successful")
            }
            return nil
        }
        
        // Save image in Firebase database
//        let url = "https://sonarapp.firebaseio.com/images"
//        let imageRef = Firebase(url: url)
//        imageRef.childByAppendingPath(currentUser).setValue(base64)
        
//        var newUrl = "https://sonarapp.firebaseio.com/images/" + currentUser
//        var newRef = Firebase(url: newUrl)
//        newRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
//            var baseString = snapshot.value as! String
//            var decodedData = NSData(base64EncodedString: baseString, options: NSDataBase64DecodingOptions())
//            var decodedImage = UIImage(data: decodedData!)
//            self.imageView.image = decodedImage
//        })
        
//        self.imageView.image = UIImage(data: imageData)
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    
    @IBAction func logOutButtonPressed(sender: UIButton) {
        
        ref.unauth()
        
        let login = UIStoryboard(name: "LogIn", bundle: nil)
        let loginVC = login.instantiateInitialViewController() as! UIViewController
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    
    @IBAction func addPersonButtonPressed(sender: UIButton) {
    }
    
    
    
    
    
}
