//
//  AddedMeViewController.swift
//  Sonar
//
//  Created by Brian Endo on 9/30/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase
import Parse
import AWSS3

class AddedMeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var userIdArray = [String]()
    var nameArray = [String]()
    
    var creatorname = ""
    
    func loadName() {
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser
        let userRef = Firebase(url: url)
        
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let username = snapshot.value["username"] as? String {
                    self.creatorname = username
            }
        })
    }
    
    func loadData() {
        let addedMeUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/addedme/"
        let addedMeRef = Firebase(url: addedMeUrl)
        
        addedMeRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            let userId = snapshot.key
            let status = snapshot.value as? String
            
            if status == "addedBack" {
                
            } else {
            
            let userUrl = "https://sonarapp.firebaseio.com/users/" + userId
            let userRef = Firebase(url: userUrl)
            
            userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                let username = snapshot.value["username"] as? String
                self.userIdArray.insert(userId, atIndex: 0)
                self.nameArray.insert(username!, atIndex: 0)
                self.tableView.reloadData()
            })
        }
        })
        
    }
    
    func changeReadToTrue() {
        let readUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/read/"
        let readRef = Firebase(url: readUrl)
        readRef.setValue(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Added Me"
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.loadData()
        self.loadName()
        self.changeReadToTrue()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userIdArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: AddedMeTableViewCell = tableView.dequeueReusableCellWithIdentifier("addedMeCell", forIndexPath: indexPath) as! AddedMeTableViewCell
        
        let username = self.nameArray[indexPath.row]
        
        cell.friendLabel.text = username
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        
        let user: (String) = userIdArray[indexPath.row]
        
        let addMeUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/added/" + user
        let addMeRef = Firebase(url: addMeUrl)
        addMeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let added = snapshot.value as? Bool
            if added == true {
                cell.toggleButton.selected = true
            } else {
                cell.toggleButton.selected = false
            }
        })
        
        cell.toggleButton.tag = indexPath.row
        cell.toggleButton.addTarget(self, action: "toggleButton:", forControlEvents: .TouchUpInside)
        cell.toggleButton.setTitle("Added", forState: .Selected)
        cell.toggleButton.setTitle("Add", forState: .Normal)
        
        cell.profileImageView.image = UIImage(named: "Placeholder.png")
        if let cachedImageResult = imageCache[user] {
            print("pull from cache")
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
            readRequest1.key =  user
            readRequest1.downloadingFileURL = downloadingFileURL1
            
            let task = transferManager.download(readRequest1)
            task.continueWithBlock { (task) -> AnyObject! in
                if task.error != nil {
                    print(task.error, terminator: "")
                } else {
                    let image = UIImage(contentsOfFile: downloadingFilePath1)
                    let imageData = UIImageJPEGRepresentation(image!, 1.0)
                    imageCache[user] = imageData
                    dispatch_async(dispatch_get_main_queue()
                        , { () -> Void in
                            
                            cell.profileImageView.image = UIImage(contentsOfFile: downloadingFilePath1)
                            cell.setNeedsLayout()
                            
                    })
                    print("Fetched image")
                }
                return nil
            }
            
        }

        
        return cell
    }
    
    func toggleButton(sender: UIButton!) {
        let user: (String) = userIdArray[sender.tag]
        let friendName: (String) = nameArray[sender.tag]
        
        if sender.selected == false  {
            
            sender.selected = true
            
            let userUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/added/"
            let userActivityRef = Firebase(url: userUrl)
            userActivityRef.childByAppendingPath(user).setValue(true)
            
            let setAddedMeUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/addedme/"
            let setAddedMeRef = Firebase(url: setAddedMeUrl)
            setAddedMeRef.childByAppendingPath(user).setValue("addedBack")
            
            let addFriendUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/friends/" + user
            let addFriendRef = Firebase(url: addFriendUrl)
            addFriendRef.childByAppendingPath("username").setValue(friendName)
            
//            let addFriendUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/friends/"
//            let addFriendRef = Firebase(url: addFriendUrl)
//            addFriendRef.childByAppendingPath(user).setValue(true)
            
            let friendUrl = "https://sonarapp.firebaseio.com/users/" + user + "/friends/" + currentUser
            let friendRef = Firebase(url: friendUrl)
            friendRef.childByAppendingPath("username").setValue(self.creatorname)
            
//            let friendUrl = "https://sonarapp.firebaseio.com/users/" + user + "/friends/"
//            let friendRef = Firebase(url: friendUrl)
//            friendRef.childByAppendingPath(currentUser).setValue(true)
            
            let pushURL = "https://sonarapp.firebaseio.com/users/" + user + "/pushId"
            let pushRef = Firebase(url: pushURL)
            pushRef.observeEventType(.Value, withBlock: {
                snapshot in
                if snapshot.value is NSNull {
                    print("Did not enable push notifications")
                } else {
                    // Create our Installation query
                    let pushQuery = PFInstallation.query()
                    pushQuery?.whereKey("installationId", equalTo: snapshot.value)
                    
                    print("Reached")
                    // Send push notification to query
                    let push = PFPush()
                    push.setQuery(pushQuery) // Set our Installation query
                    let data = [
                        "alert": "You are now friends with \(self.creatorname)",
                        "badge": "Increment"
                    ]
                    push.setData(data)
                    push.sendPushInBackground()
                }
            })
        } else {
            sender.selected = false
            let userUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/added/" + user
            let userActivityRef = Firebase(url: userUrl)
            userActivityRef.removeValue()
            
            let addFriendUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/friends/" + user
            let addFriendRef = Firebase(url: addFriendUrl)
            addFriendRef.removeValue()
            
            let friendUrl = "https://sonarapp.firebaseio.com/users/" + user + "/friends/" + currentUser
            let friendRef = Firebase(url: friendUrl)
            friendRef.removeValue()
        }
    }
    

}
