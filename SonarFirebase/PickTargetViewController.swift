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
            if let firstname = snapshot.value["firstname"] as? String {
                if let lastname = snapshot.value["lastname"] as? String {
                    let name = firstname + " " + lastname
                    self.creatorname = name
                }
            }
        })
    }
    
    func loadTargetData() {
        self.friendsArray.removeAll(keepCapacity: true)
        
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/targets/"
        let targetRef = Firebase(url: url)
        
        
        targetRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            let nameUrl = "https://sonarapp.firebaseio.com/users/" + snapshot.key
            let nameRef = Firebase(url: nameUrl)
            nameRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                // do some stuff once
                if let firstname = snapshot.value["firstname"] as? String {
                    if let lastname = snapshot.value["lastname"] as? String {
//                        if snapshot.value["pushId"] is NSNull {
                            let name = firstname + " " + lastname
                            self.friendsArray.append(name)
                            self.targetIdArray.append(snapshot.key)
                            self.tableView.reloadData()
//                        } else if let pushId = snapshot.value["pushId"] as? String {
//                            let name = firstname + " " + lastname
//                            self.friendsArray.append(name)
//                            self.pushIdArray.append(pushId)
//                            self.targetIdArray.append(snapshot.key)
//                            self.tableView.reloadData()
//                        }
                    
                    }
                }
                
                
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
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
        return self.friendsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: PickTargetTableViewCell = tableView.dequeueReusableCellWithIdentifier("pickTargetCell", forIndexPath: indexPath) as! PickTargetTableViewCell
        
        let target: (AnyObject) = friendsArray[indexPath.row]
        cell.nameLabel.text = target as? String
//        cell.addTarget.tag = indexPath.row
//        cell.addTarget.setTitle("Added", forState: UIControlState.Selected)
//        cell.addTarget.setTitle("Add", forState: UIControlState.Normal)
//        cell.addTarget.addTarget(self, action: "buttonClicked:", forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! PickTargetTableViewCell
        cell.contentView.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
        cell.nameLabel.textColor = UIColor(red:0.28, green:0.27, blue:0.43, alpha:1.0)
        cell.nameLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        let target: (String) = targetIdArray[indexPath.row]
        postTargets.append(target)
        self.sendButton.enabled = true
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! PickTargetTableViewCell
        cell.contentView.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
        let target: (String) = targetIdArray[indexPath.row]
        let index = find(postTargets, target)
        postTargets.removeAtIndex(index!)
        cell.nameLabel.textColor = UIColor.blackColor()
        cell.nameLabel.font = UIFont(name: "Helvetica Neue", size: 18)
        if postTargets.count == 0 {
            self.sendButton.enabled = false
        }

    }
    
    
//    func buttonClicked(sender: UIButton!) {
//        if sender.selected == true {
//            
//            let target: (String) = targetIdArray[sender.tag]
//            let index = find(postTargets, target)
//            postTargets.removeAtIndex(index!)
//            if postTargets.count == 0 {
//                self.sendButton.enabled = false
//            }
//            
//            sender.selected = false
//        } else {
//            let target: (String) = targetIdArray[sender.tag]
//            postTargets.append(target)
//            self.sendButton.enabled = true
//            sender.selected = true
//        }
//
//    }
    
    
    @IBAction func sendButtonPressed(sender: UIBarButtonItem) {
        
        let postRef = ref.childByAppendingPath("posts")
        let post1 = ["content": content, "creator": currentUser, "messageCount": 0, "createdAt": [".sv":"timestamp"], "updatedAt": [".sv":"timestamp"] ]
        let post1Ref = postRef.childByAutoId()
        post1Ref.setValue(post1)
        
        let postID = post1Ref.key
        
        for target in postTargets {
            let url = "https://sonarapp.firebaseio.com/posts/" + postID + "/targets/"
            let currentTargetRef = Firebase(url: url)
            currentTargetRef.childByAppendingPath(target ).setValue(true)
            
            let postReceivedURL = "https://sonarapp.firebaseio.com/users/" + (target) + "/postsReceived/" + postID
            let postReceived = ["joined": false, "messageCount": 0]
            let postReceivedRef = Firebase(url: postReceivedURL)
            postReceivedRef.setValue(postReceived)
            
//            let targetedUrl = "https://sonarapp.firebaseio.com/users/" + (target) + "/postsReceived/" + postID + "/joined/"
//            let targetedRef = Firebase(url: targetedUrl)
//            targetedRef.setValue(false)
//            
//            let messageCountUrl = "https://sonarapp.firebaseio.com/users/" + (target) + "/postsReceived/" + postID + "/messageCount/"
//            let messageCountRef = Firebase(url: messageCountUrl)
//            messageCountRef.setValue(0)
            
            let pushURL = "https://sonarapp.firebaseio.com/users/" + target + "/pushId"
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
                        "alert": "\(self.creatorname) (Pulse): \(self.content)",
                        "badge": "Increment",
                        "post": postID
                    ]
                    push.setData(data)
                    push.sendPushInBackground()
                }
            })
        }
        
        let userUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/" + postID 
        let userReceived = ["joined": true, "messageCount": 0]
        let userReceivedRef = Firebase(url: userUrl)
        userReceivedRef.setValue(userReceived)
//
//        let messageCountUserUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/" + postID + "/messageCount/"
//        let messageCountUserRef = Firebase(url: messageCountUserUrl)
//        messageCountUserRef.setValue(0)
        
        let url = "https://sonarapp.firebaseio.com/posts/" + postID + "/targets/"
        let currentTargetRef = Firebase(url: url)
        currentTargetRef.childByAppendingPath(currentUser).setValue(true)
        
        
//        // Make post as first message
//        let messageUrl = "https://sonarapp.firebaseio.com/messages/" + postID
//        let messageRef = Firebase(url: messageUrl)
//        let message1 = ["creator": currentUser, "content": content]
//        let messages = messageRef.childByAutoId()
//        messages.setValue(message1)
//        
//        var messageID = messages.key
//        
//        var timeMessageUrl = "https://sonarapp.firebaseio.com/messages/" + postID + "/" + messageID
//        var timeMessageRef = Firebase(url: timeMessageUrl)
//        timeMessageRef.childByAppendingPath("createdAt").setValue([".sv":"timestamp"])
//        
        
        
//        // Convert unix date to local date
//        let dateUrl = "https://sonarapp.firebaseio.com/posts/" + postID
//        let dateRef = Firebase(url: dateUrl)
//        
//        dateRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
//            // do some stuff once
//            if let createdAt = snapshot.value["createdAt"] as? NSTimeInterval {
//                let date = NSDate(timeIntervalSince1970: (createdAt/1000))
//                print(date)
//                let dateFormatter = NSDateFormatter()
//                dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
//                dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
//                dateFormatter.timeZone = NSTimeZone()
//                let localDate = dateFormatter.stringFromDate(date)
//                print(localDate)
//            }
//            
//            
//        })

        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

}
