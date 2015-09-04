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
    
    func tableViewTapped() {
        
        // Force the textfield to end editing
        self.sendMessageTextField.endEditing(true)
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        var postID = postVC?.key
        var messagesUrl = "https://sonarapp.firebaseio.com/messages/" + postID!
        var messagesRef = Firebase(url: messagesUrl)
        
        var newMessageText = self.sendMessageTextField.text
        var message1 = ["creator": currentUser, "content": newMessageText]
        
        let messages = messagesRef.childByAutoId()
        messages.setValue(message1)
        
        var messageID = messages.key
        
        var timeMessageUrl = "https://sonarapp.firebaseio.com/messages/" + postID! + "/" + messageID
        var timeMessageRef = Firebase(url: timeMessageUrl)
        timeMessageRef.childByAppendingPath("createdAt").setValue([".sv":"timestamp"])
        
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
        
        cell.contentLabel.text = messages[indexPath.row].content
        
        return cell
    }
    
    

    
    

}
