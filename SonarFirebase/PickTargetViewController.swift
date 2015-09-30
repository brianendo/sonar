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
                if let name = snapshot.value["name"] as? String {
//                    if let lastname = snapshot.value["lastname"] as? String {
                            self.friendsArray.append(name)
                            self.targetIdArray.append(snapshot.key)
                            self.tableView.reloadData()
//                    }
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
    
    
    @IBAction func sendButtonPressed(sender: UIBarButtonItem) {
        
        let dateLater = (NSDate().timeIntervalSince1970 + (60*15)) * 1000
        let quickDate = (NSDate().timeIntervalSince1970 + (20)) * 1000
        
        let postRef = ref.childByAppendingPath("posts")
        let post1 = ["content": content, "creator": currentUser, "messageCount": 0, "createdAt": [".sv":"timestamp"], "updatedAt": [".sv":"timestamp"], "endAt": quickDate ]
        let post1Ref = postRef.childByAutoId()
        post1Ref.setValue(post1)
        
        let postID = post1Ref.key
        
        for target in postTargets {
            
            let friendUrl = "https://sonarapp.firebaseio.com/users/" + target + "/targets/" + currentUser
            let friendRef = Firebase(url: friendUrl)
            friendRef.observeEventType(.Value, withBlock: {
                snapshot in
                let friendship = snapshot.value as? Bool
                println(friendship)
                if friendship == true {
                    println("Friends")
                } else {
                    println("Not Friends")
                }
            })
            
            let url = "https://sonarapp.firebaseio.com/posts/" + postID + "/targets/"
            let currentTargetRef = Firebase(url: url)
            currentTargetRef.childByAppendingPath(target).setValue(true)
            
            let postReceivedURL = "https://sonarapp.firebaseio.com/users/" + target + "/postsReceived/" + postID
            let postReceived = ["joined": false, "messageCount": 0]
            let postReceivedRef = Firebase(url: postReceivedURL)
            postReceivedRef.setValue(postReceived)
            
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
        
        let url = "https://sonarapp.firebaseio.com/posts/" + postID + "/targets/"
        let currentTargetRef = Firebase(url: url)
        currentTargetRef.childByAppendingPath(currentUser).setValue(true)

        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

}
