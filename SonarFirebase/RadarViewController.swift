//
//  RadarViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 8/27/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase
import Parse


class RadarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    var postID = [String]()
    
    var cellURL: NSURL?
    
    var timer: NSTimer!
    
    
    func fireCellsUpdate() {
        let notification = NSNotification(name: "CustomCellUpdate", object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    func getLastAdded() {
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/"
        let targetRef = Firebase(url: url)

        
        targetRef.queryLimitedToLast(1).observeEventType(.Value, withBlock: {
            snapshot in
            
            println("get added")
            println(snapshot.value)
        })
    }
    
    func getLastChanged() {
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/"
        let targetRef = Firebase(url: url)
        
        
        targetRef.queryLimitedToLast(1).observeEventType(.ChildChanged, withBlock: {
            snapshot in
            println("get changed")
            println(snapshot.key)
            println(snapshot.value)
        })
    }

    
    func loadRadarData() {
        
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/"
        let targetRef = Firebase(url: url)
        
        targetRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            println("child")
            if let found = find(self.posts.map({ $0.key }), snapshot.key) {
                let obj = self.posts[found]
                println(obj)
                println(found)
                self.posts.removeAtIndex(found)
            }
            
            let postsUrl = "https://sonarapp.firebaseio.com/posts/" + snapshot.key
            let postsRef = Firebase(url: postsUrl)
            let joined = snapshot.value["joined"] as? Bool
            
            
            var messageCount = snapshot.value["messageCount"] as? Int
            if messageCount == nil {
                messageCount = 0
            }
            postsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let key = snapshot.key
                {if let content = snapshot.value["content"] as? String {
                    if let creator = snapshot.value["creator"] as? String {
                        if let createdAt = snapshot.value["createdAt"] as? NSTimeInterval {
                            if let updatedAt = snapshot.value["updatedAt"] as? NSTimeInterval {
                                if let endAt = snapshot.value["endAt"] as? NSTimeInterval {
                            let userurl = "https://sonarapp.firebaseio.com/users/" + (creator)
                            let userRef = Firebase(url: userurl)
                            userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                                if let name = snapshot.value["name"] as? String {
                                        let updatedDate = NSDate(timeIntervalSince1970: (updatedAt/1000))
                                        let createdDate = NSDate(timeIntervalSince1970: (createdAt/1000))
                                        let endedDate = NSDate(timeIntervalSince1970: (endAt/1000))
                                        var date: NSDate?
                                        if joined == true {
                                            date = updatedDate
                                            println("updated at")
                                        } else {
                                            date = createdDate
                                            println("created at")
                                        }
                                        
                                        println(joined)
                                        let post = Post(content: content, creator: creator, key: key, createdAt: date!, name: name, joined: joined, messageCount: messageCount!, endAt: endedDate)
                                        
                                        self.posts.append(post)
                                        
                                        
                                        // Sort posts in descending order
                                        self.posts.sort({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                        self.tableView.reloadData()
                                }
                            })
                            }
                            }
                            
                        }
                    }
                }
                
                }
            })
        })
    }
    
    func changedRadarData() {
        
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/"
        let targetRef = Firebase(url: url)
        
        
        targetRef.observeEventType(.ChildChanged, withBlock: {
            snapshot in
            if let found = find(self.posts.map({ $0.key }), snapshot.key) {
            let obj = self.posts[found]
                println(obj)
                println(found)
                self.posts.removeAtIndex(found)
            }
            
            
            // Update post to ensure that Feed is in correct order
            let postUpdatedUrl = "https://sonarapp.firebaseio.com/posts/" + snapshot.key
            let postUpdatedRef = Firebase(url: postUpdatedUrl)
            let updatedAt = ["updatedAt": [".sv":"timestamp"] ]
            postUpdatedRef.updateChildValues(updatedAt)
            
            println("childChanged")
            
            let postsUrl = "https://sonarapp.firebaseio.com/posts/" + snapshot.key
            let postsRef = Firebase(url: postsUrl)
            let joined = snapshot.value["joined"] as? Bool
            
            var messageCount = snapshot.value["messageCount"] as? Int
            if messageCount == nil {
                messageCount = 0
            }
            println(messageCount)
            postsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let key = snapshot.key
                {if let content = snapshot.value["content"] as? String {
                    if let creator = snapshot.value["creator"] as? String {
                        if let createdAt = snapshot.value["createdAt"] as? NSTimeInterval {
                            if let updatedAt = snapshot.value["updatedAt"] as? NSTimeInterval {
                                if let endAt = snapshot.value["endAt"] as? NSTimeInterval {
                                let userurl = "https://sonarapp.firebaseio.com/users/" + (creator)
                                let userRef = Firebase(url: userurl)
                                userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                                    if let name = snapshot.value["name"] as? String {
                                            let updatedDate = NSDate(timeIntervalSince1970: (updatedAt/1000))
                                            let createdDate = NSDate(timeIntervalSince1970: (createdAt/1000))
                                            let endedDate = NSDate(timeIntervalSince1970: (endAt/1000))
                                            var date: NSDate?
                                            if joined == true {
                                                date = updatedDate
                                                println(updatedDate)
                                            } else {
                                                date = createdDate
                                            }
                                            
                                            let post = Post(content: content, creator: creator, key: key, createdAt: date!, name: name, joined: joined!, messageCount: messageCount!, endAt: endedDate)
                                            
                                            self.posts.append(post)
                                            
                                            // Sort posts in descending order
                                            self.posts.sort({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                            
                                            self.tableView.reloadData()
                                        }
                                })
                                }
                            }
                        }
                    }
                    }
                    
                }
            })
        })
    }
    
    func dataRemove() {
        
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/"
        let targetRef = Firebase(url: url)
        
        
        targetRef.observeEventType(.ChildRemoved, withBlock: {
            snapshot in
            if let found = find(self.posts.map({ $0.key }), snapshot.key) {
                let obj = self.posts[found]
                println(obj)
                println(found)
                self.posts.removeAtIndex(found)
            }
            
            println("childRemoved")
            
            self.posts.sort({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
            self.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Authenticate user and redirect to login if not signed in
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                print(authData)
                currentUser = authData.uid
                
                // Add installationID from Parse to Firebase
                let installationId = PFInstallation.currentInstallation().installationId
                let userURL = "https://sonarapp.firebaseio.com/users/" + currentUser
                var userRef = Firebase(url: userURL)
                userRef.childByAppendingPath("pushId").setValue(installationId)
                
                self.tableView.delegate = self
                self.tableView.dataSource = self
                
                self.tableView.rowHeight = UITableViewAutomaticDimension
                self.tableView.estimatedRowHeight = 70
                
                // Remove all posts when reloaded so it updates
                self.posts.removeAll(keepCapacity: true)
                
                self.loadRadarData()
                self.changedRadarData()
                self.dataRemove()
                
                
                self.getLastAdded()
                self.getLastChanged()
                
                self.timer = NSTimer(timeInterval: 1.0, target: self, selector: Selector("fireCellsUpdate"), userInfo: nil, repeats: true)
                NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
                
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.addObserver(self, selector: Selector("deleteDeadCell"), name: "DeleteDeadCell", object: nil)
            } else {
                // No user is signed in
                let login = UIStoryboard(name: "LogIn", bundle: nil)
                let loginVC = login.instantiateInitialViewController() as! UIViewController
                self.presentViewController(loginVC, animated: true, completion: nil)
            }
        })
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
    
    func deleteDeadCell() {
        for post in posts {
            let endAt = post.endAt
            var timeLeft = endAt.timeIntervalSinceDate(NSDate())
            if timeLeft <= 0 {
                if let found = find(self.posts.map({ $0.endAt }), post.endAt) {
                    let obj = self.posts[found]
                    println(obj)
                    println(found)
                    println(post.key)
                    
                    let url = "https://sonarapp.firebaseio.com/posts/" + post.key + "/endAt"
                    let postRef = Firebase(url: url)
                    postRef.observeEventType(.Value, withBlock: {
                        snapshot in
                        let endTime = snapshot.value as? NSTimeInterval
                        
                        let endedDate = NSDate(timeIntervalSince1970: (endTime!/1000))
                        
                        var timeLeft = endedDate.timeIntervalSinceDate(NSDate())
                        println(timeLeft)
                        if timeLeft >= 0 {
                            println("Alive")
                        }
                        else {
                            println("Delete")
                            let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/" + post.key
                            let targetRef = Firebase(url: url)
                            targetRef.removeValue()
                            
                            let targetUrl = "https://sonarapp.firebaseio.com/posts/" + post.key + "/targets/" + currentUser
                            let removeTargetRef = Firebase(url: targetUrl)
                            removeTargetRef.removeValue()

                        }
                    })
                }
            }
        }
        
    }
    
    
    func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        let calendar = NSCalendar.currentCalendar()
        let unitFlags = NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitWeekOfYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitSecond
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:NSDateComponents = calendar.components(unitFlags, fromDate: earliest, toDate: latest, options: nil)
        
        
        if (components.year >= 2) {
            return "\(components.year) years ago"
        } else if (components.year >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month >= 2) {
            return "\(components.month) months ago"
        } else if (components.month >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear >= 2) {
            return "\(components.weekOfYear) weeks ago"
        } else if (components.weekOfYear >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day >= 2) {
            return "\(components.day)d"
        } else if (components.day >= 1){
            if (numericDates){
                return "1d"
            } else {
                return "Yesterday"
            }
        } else if (components.hour >= 2) {
            return "\(components.hour)h"
        } else if (components.hour >= 1){
            if (numericDates){
                return "1h"
            } else {
                return "An hour ago"
            }
        } else if (components.minute >= 2) {
            return "\(components.minute)m"
        } else if (components.minute >= 1){
            if (numericDates){
                return "1m"
            } else {
                return "A minute ago"
            }
        } else if (components.second >= 3) {
            return "\(components.second)s"
        } else {
            return "1s"
        }
        
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Segue to Chat
        if segue.identifier == "showChat" {
            let chatVC: ChatTableViewController = segue.destinationViewController as! ChatTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            tableView.cellForRowAtIndexPath(indexPath!)?.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
            posts[indexPath!.row].joined = true
            self.tableView.reloadData()
            let post = self.posts[indexPath!.row]
            chatVC.postVC = post
            chatVC.postID = post.key
        }
        // Segue to WebView
        else if segue.identifier == "presentWebView" {
            // Go to nav controller then webVC
            let nav = segue.destinationViewController as! UINavigationController
            let webVC: WebViewController = nav.topViewController as! WebViewController
            
            webVC.urlToLoad = cellURL
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: RadarTableViewCell = tableView.dequeueReusableCellWithIdentifier("radarCell", forIndexPath: indexPath) as! RadarTableViewCell
        
        let creator: (String) = posts[indexPath.row].creator
        
        
        let key = posts[indexPath.row].key
        
        let radarContent: (AnyObject) = posts[indexPath.row].content
        cell.textView.selectable = false
        cell.textView.text = radarContent as? String
        cell.textView.userInteractionEnabled = false
        
        cell.textView.selectable = true
        
        let userMessageCount = posts[indexPath.row].messageCount
        
        let joinedStatus = posts[indexPath.row].joined
        
        let url = "https://sonarapp.firebaseio.com/posts/" + key + "/messageCount/"
        let messageRef = Firebase(url: url)
        messageRef.observeEventType(.Value, withBlock: {
            snapshot in
            let messageCount = snapshot.value as? Int
            
            if userMessageCount < messageCount {
                cell.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
            } else {
                cell.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
            }
            
        })
        
//        if joinedStatus == true {
//            cell.postImageView.image = UIImage(named: "Chat")
//            cell.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
//
//            let url = "https://sonarapp.firebaseio.com/posts/" + key + "/messageCount/"
//            let messageRef = Firebase(url: url)
//            messageRef.observeEventType(.Value, withBlock: {
//                snapshot in
//                let messageCount = snapshot.value as? Int
//                
//                if userMessageCount < messageCount {
//                    cell.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
//                } else {
//                    cell.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
//                }
//                
//            })
//            
//            let changedUrl = "https://sonarapp.firebaseio.com/posts/" + key + "/messageCount/"
//            let changeMessageRef = Firebase(url: changedUrl)
//            changeMessageRef.observeEventType(.ChildChanged, withBlock: {
//                snapshot in
//                println("Reached Changed")
//                let messageCount = snapshot.value as? Int
//                
//                if userMessageCount < messageCount {
//                    cell.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
//                } else {
//                    cell.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
//                }
//                
//            })
//        } else {
//            cell.postImageView.image = UIImage(named: "Pulse")
//            cell.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
//        }
        
        
        
        let date = posts[indexPath.row].createdAt
        
        cell.timeLabel.text = self.timeAgoSinceDate(date, numericDates: true)
        
        
        let endTime = posts[indexPath.row].endAt
        var timeLeft = endTime.timeIntervalSinceDate(NSDate())
        cell.timeInterval = round(timeLeft)
        
        // Need View Controller to segue in TableViewCell
        cell.viewController = self
        
        let radarCreator: (AnyObject) = posts[indexPath.row].name
        
        cell.nameLabel.text = radarCreator as? String
        
        return cell
    }
    

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showChat", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            println("Delete")
            let post = posts[indexPath.row]
            // 2
            let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/" + post.key
            let targetRef = Firebase(url: url)
            targetRef.removeValue()
            
            let targetUrl = "https://sonarapp.firebaseio.com/posts/" + post.key + "/targets/" + currentUser
            let removeTargetRef = Firebase(url: targetUrl)
            removeTargetRef.removeValue()
            
            self.tableView.reloadData()
        }
    }
    
    
    
    
    

}
