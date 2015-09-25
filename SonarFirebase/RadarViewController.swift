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
    
    func loadRadarData() {
        
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/"
        let targetRef = Firebase(url: url)
        
        
        targetRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            
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
                            let userurl = "https://sonarapp.firebaseio.com/users/" + (creator)
                            let userRef = Firebase(url: userurl)
                            userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                                if let firstname = snapshot.value["firstname"] as? String {
                                    if let lastname = snapshot.value["lastname"] as? String {
                                        let updatedDate = NSDate(timeIntervalSince1970: (updatedAt/1000))
                                        let name = firstname + " " + lastname
                                        let createdDate = NSDate(timeIntervalSince1970: (createdAt/1000))
                                        var date: NSDate?
                                        if joined == true {
                                            date = updatedDate
                                        } else {
                                            date = createdDate
                                        }
                                        println(date!)
                                        let post = Post(content: content, creator: creator, key: key, createdAt: date!, name: name, joined: joined!, messageCount: messageCount!)
                                        self.posts.append(post)
                                        
                                        // Sort posts in descending order
                                        self.posts.sort({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                        self.tableView.reloadData()
                                    }
                                }
                            })
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
                                let userurl = "https://sonarapp.firebaseio.com/users/" + (creator)
                                let userRef = Firebase(url: userurl)
                                userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                                    if let firstname = snapshot.value["firstname"] as? String {
                                        if let lastname = snapshot.value["lastname"] as? String {
                                            let updatedDate = NSDate(timeIntervalSince1970: (updatedAt/1000))
                                            let name = firstname + " " + lastname
                                            let createdDate = NSDate(timeIntervalSince1970: (createdAt/1000))
                                            var date: NSDate?
                                            if joined == true {
                                                date = updatedDate
                                            } else {
                                                date = createdDate
                                            }
                                            println(date!)
                                            
                                            
                                            let post = Post(content: content, creator: creator, key: key, createdAt: date!, name: name, joined: joined!, messageCount: messageCount!)
                                            self.posts.append(post)
                                            
                                            // Sort posts in descending order
                                            self.posts.sort({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                            self.tableView.reloadData()
                                        }
                                    }
                                })
                            }
                        }
                    }
                    }
                    
                }
            })
        })
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
                
//                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None

                self.loadRadarData()
                self.changedRadarData()
            } else {
                // No user is signed in
                let login = UIStoryboard(name: "LogIn", bundle: nil)
                let loginVC = login.instantiateInitialViewController() as! UIViewController
                self.presentViewController(loginVC, animated: true, completion: nil)
            }
        })
        
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
        
        
        let key = posts[indexPath.row].key
        
        let radarContent: (AnyObject) = posts[indexPath.row].content
        cell.textView.selectable = false
        cell.textView.text = radarContent as? String
        cell.textView.userInteractionEnabled = false
        
        cell.textView.selectable = true
        
        
        let joinedStatus = posts[indexPath.row].joined
        if joinedStatus == true {
            cell.postImageView.image = UIImage(named: "Chat")
        } else {
            cell.postImageView.image = UIImage(named: "Pulse")
        }
        
        
        
        let date = posts[indexPath.row].createdAt
        
        cell.timeLabel.text = self.timeAgoSinceDate(date, numericDates: true)
        
        // Need View Controller to segue in TableViewCell
        cell.viewController = self
        
        let radarCreator: (AnyObject) = posts[indexPath.row].name
        
        cell.nameLabel.text = radarCreator as? String
        
        let userMessageCount = posts[indexPath.row].messageCount
        
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
        
        let changedUrl = "https://sonarapp.firebaseio.com/posts/" + key + "/messageCount/"
        let changeMessageRef = Firebase(url: changedUrl)
        changeMessageRef.observeEventType(.ChildChanged, withBlock: {
            snapshot in
            
            let messageCount = snapshot.value as? Int
            
            if userMessageCount < messageCount {
                cell.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
            } else {
                cell.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
            }
            
        })
        
        return cell
    }
    

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("showChat", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            println("Delete")
        }
    }
    
    
    
    
    

}
