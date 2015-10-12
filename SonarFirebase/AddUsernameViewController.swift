//
//  AddUsernameViewController.swift
//  Sonar
//
//  Created by Brian Endo on 10/1/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Parse
import Firebase

class AddUsernameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating {

    
    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController!
    
    var username: Username!
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
    
    override func viewWillDisappear(animated: Bool) {
        self.searchController.active = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add by Username"
        
        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.loadName()
        
        self.searchController = UISearchController(searchResultsController: nil)
        
        self.searchController.searchResultsUpdater = self
        
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        self.searchController.searchBar.sizeToFit()
        
        self.searchController.searchBar.scopeButtonTitles = nil
        
        self.tableView.tableHeaderView = self.searchController.searchBar

        self.searchController.searchBar.delegate = self
        
        self.definesPresentationContext = false
        
        self.searchController.searchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: AddUsernameTableViewCell = tableView.dequeueReusableCellWithIdentifier("usernameCell", forIndexPath: indexPath) as! AddUsernameTableViewCell
        
        if username == nil {
            cell.toggleButton.hidden = true
            cell.nameLabel.text = ""
        } else {
            cell.toggleButton.hidden = false
            cell.nameLabel.text = username.username
            let addMeUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/added/" + username.firebaseId
            let addMeRef = Firebase(url: addMeUrl)
            addMeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                let added = snapshot.value as? Bool
                if added == true {
                    cell.toggleButton.selected = true
                } else {
                    cell.toggleButton.selected = false
                }
            })
        }
        
        
        
        
        cell.toggleButton.tag = indexPath.row
        cell.toggleButton.addTarget(self, action: "toggleButton:", forControlEvents: .TouchUpInside)
        cell.toggleButton.setTitle("Added", forState: .Selected)
        cell.toggleButton.setTitle("Add", forState: .Normal)
        
        return cell
    }
    
    func toggleButton(sender: UIButton){
        let searchedUser = username.firebaseId
        
        if sender.selected == false {
            sender.selected = true
            
            let userUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/added/"
            let userActivityRef = Firebase(url: userUrl)
            userActivityRef.childByAppendingPath(searchedUser).setValue(true)
            
            let otherUserUrl = "https://sonarapp.firebaseio.com/user_activity/" + (searchedUser) + "/addedme/"
            let otherUserActivityRef = Firebase(url: otherUserUrl)
            otherUserActivityRef.childByAppendingPath(currentUser).setValue(true)
            
            let readUrl = "https://sonarapp.firebaseio.com/user_activity/" + (searchedUser) + "/read/"
            let readRef = Firebase(url: readUrl)
            readRef.setValue(false)
            
            let pushURL = "https://sonarapp.firebaseio.com/users/" + (searchedUser) + "/pushId"
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
        } else {
            sender.selected = false
            
            let userUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/added/" + searchedUser
            let userActivityRef = Firebase(url: userUrl)
            userActivityRef.removeValue()
            
            let otherUserUrl = "https://sonarapp.firebaseio.com/user_activity/" + (searchedUser) + "/addedme/" + currentUser
            let otherUserActivityRef = Firebase(url: otherUserUrl)
            otherUserActivityRef.removeValue()
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = self.searchController.searchBar.text
        self.filterContentForSearch(searchString)
        self.tableView.reloadData()
    }
    
    func filterContentForSearch (searchText: String) {
        let searchTextLowercase = searchText.lowercaseString
        
        var user = PFQuery(className:"FirebaseUser")
        user.whereKey("username", equalTo: searchTextLowercase)
        
        user.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                if objects!.count > 0 {
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            println(object.objectForKey("firebaseId"))
                            println(object.objectForKey("name"))
                            let name = object.objectForKey("name") as! String
                            let firebaseId = object.objectForKey("firebaseId") as! String
                            let searchedUsername = searchTextLowercase
                            self.username = Username(username: searchedUsername, firebaseId: firebaseId)
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    println("No user")
                    self.username = nil
                    self.tableView.reloadData()
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }
    

}
