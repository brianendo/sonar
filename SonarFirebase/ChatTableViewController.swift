//
//  ChatTableViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 9/2/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase

class ChatTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    var postVC: Post?
    var messages = [Message]()
    
    var cellURL: NSURL?
    
    @IBOutlet weak var sendMessageTextField: UITextField!
    
    @IBOutlet weak var dockViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var dockView: UIView!
    
    func loadMessageData() {
        var postID = postVC?.key
        var messagesUrl = "https://sonarapp.firebaseio.com/messages/" + postID!
        var messagesRef = Firebase(url: messagesUrl)
        
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
        
        self.sendMessageTextField.delegate = self

        // Add a tap gesture recognizer to the table view
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped")
        self.tableView.addGestureRecognizer(tapGesture)
        
        self.tableView.reloadData()
        self.loadMessageData()
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
        self.sendMessageTextField.endEditing(true)
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        
        // Post Message to Firebase
        var postID = postVC?.key
        var messagesUrl = "https://sonarapp.firebaseio.com/messages/" + postID!
        var messagesRef = Firebase(url: messagesUrl)
        var newMessageText = self.sendMessageTextField.text
        var message1 = ["creator": currentUser, "content": newMessageText]
        let messages = messagesRef.childByAutoId()
        messages.setValue(message1)
        
        // Get messageID
        var messageID = messages.key
        
        // Timestamp of Message
        var timeMessageUrl = "https://sonarapp.firebaseio.com/messages/" + postID! + "/" + messageID
        var timeMessageRef = Firebase(url: timeMessageUrl)
        timeMessageRef.childByAppendingPath("createdAt").setValue([".sv":"timestamp"])
        
        
        // Time updated of Message
        var postUpdatedUrl = "https://sonarapp.firebaseio.com/posts/" + postID!
        var postUpdatedRef = Firebase(url: postUpdatedUrl)
        postUpdatedRef.childByAppendingPath("updatedAt").setValue([".sv":"timestamp"])
        
        // Call the end editing method for the text field
        self.sendMessageTextField.endEditing(true)
        self.sendMessageTextField.text = ""
        
    }
    
    // MARK: TextField Delegate Methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        // Perform an animation to grow the dockView
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.4, animations: {
            
            self.dockViewHeightConstraint.constant = 275
            self.view.layoutIfNeeded()
            
            }, completion: nil)
        
//        var pointInTable:CGPoint = dockView.superview!.convertPoint(dockView.frame.origin, toView: tableView)
//        var contentOffset:CGPoint = tableView.contentOffset
//        contentOffset.y  = pointInTable.y
//        if let accessoryView = dockView.inputAccessoryView {
//            contentOffset.y -= accessoryView.frame.size.height
//        }
//        tableView.contentOffset = contentOffset

    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        // Perform an animation to grow the dockView
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.2, animations: {
            
            self.dockViewHeightConstraint.constant = 60
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    // MARK: TableView Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ChatTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ChatTableViewCell
        
        var messageCreator = messages[indexPath.row].creator
        
        var userurl = "https://sonarapp.firebaseio.com/users/" + (messageCreator as String)
        var userRef = Firebase(url: userurl)
        
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
        
        let downloadingFilePath1 = NSTemporaryDirectory().stringByAppendingPathComponent("temp-download")
        let downloadingFileURL1 = NSURL(fileURLWithPath: downloadingFilePath1 )
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        let readRequest1 : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        readRequest1.bucket = S3BucketName
        readRequest1.key =  messageCreator
        readRequest1.downloadingFileURL = downloadingFileURL1
        
        cell.profileImageView.image = nil
        let task = transferManager.download(readRequest1)
        task.continueWithBlock { (task) -> AnyObject! in
            println(task.error)
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
                println("Fetched image")
            }
            return nil
        }
        
        return cell
    }
    
    
    

    
    

}
