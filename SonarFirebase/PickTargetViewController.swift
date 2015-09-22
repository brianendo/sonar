//
//  PickTargetViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 8/26/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase

class PickTargetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var content = ""
    var creator = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    var friendsArray = [AnyObject]()
    var targetIdArray = [String]()
    var postTargets = [String]()

    
    func loadTargetData() {
        self.friendsArray.removeAll(keepCapacity: true)
        
        let url = "https://sonarapp.firebaseio.com/users" + "/" + currentUser + "/targets/"
        let targetRef = Firebase(url: url)
        
        
        targetRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            let nameUrl = "https://sonarapp.firebaseio.com/users/" + snapshot.key
            let nameRef = Firebase(url: nameUrl)
            nameRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                // do some stuff once
                if let firstname = snapshot.value["firstname"] as? String {
                    if let lastname = snapshot.value["lastname"] as? String {
                        let name = firstname + " " + lastname
                        self.friendsArray.append(name)
                        self.targetIdArray.append(snapshot.key)
                        self.tableView.reloadData()
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
        self.sendButton.enabled = false
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
        
        cell.addTarget.tag = indexPath.row
        cell.addTarget.setTitle("Added", forState: UIControlState.Selected)
        cell.addTarget.setTitle("Add", forState: UIControlState.Normal)
        cell.addTarget.addTarget(self, action: "buttonClicked:", forControlEvents: .TouchUpInside)
        
        
        return cell
    }
    
    func buttonClicked(sender: UIButton!) {
        if sender.selected == true {
            
            let target: (String) = targetIdArray[sender.tag]
            let index = postTargets.indexOf(target)
            postTargets.removeAtIndex(index!)
            if postTargets.count == 0 {
                self.sendButton.enabled = false
            }
            
            sender.selected = false
        } else {
            let target: (String) = targetIdArray[sender.tag]
            postTargets.append(target)
            self.sendButton.enabled = true
            sender.selected = true
//            if postTargets.count > 0 {
//                self.sendButton.enabled = true
//                sender.selected = true
//            } else {
//                sender.selected = true
//            }
            
        }
//        let target: (AnyObject) = targetIdArray[sender.tag]
//        postTargets.append(target)
//        sender.setTitle("Added", forState: UIControlState.Normal)
//        if postTargets.count > 0 {
//           self.sendButton.enabled = true
//        } else {
//            
//        }
    }
    
    
    @IBAction func sendButtonPressed(sender: UIBarButtonItem) {
        
        let postRef = ref.childByAppendingPath("posts")
        let post1 = ["content": content, "creator": currentUser]
        let post1Ref = postRef.childByAutoId()
        post1Ref.setValue(post1)
        
        let postID = post1Ref.key
        
        if postTargets.count == 0 {
            
        } else {
            for target in postTargets {
                let url = "https://sonarapp.firebaseio.com/posts/" + postID + "/targets/"
                let currentTargetRef = Firebase(url: url)
                currentTargetRef.childByAppendingPath(target ).setValue(true)
                
                let targetedUrl = "https://sonarapp.firebaseio.com/users/" + (target ) + "/postsReceived/"
                let targetedRef = Firebase(url: targetedUrl)
                targetedRef.childByAppendingPath(postID).setValue(true)
            }
//            var myurl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsSent/"
//            var myPostsRef = Firebase(url: myurl)
//            myPostsRef.childByAppendingPath(postID).setValue(true)
            let userurl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/"
            let userTargetRef = Firebase(url: userurl)
            userTargetRef.childByAppendingPath(postID).setValue(true)
        }
        
        
        // Add Server Side timestamp to post
        let timeUrl = "https://sonarapp.firebaseio.com/posts/" + postID
        let timeRef = Firebase(url: timeUrl)
        timeRef.childByAppendingPath("createdAt").setValue([".sv":"timestamp"])
        
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
        
        
        // Convert unix date to local date
        let dateUrl = "https://sonarapp.firebaseio.com/posts/" + postID
        let dateRef = Firebase(url: dateUrl)
        
        dateRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            // do some stuff once
            if let createdAt = snapshot.value["createdAt"] as? NSTimeInterval {
                let date = NSDate(timeIntervalSince1970: (createdAt/1000))
                print(date, terminator: "")
                let dateFormatter = NSDateFormatter()
                dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
                dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
                dateFormatter.timeZone = NSTimeZone()
                let localDate = dateFormatter.stringFromDate(date)
                print(localDate, terminator: "")
            }
            
            
        })

        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

}
