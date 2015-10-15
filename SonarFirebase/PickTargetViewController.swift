//
//  PickTargetViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 8/26/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase
import Parse
import AWSS3

class PickTargetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var content = ""
    var creator = ""
    var creatorname = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    var friendsArray = [AnyObject]()
    var targetIdArray = [String]()
    var postTargets = [String]()
    var pushIdArray = [String]()

    
    func loadName() {
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser
        let userRef = Firebase(url: url)
        
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let username = snapshot.value["username"] as? String {
                    self.creatorname = username
            }
        })
    }
    
    func loadTargetData() {
        self.friendsArray.removeAll(keepCapacity: true)
        
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/friends/"
        let targetRef = Firebase(url: url)
        
        
        targetRef.queryOrderedByChild("username").observeEventType(.ChildAdded, withBlock: {
            snapshot in
            let nameUrl = "https://sonarapp.firebaseio.com/users/" + snapshot.key
            let nameRef = Firebase(url: nameUrl)
            nameRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                // do some stuff once
                if let username = snapshot.value["username"] as? String {
                            self.friendsArray.append(username)
                            self.targetIdArray.append(snapshot.key)
                            self.tableView.reloadData()
                }
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Pick Friends"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        self.loadTargetData()
        self.loadName()
        self.sendButton.enabled = false
        self.tableView.allowsMultipleSelection = true
    }

    override func viewDidAppear(animated: Bool) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.friendsArray.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: PickTargetTableViewCell = tableView.dequeueReusableCellWithIdentifier("pickTargetCell", forIndexPath: indexPath) as! PickTargetTableViewCell
        
        if indexPath.section == 0 {
            cell.nameLabel.text = "All Friends"
            cell.profileImageView.image = UIImage(named: "PeopleCirclePurple")
            return cell
        } else {
            let target: (AnyObject) = friendsArray[indexPath.row]
            let id: (String) = targetIdArray[indexPath.row]
            
            cell.nameLabel.text = target as? String
            
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
                        println("No Profile Pic")
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
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! PickTargetTableViewCell
        cell.contentView.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
        cell.nameLabel.textColor = UIColor(red:0.28, green:0.27, blue:0.43, alpha:1.0)
        cell.nameLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        
        if indexPath.section == 0 {
            var count = 0
            for (count; count < targetIdArray.count; count++) {
                var indexPath = NSIndexPath(forRow: count, inSection: 1)
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
            postTargets = targetIdArray
            self.sendButton.enabled = true
            println(postTargets)
        } else {
            var allFriends = NSIndexPath(forRow: 0, inSection: 0)
            let selectedIndexPaths = indexPathsForSelectedRowsInSection(indexPath.section)
            if selectedIndexPaths?.count == 1 {
                tableView.deselectRowAtIndexPath(allFriends, animated: false)
                postTargets = []
            }
            
            let target: (String) = targetIdArray[indexPath.row]
            postTargets.append(target)
            self.sendButton.enabled = true
            println(postTargets)
        }

    }
    
    func indexPathsForSelectedRowsInSection(section: Int) -> [NSIndexPath]? {
        return (tableView.indexPathsForSelectedRows() as? [NSIndexPath])?.filter({ (indexPath) -> Bool in
            indexPath.section == section
        })
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! PickTargetTableViewCell
        cell.contentView.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
        cell.nameLabel.textColor = UIColor.blackColor()
        cell.nameLabel.font = UIFont(name: "Helvetica Neue", size: 18)
        
        if indexPath.section == 0 {
            postTargets = []
            self.sendButton.enabled = false
            println(postTargets)
        } else {
            let target: (String) = targetIdArray[indexPath.row]
            let index = find(postTargets, target)
            postTargets.removeAtIndex(index!)
            
            if postTargets.count == 0 {
                self.sendButton.enabled = false
            }
            println(postTargets)
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1{
            return "Friends List"
        } else {
            return nil
        }
    }
    
    @IBAction func sendButtonPressed(sender: UIBarButtonItem) {
        
        let dateLater = (NSDate().timeIntervalSince1970 + (60*15)) * 1000
        let quickDate = (NSDate().timeIntervalSince1970 + (60*10))
        
        let postRef = ref.childByAppendingPath("posts")
        let post1 = ["content": content, "creator": currentUser, "messageCount": 0, "createdAt": [".sv":"timestamp"], "updatedAt": [".sv":"timestamp"], "endAt": quickDate ]
        let post1Ref = postRef.childByAutoId()
        post1Ref.setValue(post1)
        
        let postID = post1Ref.key
        
        for target in postTargets {
            
            let url = "https://sonarapp.firebaseio.com/posts/" + postID + "/targets/"
            let currentTargetRef = Firebase(url: url)
            currentTargetRef.childByAppendingPath(target).setValue(true)
            
            let postReceivedURL = "https://sonarapp.firebaseio.com/users/" + target + "/postsReceived/" + postID
            let postReceived = ["createdAt": [".sv":"timestamp"], "updatedAt": [".sv":"timestamp"], "endAt": quickDate]
            let postReceivedRef = Firebase(url: postReceivedURL)
            postReceivedRef.setValue(postReceived)
            
            let messageCountURL = "https://sonarapp.firebaseio.com/messageCount/" + target + "/postsReceived/" + postID
            let messageCount = ["myMessageCount": -1, "realMessageCount": 0]
            let messageCountRef = Firebase(url: messageCountURL)
            messageCountRef.setValue(messageCount)
            
            let pushURL = "https://sonarapp.firebaseio.com/users/" + target + "/pushId"
            let pushRef = Firebase(url: pushURL)
            pushRef.observeSingleEventOfType(.Value, withBlock: {
                snapshot in
                if snapshot.value is NSNull {
                    println("Did not enable push notifications")
                } else {
                    // Create our Installation query
                    let pushQuery = PFInstallation.query()
                    pushQuery?.whereKey("installationId", equalTo: snapshot.value)
                    
                    // Send push notification to query
                    let push = PFPush()
                    push.setQuery(pushQuery) // Set our Installation query
                    let data = [
                        "alert": "\(self.creatorname) (Pulse): \(self.content)",
                        "badge": "Increment",
                        "sound": "default",
                        "post": postID
                    ]
                    push.setData(data)
                    push.sendPushInBackground()
                }
            })
        }
        
        let userUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/" + postID 
        let userReceived = ["createdAt": [".sv":"timestamp"], "updatedAt": [".sv":"timestamp"], "endAt": quickDate]
        let userReceivedRef = Firebase(url: userUrl)
        userReceivedRef.setValue(userReceived)
        
        let userMessageCountURL = "https://sonarapp.firebaseio.com/messageCount/" + currentUser + "/postsReceived/" + postID
        let userMessageCount = ["myMessageCount": 0, "realMessageCount": 0]
        let userMessageCountRef = Firebase(url: userMessageCountURL)
        userMessageCountRef.setValue(userMessageCount)
        
        let url = "https://sonarapp.firebaseio.com/posts/" + postID + "/targets/"
        let currentTargetRef = Firebase(url: url)
        currentTargetRef.childByAppendingPath(currentUser).setValue(true)

        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

}
