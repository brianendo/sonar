//
//  AddFriendViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 8/24/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import Parse

class AddFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    let userRef = Firebase(url:"https://sonarapp.firebaseio.com/users")
    
    var firstnameArray = [String]()
    var friendArray = [AnyObject]()
    
    var creatorname = ""
    
    func loadName() {
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser
        let userRef = Firebase(url: url)
        
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let name = snapshot.value["name"] as? String {
                self.creatorname = name
            }
        })
    }
    
    func loadData() {
        userRef.queryOrderedByChild("name").observeEventType(.ChildAdded, withBlock: { snapshot in
            if let name = snapshot.value["name"] as? String {
                self.friendArray.append(snapshot.key)
                self.firstnameArray.append(name)
                self.tableView.reloadData()
                
            }
        })
        
    }
    
//    func removeCurrentUser() {
//        for friend in friendArray {
//            if friend as! String == currentUser{
//                deleteElement(friend)
//            }
//        }
//    }
//    
//    func deleteElement (element: AnyObject) {
//        friendArray = friendArray.filter() { $0 !== element }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        self.loadName()
        self.loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
//        self.tableView.reloadData()
//    
//        
//        self.loadData()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firstnameArray.count

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: AddFriendTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! AddFriendTableViewCell
        
        let friend = firstnameArray[indexPath.row]
        cell.nameLabel.text = friend
        
        
        
        cell.addButton.tag = indexPath.row
        cell.addButton.addTarget(self, action: "addButton:", forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    func addButton(sender: UIButton!) {
        let user: (AnyObject) = friendArray[sender.tag]
        
//        let url = "https://sonarapp.firebaseio.com/users/" +   currentUser + "/targets/"
//        
//        let currentUserRef = Firebase(url: url)
//        
//        currentUserRef.childByAppendingPath(user as! String).setValue(true)
        
        let userUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/added/"
        let userActivityRef = Firebase(url: userUrl)
        userActivityRef.childByAppendingPath(user as! String).setValue(true)
        
        let otherUserUrl = "https://sonarapp.firebaseio.com/user_activity/" + (user as! String) + "/addedme/"
        let otherUserActivityRef = Firebase(url: otherUserUrl)
        otherUserActivityRef.childByAppendingPath(currentUser).setValue(true)
        
        let pushURL = "https://sonarapp.firebaseio.com/users/" + (user as! String) + "/pushId"
        let pushRef = Firebase(url: pushURL)
        pushRef.observeEventType(.Value, withBlock: {
            snapshot in
            if snapshot.value is NSNull {
                println("Did not enable push notifications")
            } else {
                // Create our Installation query
                let pushQuery = PFInstallation.query()
                pushQuery?.whereKey("installationId", equalTo: snapshot.value)
                
                // Send push notification to query
                let push = PFPush()
                push.setQuery(pushQuery) // Set our Installation query
                let data = [
                    "alert": "\(self.creatorname) added you",
                    "badge": "Increment",
                ]
                push.setData(data)
                push.sendPushInBackground()
            }
        })
        
        print(user)
        print(currentUser)
    }

}
