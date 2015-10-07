//
//  TargetListViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 8/26/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase
import AWSS3


class TargetListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    var friendsArray = [String]()
    var idArray = [String]()
    
    func loadTargetData() {
        self.friendsArray.removeAll(keepCapacity: true)
        
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/friends/"
        let targetRef = Firebase(url: url)
        
        
        targetRef.queryOrderedByChild("name").observeEventType(.ChildAdded, withBlock: {
            snapshot in
            print(snapshot.key)
            let id = snapshot.key as? String
            let nameUrl = "https://sonarapp.firebaseio.com/users/" + snapshot.key
            let nameRef = Firebase(url: nameUrl)
            nameRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                // do some stuff once
                if let name = snapshot.value["name"] as? String {
                        self.friendsArray.append(name)
                        print(name)
                        self.idArray.append(id!)
                        self.tableView.reloadData()
                }
                
                
            })
        })
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        self.title = "Friends List"
        
        self.loadTargetData()
    }
    
    override func viewDidAppear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TargetListTableViewCell = tableView.dequeueReusableCellWithIdentifier("targetCell", forIndexPath: indexPath) as! TargetListTableViewCell
        
        let target: (AnyObject) = friendsArray[indexPath.row]
        cell.nameLabel.text = target as? String
        
        let id = idArray[indexPath.row]
        
        cell.profileImageView.image = UIImage(named: "Placeholder.png")
        if let cachedImageResult = imageCache[id] {
            println("pull from cache")
            cell.profileImageView.image = UIImage(data: cachedImageResult!)
        } else {
            // 3
            cell.profileImageView.image = UIImage(named: "BatPic")
            
            // 4
            let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
            let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            
            
            let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
            readRequest1.bucket = S3BucketName
            readRequest1.key =  id
            readRequest1.downloadingFileURL = downloadingFileURL1
            
            let task = transferManager.download(readRequest1)
            task.continueWithBlock { (task) -> AnyObject! in
                if task.error != nil {
                    print(task.error)
                } else {
                    let image = UIImage(contentsOfFile: downloadingFilePath1)
                    let imageData = UIImageJPEGRepresentation(image, 1.0)
                    imageCache[id] = imageData
                    dispatch_async(dispatch_get_main_queue()
                        , { () -> Void in
                            
                            cell.profileImageView.image = UIImage(contentsOfFile: downloadingFilePath1)
                            cell.setNeedsLayout()
                            
                    })
                    println("Fetched image")
                }
                return nil
            }
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendsArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! TargetListTableViewCell
        let name = friendsArray[indexPath.row]
        let id = idArray[indexPath.row]
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let libButton = UIAlertAction(title: "Unfriend \(name)", style: UIAlertActionStyle.Default) { (alert) -> Void in
            let userUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/added/" + id
            let userActivityRef = Firebase(url: userUrl)
            userActivityRef.removeValue()
            
            let addFriendUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/friends/" + id
            let addFriendRef = Firebase(url: addFriendUrl)
            addFriendRef.removeValue()
            
            let friendUrl = "https://sonarapp.firebaseio.com/users/" + id + "/friends/" + currentUser
            let friendRef = Firebase(url: friendUrl)
            friendRef.removeValue()
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            self.friendsArray.removeAtIndex(indexPath.row)
            self.idArray.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
            print("Cancel Pressed")
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        
        alert.addAction(libButton)
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    

}
