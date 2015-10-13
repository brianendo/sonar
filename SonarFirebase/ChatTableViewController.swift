//
//  ChatTableViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 9/2/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase
import Parse
import AWSS3

class ChatTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    var postVC: Post?
    var postID: String?
    var messages = [Message]()
    var postContent: String?
    
    var cellURL: NSURL?
    
    let placeholder = "Send Message"
    var messageCreatorName = ""
    var targetIdArray = [String]()
    var creatorArray = [String]()
    
    var timer: NSTimer!
    
    var targetCount = ""
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTextView: UITextView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    
    @IBOutlet weak var sendMessageTextView: UITextView!
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var dockView: UIView!

    
    
    func registerForKeyboardNotifications ()-> Void   {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        
    }
    
    func deregisterFromKeyboardNotifications () -> Void {
        let center:  NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.05, animations: { () -> Void in
            self.bottomLayoutConstraint.constant = keyboardFrame.size.height
            let insets: UIEdgeInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, 0, 0)
            
            self.tableView.contentInset = insets
            self.tableView.scrollIndicatorInsets = insets
            
            self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + keyboardFrame.size.height)
            self.tableViewScrollToBottom(true)
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.05, animations: { () -> Void in
            self.bottomLayoutConstraint.constant = 0
            let insets: UIEdgeInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, 0, 0)
            
            self.tableView.contentInset = insets
            self.tableView.scrollIndicatorInsets = insets
            self.tableViewScrollToBottom(true)
        })
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.messageCountUpdate()
        
        self.deregisterFromKeyboardNotifications()
        
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
    
//    var timeInterval: Int = 0 {
//        didSet {
//            if timeInterval > 60 {
//                let time = Int(timeInterval/60)
//                let timeString = returnSecondsToHoursMinutesSeconds(timeInterval)
//                self.timeLeftLabel.text = timeString
//            } else if timeInterval <= 60 {
//                let time = Int(timeInterval)
//                self.timeLeftLabel.text = "\(time)s"
//            } else if timeInterval <= 1 {
//                self.navigationController?.popViewControllerAnimated(true)
//                self.timeLeftLabel.text = "Dead"
//            }
//        }
//    }
    
//    func updateLabel() {
//        if self.timeInterval > 1 {
//            --self.timeInterval
//        } else if self.timeInterval <= 1 {
//            self.timeLeftLabel.text = "Dead"
//            self.navigationController?.popViewControllerAnimated(true)
//        }
//    }
    
    var timeInterval: Int = 0 {
        didSet {
            var value = (timeInterval - Int(NSDate().timeIntervalSince1970))
            if value > 60 {
                let time = Int(value/60)
                let timeString = returnSecondsToHoursMinutesSeconds(value)
                self.timeLeftLabel.text = timeString
            } else if (value <= 60 && value > 0) {
                let time = Int(value)
                self.timeLeftLabel.text = "\(time)s"
            }else if value <= 0 {
                self.timeLeftLabel.text = "Dead"
            }
        }
    }
    
    func updateLabel() {
        if (self.timeInterval - Int(NSDate().timeIntervalSince1970)) > 0 {
            self.timeInterval = (self.timeInterval - 0)
        } else if (self.timeInterval - Int(NSDate().timeIntervalSince1970)) <= 0 {
            self.timeLeftLabel.text = "Dead"
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func fireUpdate() {
        let notification = NSNotification(name: "UpdateChatView", object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    func loadPostData() {
        let postUpdatedUrl = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/" + self.postID!
        let postUpdatedRef = Firebase(url: postUpdatedUrl)
        
        postUpdatedRef.observeEventType(.Value, withBlock: {
            snapshot in
            var endAt = snapshot.value["endAt"] as? NSTimeInterval
            
            let postUrl = "https://sonarapp.firebaseio.com/posts/" + self.postID!
            let postRef = Firebase(url: postUrl)
            
            postRef.observeEventType(.Value, withBlock: {
                snapshot in
                if let content = snapshot.value["content"] as? String {
                    if let creator = snapshot.value["creator"] as? String {
                        let url = "https://sonarapp.firebaseio.com/users/" + creator
                        let userRef = Firebase(url: url)
                        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                            if let username = snapshot.value["username"] as? String {
                                println(endAt)
                                if endAt == nil {
                                    endAt = 0
                                }
                                let endedDate = NSDate(timeIntervalSince1970: (endAt!))
                                var timeLeft = endedDate.timeIntervalSinceDate(NSDate())
                                
                                var timeInterval = endedDate.timeIntervalSince1970
                                
                                self.timeInterval = Int(timeInterval)
                                self.nameLabel.text = username
                                self.headerTextView.text = content
                                self.tableView.reloadData()
                            }
                        })
                    }
                    
                }
            })
            
        })
    }
    
    func loadMessageData() {
        let messagesUrl = "https://sonarapp.firebaseio.com/messages/" + postID!
        let messagesRef = Firebase(url: messagesUrl)
        
        messagesRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            if let creator = snapshot.value["creator"] as? String {
                if let content = snapshot.value["content"] as? String {
                    let message = Message(content: content, creator: creator)
                    self.messages.append(message)
                    self.tableView.reloadData()
                }
            }
        })
        
    }
    
    
    func messageCountUpdate() {
        
        let messagesCount = "https://sonarapp.firebaseio.com/messageCount/" + currentUser + "/postsReceived/" + self.postID! + "/realMessageCount/"
        var messagesCountRef = Firebase(url: messagesCount)
        
        messagesCountRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let count = snapshot.value as? Int {
                
                let userMessageCount = "https://sonarapp.firebaseio.com/messageCount/" + currentUser + "/postsReceived/" + self.postID! + "/myMessageCount/"
                let userMessageRef = Firebase(url: userMessageCount)
                userMessageRef.setValue(count)
                self.tableView.reloadData()
            }
        })
        
    }
    
    
    // Change message count
    func messageCountWhenLoading() {
        
        let messagesCount = "https://sonarapp.firebaseio.com/posts/" + self.postID! + "/messageCount/"
        var messagesCountRef = Firebase(url: messagesCount)
        
        messagesCountRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let count = snapshot.value as? Int {
                
                let userMessageCount = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/" + self.postID! + "/messageCount/"
                let userMessageRef = Firebase(url: userMessageCount)
                userMessageRef.setValue(count)
                self.tableView.reloadData()
            }
        })
        
    }

    
    func messageCountWhenInChat() {
        
        // Add messagesCount
        let postUpdated = "https://sonarapp.firebaseio.com/posts/" + postID!
        var postUpdatedRef = Firebase(url: postUpdated)
        
        postUpdatedRef.observeEventType(.ChildChanged, withBlock: {
            snapshot in
            let messagesCount = "https://sonarapp.firebaseio.com/posts/" + self.postID! + "/messageCount/"
            var messagesCountRef = Firebase(url: messagesCount)
            
            messagesCountRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let count = snapshot.value as? Int {
                    let userMessageCount = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/" + self.postID! + "/messageCount/"
                    let userMessageRef = Firebase(url: userMessageCount)
                    userMessageRef.setValue(count)
                    self.tableView.reloadData()
                }
            })
            

        })
        
    }
    
    func loadName() {
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser
        let userRef = Firebase(url: url)
        
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let username = snapshot.value["username"] as? String {
                
                    self.messageCreatorName = username
                    self.tableView.reloadData()
            }
        })
    }
    
    func loadTargetArray() {
        let targetUrl = "https://sonarapp.firebaseio.com/posts/" + postID! + "/targets"
        let targetRef = Firebase(url: targetUrl)
        targetRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            if let key = snapshot.key as? String {
                self.targetIdArray.append(key)
                self.tableView.reloadData()
            }
        })
    }
    
    func removeFromTargetArray() {
        let targetUrl = "https://sonarapp.firebaseio.com/posts/" + postID! + "/targets"
        let targetRef = Firebase(url: targetUrl)
        targetRef.observeEventType(.ChildRemoved, withBlock: {
            snapshot in
            if let key = snapshot.key as? String {
                if let found = find(self.targetIdArray.map({ $0 }), key) {
                    let obj = self.targetIdArray[found]
                    println(obj)
                    println(found)
                    self.targetIdArray.removeAtIndex(found)
                    self.tableView.reloadData()
                }
                
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.title = "Chat"
        
        self.sendMessageTextView.delegate = self
        
        self.sendMessageTextView.text = placeholder
        self.sendMessageTextView.textColor = UIColor.lightGrayColor()
        
        self.sendMessageTextView.selectedTextRange = self.sendMessageTextView.textRangeFromPosition(self.sendMessageTextView.beginningOfDocument, toPosition: self.sendMessageTextView.beginningOfDocument)
        
        self.sendButton.enabled = false
        
        // Add a tap gesture recognizer to the table view
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped")
        self.tableView.addGestureRecognizer(tapGesture)
        self.tableView.tableFooterView = UIView(frame: CGRect.zeroRect)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70
        
        
        
        self.messageCountUpdate()
        self.loadMessageData()
        self.loadName()
        self.loadTargetArray()
        
        self.loadPostData()
        
        self.removeFromTargetArray()
        
        self.headerTextView.delegate = self
        
        self.headerView.layer.masksToBounds = true
        self.headerView.layer.borderColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0).CGColor
        self.headerView.layer.borderWidth = 0.7
        
        self.dockView.layer.masksToBounds = true
        self.dockView.layer.borderColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0).CGColor
        self.dockView.layer.borderWidth = 0.5
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70
        
        self.tableViewScrollToBottom(true)
        
//        self.targetCount = String(self.targetIdArray.count)
//        self.navigationItem.leftBarButtonItem?.title = self.targetCount
        
//        let notificationCenter = NSNotificationCenter.defaultCenter()
//        notificationCenter.removeObserver(self)
//        notificationCenter.addObserver(self, selector: Selector("updateLabel"), name: "UpdateChatView", object: nil)
//        
//        self.timer = NSTimer(timeInterval: 1.0, target: self, selector: Selector("fireUpdate"), userInfo: nil, repeats: true)
//        
//        
//        NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateLabel"), userInfo: nil, repeats: true)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override func viewDidDisappear(animated: Bool) {
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Segue to WebView
        if segue.identifier == "presentWebViewFromChat" {
            // Go to nav controller then webVC
            let nav = segue.destinationViewController as! UINavigationController
            let webVC: WebViewController = nav.topViewController as! WebViewController
            
            webVC.urlToLoad = cellURL
        } else if segue.identifier == "showChatInfo" {
            let chatInfoVC = segue.destinationViewController as! ChatInfoViewController
            chatInfoVC.idArray = targetIdArray
            chatInfoVC.creatorname = self.messageCreatorName
            chatInfoVC.postID = self.postID!
        }
    }
    
    @IBAction func chatInfoBarButtonPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("showChatInfo", sender: self)
    }
    
    
    func loadHeaderView() {
        self.headerTextView.text = self.postContent
    }
    
    
    func tableViewTapped() {
        
        // Force the textfield to end editing
        self.sendMessageTextView.endEditing(true)
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        
        // Time updated of Post
        let postUpdatedUrl = "https://sonarapp.firebaseio.com/posts/" + postID! 
        let postUpdatedRef = Firebase(url: postUpdatedUrl)
        let updatedAt = ["updatedAt": [".sv":"timestamp"] ]
        postUpdatedRef.updateChildValues(updatedAt)
        
        
        // Post Message to Firebase
        let messagesUrl = "https://sonarapp.firebaseio.com/messages/" + postID!
        let messagesRef = Firebase(url: messagesUrl)
        let newMessageText = self.sendMessageTextView.text
        let message1 = ["creator": currentUser, "content": newMessageText, "createdAt": [".sv":"timestamp"]]
        let messages = messagesRef.childByAutoId()
        messages.setValue(message1)
        
        println(targetIdArray)
        println(targetIdArray.count)
        
        for target in targetIdArray {
            let pushURL = "https://sonarapp.firebaseio.com/users/" + target + "/pushId"
            let pushRef = Firebase(url: pushURL)
            
//            pushRef.observeSingleEventOfType(.Value, withBlock: {
//                snapshot in
//                if snapshot.value is NSNull {
//                    println("Did not enable push notifications")
//                } else {
//                    println("Made it")
//                    
//                    if target == currentUser {
//                        
//                    } else {
//                    
//                    // Create our Installation query
//                    let pushQuery = PFInstallation.query()
//                    pushQuery?.whereKey("installationId", equalTo: snapshot.value)
//                    
//                    // Send push notification to query
//                    let push = PFPush()
//                    push.setQuery(pushQuery) // Set our Installation query
//                    let data = [
//                        "alert": "\(self.messageCreatorName): \(newMessageText)",
//                        "badge": "Increment",
//                        "post": self.postID!
//                    ]
//                    push.setData(data)
//                    push.sendPushInBackground()
//                    }
//                }
//            })
            
            let messageCount = "https://sonarapp.firebaseio.com/messageCount/" + target + "/postsReceived/" + self.postID! + "/realMessageCount/"
            var messageCountRef = Firebase(url: messageCount)
            
            messageCountRef.observeSingleEventOfType(.Value, withBlock: {
                snapshot in
                let count = snapshot.value as? Int
                let messageCount = count! + 1
                
                let postReceivedUrl = "https://sonarapp.firebaseio.com/users/" + target + "/postsReceived/" + self.postID!
                let postReceivedRef = Firebase(url: postReceivedUrl)
                
                let newMessageCount = "https://sonarapp.firebaseio.com/messageCount/" + target + "/postsReceived/" + self.postID! + "/realMessageCount/"
                var newMessageCountRef = Firebase(url: newMessageCount)
                newMessageCountRef.setValue(messageCount)
                
                let timeLeft = (self.timeInterval - Int(NSDate().timeIntervalSince1970))
                println(timeLeft)
                
                let timeInterval = self.timeInterval
                
                if messageCount <= 1 {
                    if timeLeft <= 3300 {
                        let firstCounter = (60*5)
                        let newEndDate = Int((self.timeInterval + firstCounter))
                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
                        
                        let timeremaining = timeLeft + firstCounter
                        let timeremainingString = self.returnSecondsToHoursMinutesSeconds(timeremaining)
                        
                        pushRef.observeSingleEventOfType(.Value, withBlock: {
                            snapshot in
                            if snapshot.value is NSNull {
                                println("Did not enable push notifications")
                            } else {
                                println("Made it")
                                
                                if target == currentUser {
                                    
                                } else {
                                    
                                    // Create our Installation query
                                    let pushQuery = PFInstallation.query()
                                    pushQuery?.whereKey("installationId", equalTo: snapshot.value)
                                    
                                    // Send push notification to query
                                    let push = PFPush()
                                    push.setQuery(pushQuery) // Set our Installation query
                                    let data = [
                                        "alert": "\(self.messageCreatorName) (\(timeremainingString)): \(newMessageText)",
                                        "badge": "Increment",
                                        "post": self.postID!
                                    ]
                                    push.setData(data)
                                    push.sendPushInBackground()
                                }
                            }
                        })
                    } else {
                        let overTimeLeft = timeLeft - 3300
                        let firstCounter = (60*5) - overTimeLeft
                        let newEndDate = Int((self.timeInterval + firstCounter))
                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
                        
                        let timeremaining = timeLeft + firstCounter
                        let timeremainingString = self.returnSecondsToHoursMinutesSeconds(timeremaining)
                        
                        pushRef.observeSingleEventOfType(.Value, withBlock: {
                            snapshot in
                            if snapshot.value is NSNull {
                                println("Did not enable push notifications")
                            } else {
                                println("Made it")
                                
                                if target == currentUser {
                                    
                                } else {
                                    
                                    // Create our Installation query
                                    let pushQuery = PFInstallation.query()
                                    pushQuery?.whereKey("installationId", equalTo: snapshot.value)
                                    
                                    // Send push notification to query
                                    let push = PFPush()
                                    push.setQuery(pushQuery) // Set our Installation query
                                    let data = [
                                        "alert": "\(self.messageCreatorName) (1h): \(newMessageText)",
                                        "badge": "Increment",
                                        "post": self.postID!
                                    ]
                                    push.setData(data)
                                    push.sendPushInBackground()
                                }
                            }
                        })
                    }
                } else {
                    if timeLeft <= 3420 {
                        let firstCounter = (60*3)
                        let newEndDate = Int((self.timeInterval + firstCounter))
                        
                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
                        
                        let timeremaining = timeLeft + firstCounter
                        let timeremainingString = self.returnSecondsToHoursMinutesSeconds(timeremaining)
                        
                        pushRef.observeSingleEventOfType(.Value, withBlock: {
                            snapshot in
                            if snapshot.value is NSNull {
                                println("Did not enable push notifications")
                            } else {
                                println("Made it")
                                
                                if target == currentUser {
                                    
                                } else {
                                    
                                    // Create our Installation query
                                    let pushQuery = PFInstallation.query()
                                    pushQuery?.whereKey("installationId", equalTo: snapshot.value)
                                    
                                    // Send push notification to query
                                    let push = PFPush()
                                    push.setQuery(pushQuery) // Set our Installation query
                                    let data = [
                                        "alert": "\(self.messageCreatorName) (\(timeremainingString)): \(newMessageText)",
                                        "badge": "Increment",
                                        "post": self.postID!
                                    ]
                                    push.setData(data)
                                    push.sendPushInBackground()
                                }
                            }
                        })
                    } else {
                        let overTimeLeft = timeLeft - 3420
                        let firstCounter = (60*3) - overTimeLeft
                        let newEndDate = Int((self.timeInterval + firstCounter))
                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
                        
                        let timeremaining = timeLeft + firstCounter
                        let timeremainingString = self.returnSecondsToHoursMinutesSeconds(timeremaining)
                        
                        pushRef.observeSingleEventOfType(.Value, withBlock: {
                            snapshot in
                            if snapshot.value is NSNull {
                                println("Did not enable push notifications")
                            } else {
                                println("Made it")
                                
                                if target == currentUser {
                                    
                                } else {
                                    
                                    // Create our Installation query
                                    let pushQuery = PFInstallation.query()
                                    pushQuery?.whereKey("installationId", equalTo: snapshot.value)
                                    
                                    // Send push notification to query
                                    let push = PFPush()
                                    push.setQuery(pushQuery) // Set our Installation query
                                    let data = [
                                        "alert": "\(self.messageCreatorName) (1h): \(newMessageText)",
                                        "badge": "Increment",
                                        "post": self.postID!
                                    ]
                                    push.setData(data)
                                    push.sendPushInBackground()
                                }
                            }
                        })
                    }
                }
                
                
//                if messageCount <= 4 {
//                    if timeLeft <= 2700 {
//                        let firstCounter = (60*15)
//                        let newEndDate = Int((self.timeInterval + firstCounter) * 1000)
//                        println("Reached")
//                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
//                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
//                    } else {
//                        let overTimeLeft = timeLeft - 2700
//                        let firstCounter = (60*15) - overTimeLeft
//                        let newEndDate = Int((self.timeInterval + firstCounter) * 1000)
//                        println("Over Reached")
//                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
//                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
//                    }
//                } else if (messageCount > 4 && messageCount <= 10) {
//                    if timeLeft <= 3000 {
//                        let firstCounter = (60*10)
//                        let newEndDate = Int((self.timeInterval + firstCounter) * 1000)
//                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
//                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
//                    } else {
//                        let overTimeLeft = timeLeft - 3000
//                        let firstCounter = (60*10) - overTimeLeft
//                        let newEndDate = Int((self.timeInterval + firstCounter) * 1000)
//                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
//                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
//                    }
//                } else {
//                    if timeLeft <= 3300 {
//                        let firstCounter = (60*5)
//                        let newEndDate = Int((self.timeInterval + firstCounter) * 1000)
//                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
//                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
//                    } else {
//                        let overTimeLeft = timeLeft - 3300
//                        let firstCounter = (60*5) - overTimeLeft
//                        let newEndDate = Int((self.timeInterval + firstCounter) * 1000)
//                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
//                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
//                    }
//                }
            })
            

//            // Add messageCount
//            let messageCount = "https://sonarapp.firebaseio.com/messageCount/" + target + "/postsReceived/" + self.postID! + "/realMessageCount/"
//            var messageCountRef = Firebase(url: messageCount)
//            
//            messageCountRef.runTransactionBlock({
//                (currentData:FMutableData!) in
//                var value = currentData.value as? Int
//                if value == nil {
//                    value = 0
//                }
//                currentData.value = value! + 1
//                println("added counter to the post")
//                
//                let messageCount = currentData.value as? Int
//                
//                println(messageCount)
//                println(target)
//                
//                let postReceivedUrl = "https://sonarapp.firebaseio.com/users/" + target + "/postsReceived/" + self.postID!
//                let postReceivedRef = Firebase(url: postReceivedUrl)
//                
//                
//                let dateNow = NSDate().timeIntervalSince1970 * 1000
//                let dateLater = (NSDate().timeIntervalSince1970 + (60*15)) * 1000
//                let quickDate = Int((NSDate().timeIntervalSince1970 + (60*30)) * 1000)
//                
//                let timeLeft = (self.timeInterval - Int(NSDate().timeIntervalSince1970))
//                println(timeLeft)
//                
//                if messageCount <= 4 {
//                    if timeLeft <= 2700 {
//                        let firstCounter = (60*15)
//                        let newEndDate = Int((self.timeInterval + firstCounter) * 1000)
//                        println("Reached")
//                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
//                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
//                    } else {
//                        let overTimeLeft = timeLeft - 2700
//                        let firstCounter = (60*15) - overTimeLeft
//                        let newEndDate = Int((self.timeInterval + firstCounter) * 1000)
//                        println("Over Reached")
//                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
//                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
//                    }
//                } else if (messageCount > 4 && messageCount <= 10) {
//                    if timeLeft <= 3000 {
//                        let firstCounter = (60*10)
//                        let newEndDate = Int((self.timeInterval + firstCounter) * 1000)
//                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
//                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
//                    } else {
//                        let overTimeLeft = timeLeft - 3000
//                        let firstCounter = (60*10) - overTimeLeft
//                        let newEndDate = Int((self.timeInterval + firstCounter) * 1000)
//                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
//                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
//                    }
//                } else {
//                    if timeLeft <= 3300 {
//                        let firstCounter = (60*5)
//                        let newEndDate = Int((self.timeInterval + firstCounter) * 1000)
//                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
//                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
//                    } else {
//                        let overTimeLeft = timeLeft - 3300
//                        let firstCounter = (60*5) - overTimeLeft
//                        let newEndDate = Int((self.timeInterval + firstCounter) * 1000)
//                        let updates = ["updatedAt": [".sv":"timestamp"], "endAt": newEndDate]
//                        postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
//                    }
//                }
//                
//                
////                if messageCount == 0 {
////                    println("stop")
////                } else if messageCount == 1{
////                    let updates = ["updatedAt": [".sv":"timestamp"], "endAt": quickDate]
////                    postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
////                } else {
////                    let updates = ["updatedAt": [".sv":"timestamp"], "endAt": quickDate]
////                    postReceivedRef.updateChildValues(updates as [NSObject : AnyObject])
////                }
//                
//                return FTransactionResult.successWithValue(currentData)
//            })
            
        }

        
        // Call the end editing method for the text field
        self.sendMessageTextView.endEditing(true)
        
        self.sendMessageTextView.text = placeholder
        self.sendMessageTextView.textColor = UIColor.lightGrayColor()
        
        self.sendMessageTextView.selectedTextRange = self.sendMessageTextView.textRangeFromPosition(self.sendMessageTextView.beginningOfDocument, toPosition: self.sendMessageTextView.beginningOfDocument)
        self.sendButton.enabled = false
        
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        self.tableViewScrollToBottom(true)
    }
    
    // MARK: TextView Delegate Methods
    
    func textViewDidBeginEditing(textView: UITextView) {
        if self.view.window != nil {
            if sendMessageTextView.textColor == UIColor.lightGrayColor() {
                sendMessageTextView.selectedTextRange = sendMessageTextView.textRangeFromPosition(sendMessageTextView.beginningOfDocument, toPosition: sendMessageTextView.beginningOfDocument)
            }
        }

    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = self.sendMessageTextView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            self.sendMessageTextView.text = placeholder
            self.sendMessageTextView.textColor = UIColor.lightGrayColor()
            
            self.sendMessageTextView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            self.sendButton.enabled = false
            
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if self.sendMessageTextView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
            self.sendMessageTextView.text = nil
            self.sendMessageTextView.textColor = UIColor.blackColor()
            
        }
        return true
        
    }
    
    func textViewDidChange(textView: UITextView) {
        let trimmedString = sendMessageTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if count(trimmedString) == 0 {
            self.sendButton.enabled = false
        } else {
            self.sendButton.enabled = true
        }
    }
    
    
    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if sendMessageTextView.textColor == UIColor.lightGrayColor() {
                sendMessageTextView.selectedTextRange = sendMessageTextView.textRangeFromPosition(sendMessageTextView.beginningOfDocument, toPosition: sendMessageTextView.beginningOfDocument)
            }
        }
        
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        // Use RadarViewController and access its variables
        
        self.cellURL = URL
        self.performSegueWithIdentifier("presentWebViewFromChat", sender: self)
        return false
        
    }
    
    // MARK: TableView Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ChatTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ChatTableViewCell
        
        let messageCreator = messages[indexPath.row].creator

        let userurl = "https://sonarapp.firebaseio.com/users/" + (messageCreator as String)
        let userRef = Firebase(url: userurl)
        
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let username = snapshot.value["username"] as? String {
                    cell.creatorLabel.text = username
            }
        })
        
        let messageContent: (AnyObject) = messages[indexPath.row].content
        
        cell.contentTextView.selectable = false
        cell.contentTextView.text = messageContent as? String
        cell.contentTextView.selectable = true
        
        
        // Need View Controller to segue in TableViewCell
        cell.viewController = self
        
        
        cell.profileImageView.image = UIImage(named: "Placeholder.png")
        if let cachedImageResult = imageCache[messageCreator] {
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
            readRequest1.key =  messageCreator
            readRequest1.downloadingFileURL = downloadingFileURL1
            
            let task = transferManager.download(readRequest1)
            task.continueWithBlock { (task) -> AnyObject! in
                if task.error != nil {
                    print(task.error)
                } else {
                    let image = UIImage(contentsOfFile: downloadingFilePath1)
                    let imageData = UIImageJPEGRepresentation(image, 1.0)
                    imageCache[messageCreator] = imageData
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
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    

    func tableViewScrollToBottom(animated: Bool) {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            let numberOfSections = self.tableView.numberOfSections()
            let numberOfRows = self.tableView.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
            }
            
        })
    }

    

    
    

}
