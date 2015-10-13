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
import AWSS3


class RadarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    var postID = [String]()
    
    var friendsArray = [String]()
    var idArray = [String]()
    
    var cellURL: NSURL?
    
    var timer: NSTimer!
    
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

    func getRadarData() {
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
            var updatedAt = snapshot.value["updatedAt"] as? NSTimeInterval
            var endAt = snapshot.value["endAt"] as? NSTimeInterval
            
            if updatedAt == nil {
                updatedAt = 0
            }
            
            if endAt == nil {
                endAt = 0
            }
            
            postsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let key = snapshot.key
                {if let content = snapshot.value["content"] as? String {
                    if let creator = snapshot.value["creator"] as? String {
                        if let createdAt = snapshot.value["createdAt"] as? NSTimeInterval {
                                    let userurl = "https://sonarapp.firebaseio.com/users/" + (creator)
                                    let userRef = Firebase(url: userurl)
                                    userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                                        if let username = snapshot.value["username"] as? String {
                                            let updatedDate = NSDate(timeIntervalSince1970: (updatedAt!/1000))
                                            let createdDate = NSDate(timeIntervalSince1970: (createdAt/1000))
                                            let endedDate = NSDate(timeIntervalSince1970: (endAt!))
                                            
                                            let post = Post(content: content, creator: creator, key: key, createdAt: updatedDate, name: username, joined: true, messageCount: 0, endAt: endedDate)
                                            
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
            })
        })
    }
    
    func getChangedRadarData() {
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/"
        let targetRef = Firebase(url: url)
        
        targetRef.observeEventType(.ChildChanged, withBlock: {
            snapshot in
            println("childChanged")
            
            let eliminate = snapshot.key
            

            
            let postsUrl = "https://sonarapp.firebaseio.com/posts/" + snapshot.key
            let postsRef = Firebase(url: postsUrl)
            //            let joined = snapshot.value["joined"] as? Bool
            let updatedAt = snapshot.value["updatedAt"] as? NSTimeInterval
            let endAt = snapshot.value["endAt"] as? NSTimeInterval
            
            postsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let key = snapshot.key
                {if let content = snapshot.value["content"] as? String {
                    if let creator = snapshot.value["creator"] as? String {
                        if let createdAt = snapshot.value["createdAt"] as? NSTimeInterval {
                            let userurl = "https://sonarapp.firebaseio.com/users/" + (creator)
                            let userRef = Firebase(url: userurl)
                            userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                                if let username = snapshot.value["username"] as? String {
                                    
                                    let updatedDate = NSDate(timeIntervalSince1970: (updatedAt!/1000))
                                    let createdDate = NSDate(timeIntervalSince1970: (createdAt/1000))
                                    let endedDate = NSDate(timeIntervalSince1970: (endAt!))
                                    
                                    let post = Post(content: content, creator: creator, key: key, createdAt: updatedDate, name: username, joined: true, messageCount: 0, endAt: endedDate)
                                    
                                    if let found = find(self.posts.map({ $0.key }), eliminate) {
                                        let obj = self.posts[found]
                                        println(obj)
                                        println(found)
                                        self.posts.removeAtIndex(found)
                                    }
                                    
                                    
                                    self.posts.append(post)
                                    
                                    println(self.posts)
                                    println(post.key)
                                    
                                    
                                    // Sort posts in descending order
                                    self.posts.sort({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
                                    self.tableView.reloadData()
                                    

                                }
                            })
                            
                        }
                    }
                    }
                    
                }
            })
        })
    }
    
    func readNotifications() {
        let url = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/read/"
        let targetRef = Firebase(url: url)
        
        let leftImage = UIImage(named: "Profile")
        let leftBarButton = UIBarButtonItem(image: leftImage, style: UIBarButtonItemStyle.Plain, target: self, action: "pushRadarToProfile")
        
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        targetRef.observeEventType(.Value, withBlock: {
            snapshot in
            let read = snapshot.value as? Bool
            if read == false {
                var leftImage = UIImage(named: "ProfileNotification")
                leftImage = leftImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                let leftBarButton = UIBarButtonItem(image: leftImage, style: UIBarButtonItemStyle.Plain, target: self, action: "pushRadarToProfile")
                
                self.navigationItem.leftBarButtonItem = leftBarButton
            } else {
                let leftImage = UIImage(named: "Profile")
                let leftBarButton = UIBarButtonItem(image: leftImage, style: UIBarButtonItemStyle.Plain, target: self, action: "pushRadarToProfile")
                
                self.navigationItem.leftBarButtonItem = leftBarButton
            }
            
        })
    }
    

    
    func dataRemove() {
        
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/"
        let targetRef = Firebase(url: url)
        
        
        targetRef.observeEventType(.ChildRemoved, withBlock: {
            snapshot in
            let key = snapshot.key as? String
            if let found = find(self.posts.map({ $0.key }), snapshot.key) {
                let obj = self.posts[found]
                println(obj)
                println(found)
                self.posts.removeAtIndex(found)
            }
            var createdAt = snapshot.value["createdAt"] as? Int
            let endAt = snapshot.value["endAt"] as? Int
            
            if createdAt == nil {
                createdAt = 0
            }
            
            println(createdAt!/1000)
            println(endAt)
            let length = Int((endAt! - (createdAt!/1000)))
            println(length)
            println("childRemoved")
            
            let pointAddedUrl = "https://sonarapp.firebaseio.com/time/" + currentUser + "/posts/" + key! 
            let pointAddedRef = Firebase(url: pointAddedUrl)
            pointAddedRef.setValue(length)
            
            self.posts.sort({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
            self.tableView.reloadData()
        })
    }
    
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
    func returnSecondsToHoursMinutesSeconds (seconds:Int) -> (String) {
        let (h, m, s) = secondsToHoursMinutesSeconds (seconds)
        if h == 0 && m == 0{
            return "\(s)s"
        } else if h == 0 {
            return "\(m)m \(s)s"
        } else {
            return "\(h)h \(m)m \(s)s"
        }
    }
    
    func loadFriendData() {
        self.friendsArray.removeAll(keepCapacity: true)
        
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/friends/"
        let targetRef = Firebase(url: url)
        
        
        targetRef.queryOrderedByChild("username").observeEventType(.ChildAdded, withBlock: {
            snapshot in
            print(snapshot.key)
            let id = snapshot.key as? String
            let usernameUrl = "https://sonarapp.firebaseio.com/users/" + snapshot.key
            let usernameRef = Firebase(url: usernameUrl)
            usernameRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                // do some stuff once
                if let username = snapshot.value["username"] as? String {
                    self.friendsArray.append(username)
                    print(username)
                    self.idArray.append(id!)
                    self.tableView.reloadData()
                }
                
                
            })
        })
    }
    
    
    override func viewDidAppear(animated: Bool) {
        var nav = self.navigationController?.navigationBar
        let rightImage = UIImage(named: "WhitePulseSize")
        
        let rightBarButton = UIBarButtonItem(image: rightImage, style: UIBarButtonItemStyle.Plain, target: self, action: "pushRadarToPulse")
        
//        let leftImage = UIImage(named: "Profile")
//        let leftBarButton = UIBarButtonItem(image: leftImage, style: UIBarButtonItemStyle.Plain, target: self, action: "pushRadarToProfile")
//        
//        self.navigationItem.leftBarButtonItem = leftBarButton
        
        self.navigationItem.rightBarButtonItem = rightBarButton

        
        let topImage = UIImage(named: "WhiteBat")
        let imageView = UIImageView(image: topImage)
        imageView.frame = CGRectMake(0, 0, 59, 25)
        imageView.contentMode = .ScaleAspectFit
        
        
        nav!.topItem?.titleView = imageView
        
        self.loadName()
        
        self.tableView.reloadData()
    }
    
    func pushRadarToPulse(){
        self.performSegueWithIdentifier("presentCreatePulse", sender: nil)
    }
    
    func pushRadarToProfile(){
        self.performSegueWithIdentifier("presentProfile", sender: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/"
        let targetRef = Firebase(url: url)
        
        targetRef.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            println("clean")
            
            if let found = find(self.posts.map({ $0.key }), snapshot.key) {
                let obj = self.posts[found]
                println(obj)
                println(found)
                self.posts.removeAtIndex(found)
            }
        })
        
        self.tableView.reloadData()
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
//                self.tableView.tableFooterView = UIView(frame: CGRect.zeroRect)
                
                
                // Remove all posts when reloaded so it updates
                self.posts.removeAll(keepCapacity: true)
                
                self.dataRemove()
                
                self.getRadarData()
                self.getChangedRadarData()
                
                self.readNotifications()
                
                self.loadFriendData()
                self.loadName()
                
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
//        NSNotificationCenter.defaultCenter().removeObserver(self)
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
                        
                        let endedDate = NSDate(timeIntervalSince1970: (endTime!))
                        
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
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Friends List"
        } else {
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return posts.count
        } else if section == 1{
            return (friendsArray.count + 1)
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
        
        let cell: RadarTableViewCell = tableView.dequeueReusableCellWithIdentifier("radarCell", forIndexPath: indexPath) as! RadarTableViewCell
        
        let creator: (String) = posts[indexPath.row].creator
        let key = posts[indexPath.row].key
        
        let radarContent: (AnyObject) = posts[indexPath.row].content
        cell.textView.selectable = false
        cell.textView.text = radarContent as? String
        cell.textView.userInteractionEnabled = false
        
        cell.textView.selectable = true
        
        let url = "https://sonarapp.firebaseio.com/messageCount/" + currentUser + "/postsReceived/" + key
        let messageRef = Firebase(url: url)
        messageRef.observeEventType(.Value, withBlock: {
            snapshot in
            let myMessageCount = snapshot.value["myMessageCount"] as? Int
            let realMessageCount = snapshot.value["realMessageCount"] as? Int
            
            if myMessageCount < realMessageCount {
                cell.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
            } else {
                cell.backgroundColor = UIColor.whiteColor()
            }
            
        })
//        let date = posts[indexPath.row].createdAt
//        
//        cell.timeLabel.text = self.timeAgoSinceDate(date, numericDates: true)
        
        
        let endTime = posts[indexPath.row].endAt
        var timeLeft = endTime.timeIntervalSinceDate(NSDate())
//        cell.timeInterval = round(timeLeft)
        
        
        var timeInterval = endTime.timeIntervalSince1970
        cell.timeInterval = Int(timeInterval)
            
        // Need View Controller to segue in TableViewCell
        cell.viewController = self
        
        let radarCreator: (AnyObject) = posts[indexPath.row].name
        
        cell.nameLabel.text = radarCreator as? String

        return cell
        } else if indexPath.section == 1 {
            let cell: FriendScoreTableViewCell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendScoreTableViewCell
            
            if indexPath.row == 0 {
                
                cell.nameLabel.text = creatorname
                
                cell.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)
                
                let scoreUrl = "https://sonarapp.firebaseio.com/time/" + currentUser + "/posts/"
                let scoreRef = Firebase(url: scoreUrl)
                
                scoreRef.queryOrderedByValue().queryLimitedToLast(1).observeEventType(.ChildAdded, withBlock: {
                    snapshot in
                    let id = snapshot.key as? String
                    let score = snapshot.value as? Int
                    let scoreString = String(score!)
                    let scoreText = self.returnSecondsToHoursMinutesSeconds(score!)
                    
                    
                    if score == nil {
                        cell.scoreLabel.text = "ZzzzZzzzZzz"
                    } else {
                        cell.scoreLabel.text = scoreText
                    }
                    
                })
                
                cell.profileImageView.image = UIImage(named: "Placeholder.png")
                if let cachedImageResult = imageCache[currentUser] {
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
                    readRequest1.key =  currentUser
                    readRequest1.downloadingFileURL = downloadingFileURL1
                    
                    let task = transferManager.download(readRequest1)
                    task.continueWithBlock { (task) -> AnyObject! in
                        if task.error != nil {
                            println("No Profile Pic")
                        } else {
                            let image = UIImage(contentsOfFile: downloadingFilePath1)
                            let imageData = UIImageJPEGRepresentation(image, 1.0)
                            imageCache[currentUser] = imageData
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
            } else {
            var row = (indexPath.row-1)
            let friendName = friendsArray[indexPath.row-1]
            let id = idArray[indexPath.row-1]
            
            
            cell.nameLabel.text = friendName
            
            let scoreUrl = "https://sonarapp.firebaseio.com/time/" + id + "/posts/"
            let scoreRef = Firebase(url: scoreUrl)
            
            scoreRef.queryOrderedByValue().queryLimitedToLast(1).observeEventType(.ChildAdded, withBlock: {
                snapshot in
                let id = snapshot.key as? String
                let score = snapshot.value as? Int
                let scoreString = String(score!)
                let scoreText = self.returnSecondsToHoursMinutesSeconds(score!)
                
                cell.scoreLabel.text = scoreText
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
            }
            
            return cell
        } else {
            let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("addFriendCell") as! UITableViewCell
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 80
        } else if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        } else {
            return 55
        }
    }
    

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            performSegueWithIdentifier("showChat", sender: self)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        } else if indexPath.section == 2 {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let usernameButton = UIAlertAction(title: "Add by Username", style: UIAlertActionStyle.Default) { (alert) -> Void in
                
                self.performSegueWithIdentifier("showUsername", sender: self)
            }
            let addressBookButton = UIAlertAction(title: "Add from Address Book", style: UIAlertActionStyle.Default) { (alert) -> Void in
                    
                
                self.performSegueWithIdentifier("showAddressBook", sender: self)
                
            }

            let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
                print("Cancel Pressed")
            }
            
            alert.addAction(usernameButton)
            alert.addAction(addressBookButton)
            alert.addAction(cancelButton)
            self.presentViewController(alert, animated: true, completion: nil)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if editingStyle == .Delete {
                println("Delete")
                let post = posts[indexPath.row]
                
                let url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/" + post.key
                let targetRef = Firebase(url: url)
                targetRef.removeValue()
                
                let targetUrl = "https://sonarapp.firebaseio.com/posts/" + post.key + "/targets/" + currentUser
                let removeTargetRef = Firebase(url: targetUrl)
                removeTargetRef.removeValue()
                
                self.tableView.reloadData()
            }
        } else {
            
        }
        
        
    }
    
    
    
    
    

}
