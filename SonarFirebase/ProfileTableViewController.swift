//
//  ProfileTableViewController.swift
//  Sonar
//
//  Created by Brian Endo on 10/1/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import AWSS3
import Firebase
import MobileCoreServices

class ProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imageCache = NSCache()
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var addedMeContentView: UIView!
    
    @IBOutlet weak var addedMeLabel: UILabel!
    
    @IBOutlet weak var newFriendLabel: UILabel!
    
    
    var username = ""
    var creatorname = ""
    
    func loadUsername() {
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser
        let userRef = Firebase(url: url)
        
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let name = snapshot.value["name"] as? String
            if snapshot.value["username"] is NSNull {
                self.creatorname = name!
            } else {
                let username = snapshot.value["username"] as? String
                self.username = username!
                self.creatorname = name!
                self.tableView.reloadData()
            }
        })
    }
    
    func readNotifications() {
        let url = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/read/"
        let targetRef = Firebase(url: url)
        
        targetRef.observeEventType(.Value, withBlock: {
            snapshot in
            let read = snapshot.value as? Bool
            if read == false {
                print("Unread")
                self.addedMeContentView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
                self.newFriendLabel.text = "New Friend Request"
            } else {
                print("Read")
                self.addedMeContentView.backgroundColor = UIColor.clearColor()
                self.newFriendLabel.text = ""
            }
            
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        self.readNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "Profile"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.loadUsername()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.profileImageView.frame = CGRectMake(0, 0, 100, 100)
        self.profileImageView.layer.borderWidth=1.0
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
        self.profileImageView.clipsToBounds = true
        self.download()

        self.tableView.separatorColor = UIColor.groupTableViewBackgroundColor()
    }

    func download() {
        
        
        if let image = self.imageCache.objectForKey(currentUser) as? UIImage {
            self.profileImageView.image = image
        } else {
            // 3
            self.profileImageView.image = UIImage(named: "BatPic")
            
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
                            self.profileImageView.image = UIImage(contentsOfFile: downloadingFilePath1)
                            
                    })
                    print("Fetched image", terminator: "")
                }
                return nil
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return creatorname + "  @" + username
        } else {
            return ""
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            print("Selected")
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else if indexPath.section == 2{
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if indexPath.row == 1 {
                ref.unauth()
                
                let login = UIStoryboard(name: "LogIn", bundle: nil)
                let loginVC = login.instantiateInitialViewController()
                self.presentViewController(loginVC!, animated: true, completion: nil)
            } else if indexPath.row == 0 {
                
            }
        }
    }
    
    @IBAction func imageButtonClicked(sender: UIButton) {
        print("Clicked")
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let libButton = UIAlertAction(title: "Select photo from library", style: UIAlertActionStyle.Default) { (alert) -> Void in
            let photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            let mediaTypes:[String] = [kUTTypeImage as String]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = true
            
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
                cameraController.allowsEditing = true
                
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
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        let squareImage = RBSquareImage(editedImage)
        
        // Save image in S3 with the userID
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let testFileURL1 = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp"))
        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        
        let data = UIImageJPEGRepresentation(squareImage, 0.01)
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

    func RBSquareImage(image: UIImage) -> UIImage {
        var originalWidth  = image.size.width
        var originalHeight = image.size.height
        
        var edge: CGFloat
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }
        
        var posX = (originalWidth  - edge) / 2.0
        var posY = (originalHeight - edge) / 2.0
        
        var cropSquare = CGRectMake(posX, posY, edge, edge)
        
        var imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    }
    
    

}
