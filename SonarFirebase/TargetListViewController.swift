//
//  TargetListViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 8/26/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase


class TargetListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    var friendsArray = [AnyObject]()
    var nameArray = [String]()
    
    
    func loadTargetData() {
        self.friendsArray.removeAll(keepCapacity: true)
        
        var url = "https://sonarapp.firebaseio.com/users" + "/" + currentUser + "/targets/"
        var targetRef = Firebase(url: url)
        
        
        targetRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            println(snapshot.key)
            
            var nameUrl = "https://sonarapp.firebaseio.com/users/" + snapshot.key
            var nameRef = Firebase(url: nameUrl)
            nameRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                // do some stuff once
                if let firstname = snapshot.value["firstname"] as? String {
                    if let lastname = snapshot.value["lastname"] as? String {
                        var name = firstname + " " + lastname
                        self.friendsArray.append(name)
                        println(name)
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
        self.tableView.reloadData()
        
        self.loadTargetData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TargetListTableViewCell = tableView.dequeueReusableCellWithIdentifier("targetCell", forIndexPath: indexPath) as! TargetListTableViewCell
        
        let target: (AnyObject) = friendsArray[indexPath.row]
        cell.nameLabel.text = target as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendsArray.count
    }
    

}
