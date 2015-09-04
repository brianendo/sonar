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
    
    func loadRadarData() {
        
        var url = "https://sonarapp.firebaseio.com/users/" + currentUser + "/postsReceived/"
        var targetRef = Firebase(url: url)
        
        
        targetRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            
            var postsUrl = "https://sonarapp.firebaseio.com/posts/" + snapshot.key
            var postsRef = Firebase(url: postsUrl)
            postsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let key = snapshot.key
                {if let content = snapshot.value["content"] as? String {
                    if let creator = snapshot.value["creator"] as? String {
                        if let createdAt = snapshot.value["createdAt"] as? NSTimeInterval {
                            var userurl = "https://sonarapp.firebaseio.com/users/" + (creator)
                            var userRef = Firebase(url: userurl)
                            userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                                if let firstname = snapshot.value["firstname"] as? String {
                                    if let lastname = snapshot.value["lastname"] as? String {
                                        var name = firstname + " " + lastname
                                        var date = NSDate(timeIntervalSince1970: (createdAt/1000))
                                        let post = Post(content: content, creator: creator, key: key, date: date, name: name)
                                        self.posts.append(post)
                                        self.posts.sort({ $0.date.compare($1.date) == .OrderedDescending })
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

        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.posts.removeAll(keepCapacity: true)
        
        
        self.loadRadarData()
    }
    
    override func viewDidAppear(animated: Bool) {
        

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChat" {
            let chatVC: ChatTableViewController = segue.destinationViewController as! ChatTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            
            let post = self.posts[indexPath!.row]
            chatVC.postVC = post
            println(post.key)
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
        cell.contentLabel.text = radarContent as? String
        
        
        
        let radarCreator: (AnyObject) = posts[indexPath.row].name
        
        cell.nameLabel.text = radarCreator as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showChat", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    

}
