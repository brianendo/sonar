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
    
    func loadRadarData() {
        
        var url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/"
        var targetRef = Firebase(url: url)
        
        
        targetRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            var postsUrl = "https://sonarapp.firebaseio.com/posts/" + snapshot.key
            var postsRef = Firebase(url: postsUrl)
            postsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let content = snapshot.value["content"] as? String {
                    if let creator = snapshot.value["creator"] as? String {

                        let post = Post(content: content, creator: creator)
                        self.posts.append(post)
                        
                        self.tableView.reloadData()
                        
                        
                    }
                }
                
                
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.posts.removeAll(keepCapacity: true)
        
        self.tableView.reloadData()
        
        self.loadRadarData()
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
        cell.contentLabel.text = radarContent as? String
        
        
        
        let radarCreator: (AnyObject) = posts[indexPath.row].creator
        
        var userurl = "https://sonarapp.firebaseio.com/users/" + (radarCreator as! String)
        var userRef = Firebase(url: userurl)
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let firstname = snapshot.value["firstname"] as? String {
                if let lastname = snapshot.value["lastname"] as? String {
                    cell.nameLabel.text = firstname + " " + lastname
                }
            }
        })
        
        return cell
    }
    
    

}
