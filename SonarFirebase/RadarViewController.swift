//
//  RadarViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 8/27/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase

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
            
            postsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let key = snapshot.key
                {if let content = snapshot.value["content"] as? String {
                    if let creator = snapshot.value["creator"] as? String {
                        if let createdAt = snapshot.value["createdAt"] as? NSTimeInterval { 
                            let userurl = "https://sonarapp.firebaseio.com/users/" + (creator)
                            let userRef = Firebase(url: userurl)
                            userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                                if let firstname = snapshot.value["firstname"] as? String {
                                    if let lastname = snapshot.value["lastname"] as? String {
                            
                                        let name = firstname + " " + lastname
                                        let date = NSDate(timeIntervalSince1970: (createdAt/1000))
                                        
                                        let post = Post(content: content, creator: creator, key: key, createdAt: date, name: name)

                                        self.posts.append(post)
                                        
                                        // Sort posts in descending order
                                        self.posts.sortInPlace({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                        self.tableView.reloadData()
                                    }
                                }
                            })

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
                print(authData, terminator: "")
                currentUser = authData.uid
                self.tableView.delegate = self
                self.tableView.dataSource = self
                
                self.tableView.rowHeight = UITableViewAutomaticDimension
                self.tableView.estimatedRowHeight = 70
                
                // Remove all posts when reloaded so it updates
                self.posts.removeAll(keepCapacity: true)
                
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None

                self.loadRadarData()
                
            } else {
                // No user is signed in
                let login = UIStoryboard(name: "LogIn", bundle: nil)
                let loginVC = login.instantiateInitialViewController()
                self.presentViewController(loginVC!, animated: true, completion: nil)
            }
        })
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
    }
    
    func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [NSCalendarUnit.Minute, NSCalendarUnit.Hour, NSCalendarUnit.Day, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Second]
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:NSDateComponents = calendar.components(unitFlags, fromDate: earliest, toDate: latest, options: [])
        
        
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
            return "Just now"
        }
        
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Segue to Chat
        if segue.identifier == "showChat" {
            let chatVC: ChatTableViewController = segue.destinationViewController as! ChatTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            
            let post = self.posts[indexPath!.row]
            chatVC.postVC = post
            print(post.key, terminator: "")
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
        
        let radarContent: (AnyObject) = posts[indexPath.row].content
        cell.textView.selectable = false
        cell.textView.text = radarContent as? String
        cell.textView.userInteractionEnabled = false
        
        cell.textView.selectable = true
        
        let date = posts[indexPath.row].createdAt
        
        cell.timeLabel.text = self.timeAgoSinceDate(date, numericDates: true)
        
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
    
    
    
    

}
