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
    
    var friendsArray = [AnyObject]()
    var targetIdArray = [AnyObject]()
    var postTargets = [AnyObject]()

    
    func loadTargetData() {
        self.friendsArray.removeAll(keepCapacity: true)
        
        var url = "https://sonarapp.firebaseio.com/users" + "/" + currentUser + "/targets/"
        var targetRef = Firebase(url: url)
        
        
        targetRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            println(snapshot.key)
            
            var nameUrl = "https://sonarapp.firebaseio.com/users/" + snapshot.key
            var nameRef = Firebase(url: nameUrl)
            nameRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                // do some stuff once
                if let firstname = snapshot.value["firstname"] as? String {
                    if let lastname = snapshot.value["lastname"] as? String {
                        var name = firstname + " " + lastname
                        self.friendsArray.append(name)
                        println(name)
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
        
    }

    override func viewDidAppear(animated: Bool) {
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
//        self.tableView.reloadData()
//        
//        self.loadTargetData()
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
        cell.addTarget.addTarget(self, action: "addTarget:", forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    func addTarget(sender: UIButton!) {
        let target: (AnyObject) = targetIdArray[sender.tag]
        
        postTargets.append(target)
        
    }
    
    
    @IBAction func sendButtonPressed(sender: UIBarButtonItem) {
        
        let postRef = ref.childByAppendingPath("posts")
        let post1 = ["content": content, "creator": currentUser]
        let post1Ref = postRef.childByAutoId()
        post1Ref.setValue(post1)
        
        var postID = post1Ref.key
        
        if postTargets.count == 0 {
            
        } else {
            for target in postTargets {
                var url = "https://sonarapp.firebaseio.com/posts/" + postID + "/targets/"
                var currentTargetRef = Firebase(url: url)
                currentTargetRef.childByAppendingPath(target as! String).setValue(true)
                
                var targetedUrl = "https://sonarapp.firebaseio.com/users/" + (target as! String) + "/postsReceived/"
                var targetedRef = Firebase(url: targetedUrl)
                targetedRef.childByAppendingPath(postID).setValue(true)
            }
//            var myurl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsSent/"
//            var myPostsRef = Firebase(url: myurl)
//            myPostsRef.childByAppendingPath(postID).setValue(true)
            var userurl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/"
            var userTargetRef = Firebase(url: userurl)
            userTargetRef.childByAppendingPath(postID).setValue(true)
        }
        
        
        // Add Server Side timestamp to post
        var timeUrl = "https://sonarapp.firebaseio.com/posts/" + postID
        var timeRef = Firebase(url: timeUrl)
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
        var dateUrl = "https://sonarapp.firebaseio.com/posts/" + postID
        var dateRef = Firebase(url: dateUrl)
        
        dateRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            // do some stuff once
            if let createdAt = snapshot.value["createdAt"] as? NSTimeInterval {
                var date = NSDate(timeIntervalSince1970: (createdAt/1000))
                println(date)
                let dateFormatter = NSDateFormatter()
                dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
                dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
                dateFormatter.timeZone = NSTimeZone()
                let localDate = dateFormatter.stringFromDate(date)
                println(localDate)
            }
            
            
        })

        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

}
