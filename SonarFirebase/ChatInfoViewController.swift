//
//  ChatInfoViewController.swift
//  
//
//  Created by Brian Endo on 10/8/15.
//
//

import UIKit
import Firebase
import Parse
import AWSS3

class ChatInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var idArray = []
    var nameArray = [String]()
    var usernameArray = [Username]()
    var postID = ""
    
    var creatorname = ""
    
    func loadNames() {
        for id in idArray {
            let url = "https://sonarapp.firebaseio.com/users/" + (id as! String) + "/name/"
            let urlRef = Firebase(url: url)
            
            urlRef.observeEventType(.Value, withBlock: {
                snapshot in
                let name = snapshot.value as? String
                println(name)
                
                let username = Username(username: name, firebaseId: (id as! String))
                
                self.usernameArray.append(username)
                
                self.usernameArray.sort({ $0.username < $1.username })
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.loadNames()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Group Members"
        } else {
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
           return usernameArray.count
        } else {
            return 1
        }
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
        
        let cell: ChatInfoTableViewCell = tableView.dequeueReusableCellWithIdentifier("infoCell", forIndexPath: indexPath) as! ChatInfoTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.nameLabel.text = usernameArray[indexPath.row].username
        
        let id = usernameArray[indexPath.row].firebaseId
        
        cell.toggleButton.hidden = true
        cell.toggleButton.tag = indexPath.row
        cell.toggleButton.addTarget(self, action: "toggleButton:", forControlEvents: .TouchUpInside)
        cell.toggleButton.setTitle("Added", forState: .Selected)
        cell.toggleButton.setTitle("Add", forState: .Normal)
        
        
        let friendUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/friends/" + id
        let friendRef = Firebase(url: friendUrl)
        
        friendRef.observeEventType(.Value, withBlock: {
            snapshot in
            println(snapshot.value)
            if snapshot.value is NSNull {
                cell.toggleButton.hidden = false
                if id == currentUser {
                    cell.toggleButton.hidden = true
                }
                
            }
            
        })
        
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
        } else {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("leaveChatCell") as! UITableViewCell
            
            return cell
        }
    }
    
    func toggleButton(sender: UIButton){
        let id = usernameArray[sender.tag].firebaseId
        
        if sender.selected == false {
            sender.selected = true
            
            let userUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/added/"
            let userActivityRef = Firebase(url: userUrl)
            userActivityRef.childByAppendingPath(id).setValue(true)
            
            let otherUserUrl = "https://sonarapp.firebaseio.com/user_activity/" + (id) + "/addedme/"
            let otherUserActivityRef = Firebase(url: otherUserUrl)
            otherUserActivityRef.childByAppendingPath(currentUser).setValue(true)
            
            let readUrl = "https://sonarapp.firebaseio.com/user_activity/" + (id) + "/read/"
            let readRef = Firebase(url: readUrl)
            readRef.setValue(false)
            
            let pushURL = "https://sonarapp.firebaseio.com/users/" + (id) + "/pushId"
            let pushRef = Firebase(url: pushURL)
            pushRef.observeEventType(.Value, withBlock: {
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
                        "alert": "\(self.creatorname) added you",
                        "badge": "Increment",
                    ]
                    push.setData(data)
                    push.sendPushInBackground()
                }
            })
        } else {
            sender.selected = false
            
            let userUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/added/" + id
            let userActivityRef = Firebase(url: userUrl)
            userActivityRef.removeValue()
            
            let otherUserUrl = "https://sonarapp.firebaseio.com/user_activity/" + (id) + "/addedme/" + currentUser
            let otherUserActivityRef = Firebase(url: otherUserUrl)
            otherUserActivityRef.removeValue()
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let alert = UIAlertController(title: "Are you sure you want to leave the chat?", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let libButton = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { (alert) -> Void in
                
                let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/" + self.postID
                let targetRef = Firebase(url: url)
                targetRef.removeValue()
                
                let targetUrl = "https://sonarapp.firebaseio.com/posts/" + self.postID + "/targets/" + currentUser
                let removeTargetRef = Firebase(url: targetUrl)
                removeTargetRef.removeValue()
                
//                var array = self.navigationController?.viewControllers
//                println(array)

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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 70
        } else {
            return 55
        }
    }
    

}
