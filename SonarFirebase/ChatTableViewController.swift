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

class ChatTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    var postVC: Post?
    var postID: String?
    var messages = [Message]()
    
    var cellURL: NSURL?
    
    let placeholder = "Send Message"
    var messageCreatorName = ""
    var targetIdArray = [String]()
    
    @IBOutlet weak var sendMessageTextView: UITextView!
    
    @IBOutlet weak var verticalSpaceToDockView: NSLayoutConstraint!
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var dockViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var dockView: UIView!
    
    func loadName() {
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser
        let userRef = Firebase(url: url)
        
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let firstname = snapshot.value["firstname"] as? String {
                if let lastname = snapshot.value["lastname"] as? String {
                    let name = firstname + " " + lastname
                    self.messageCreatorName = name
                }
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
            }
        })
    }
    
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
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomLayoutConstraint.constant = keyboardFrame.size.height
            let insets: UIEdgeInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, keyboardFrame.size.height, 0)
            
            self.tableView.contentInset = insets
            self.tableView.scrollIndicatorInsets = insets
            
            self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + keyboardFrame.size.height)
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomLayoutConstraint.constant = 0
            let insets: UIEdgeInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, keyboardFrame.size.height, 0)
            
            self.tableView.contentInset = insets
            self.tableView.scrollIndicatorInsets = insets
        })
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        
        
        self.registerForKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        self.deregisterFromKeyboardNotifications()
        
    }

    
    func loadMessageData() {
//        let postID = postVC?.key
        let messagesUrl = "https://sonarapp.firebaseio.com/messages/" + postID!
        let messagesRef = Firebase(url: messagesUrl)
        
        messagesRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            if let content = snapshot.value["content"] as? String {
                if let creator = snapshot.value["creator"] as? String {
                    
                    let message = Message(content: content, creator: creator)
                    self.messages.append(message)
                    self.tableView.reloadData()
                }
            }
        })
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.sendMessageTextView.delegate = self
        self.sendButton.enabled = false
        self.sendMessageTextView.text = placeholder
        self.sendMessageTextView.textColor = UIColor.lightGrayColor()
        
        self.sendMessageTextView.selectedTextRange = self.sendMessageTextView.textRangeFromPosition(self.sendMessageTextView.beginningOfDocument, toPosition: self.sendMessageTextView.beginningOfDocument)
        
        // Add a tap gesture recognizer to the table view
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped")
        self.tableView.addGestureRecognizer(tapGesture)
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zeroRect)
        
        self.dockView.layer.masksToBounds = true
        self.dockView.layer.borderColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0).CGColor
        self.dockView.layer.borderWidth = 0.5
        self.tableView.reloadData()
        self.loadMessageData()
        self.loadName()
        self.loadTargetArray()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
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
        }
    }
    
    
    func tableViewTapped() {
        
        // Force the textfield to end editing
        self.sendMessageTextView.endEditing(true)
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        
        // Post Message to Firebase
//        let postID = postVC?.key
        let messagesUrl = "https://sonarapp.firebaseio.com/messages/" + postID!
        let messagesRef = Firebase(url: messagesUrl)
        let newMessageText = self.sendMessageTextView.text
        let message1 = ["creator": currentUser, "content": newMessageText]
        let messages = messagesRef.childByAutoId()
        messages.setValue(message1)
        
        // Get messageID
        let messageID = messages.key
        
        // Timestamp of Message
        let timeMessageUrl = "https://sonarapp.firebaseio.com/messages/" + postID! + "/" + messageID
        let timeMessageRef = Firebase(url: timeMessageUrl)
        timeMessageRef.childByAppendingPath("createdAt").setValue([".sv":"timestamp"])
        
        
        // Time updated of Message
        let postUpdatedUrl = "https://sonarapp.firebaseio.com/posts/" + postID!
        let postUpdatedRef = Firebase(url: postUpdatedUrl)
        postUpdatedRef.childByAppendingPath("updatedAt").setValue([".sv":"timestamp"])
        
        let index = find(self.targetIdArray, currentUser)
        self.targetIdArray.removeAtIndex(index!)
        println(targetIdArray)
        
        for target in targetIdArray {
            let pushURL = "https://sonarapp.firebaseio.com/users/" + target + "/pushId"
            let pushRef = Firebase(url: pushURL)
            pushRef.observeEventType(.Value, withBlock: {
                snapshot in
                if snapshot.value is NSNull {
                    println("Did not enable push notifications")
                } else {
                    println("Made it")
                    // Create our Installation query
                    let pushQuery = PFInstallation.query()
                    pushQuery?.whereKey("installationId", equalTo: snapshot.value)
                    
                    // Send push notification to query
                    let push = PFPush()
                    push.setQuery(pushQuery) // Set our Installation query
                    let data = [
                        "alert": "\(self.messageCreatorName): \(newMessageText)",
                        "badge": "Increment",
                        "post": self.postID!
                    ]
                    push.setData(data)
                    push.sendPushInBackground()
                    
                }
            })
        }
        
        // Call the end editing method for the text field
        self.sendMessageTextView.endEditing(true)
        self.sendMessageTextView.text = ""
        
        
        
    }
    
    // MARK: TextView Delegate Methods
    
    func textViewDidBeginEditing(textView: UITextView) {
        if self.view.window != nil {
            if sendMessageTextView.textColor == UIColor.lightGrayColor() {
                sendMessageTextView.selectedTextRange = sendMessageTextView.textRangeFromPosition(sendMessageTextView.beginningOfDocument, toPosition: sendMessageTextView.beginningOfDocument)
            }
        }

    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
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
            if let firstname = snapshot.value["firstname"] as? String {
                if let lastname = snapshot.value["lastname"] as? String {
                    cell.creatorLabel.text = firstname + " " + lastname
                }
            }
        })
        
        let messageContent: (AnyObject) = messages[indexPath.row].content
        
        cell.contentTextView.selectable = false
        cell.contentTextView.text = messageContent as? String
        cell.contentTextView.selectable = true
        
        // Need View Controller to segue in TableViewCell
        cell.viewController = self

        
        // Pull Profile Image from S3
        
        let downloadingFilePath1 = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp-download")
        let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        readRequest1.bucket = S3BucketName
        readRequest1.key =  messageCreator
        readRequest1.downloadingFileURL = downloadingFileURL1
        
        cell.profileImageView.image = UIImage(named: "Placeholder.png")
        let task = transferManager.download(readRequest1)
        task.continueWithBlock { (task) -> AnyObject! in
            print(task.error)
            if task.error != nil {
            } else {
                dispatch_async(dispatch_get_main_queue()
                    , { () -> Void in
//                        if let image = UIImage(contentsOfFile: downloadingFilePath1) {
//                            cell.profileImageView.image = image
//                        } else {
//                            // Default image or nil
//                            cell.profileImageView.image = nil
//                        }
                        
                        cell.profileImageView.image = UIImage(contentsOfFile: downloadingFilePath1)
                        
                        
                })
                print("Fetched image")
            }
            return nil
        }
        
        return cell
    }
    
    
    

    
    

}
