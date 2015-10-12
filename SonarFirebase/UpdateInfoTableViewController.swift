//
//  UpdateInfoTableViewController.swift
//  
//
//  Created by Brian Endo on 10/7/15.
//
//

import UIKit
import Parse

class UpdateInfoTableViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    func getUserInfo() {
        var user = PFQuery(className:"FirebaseUser")
        user.whereKey("firebaseId", equalTo: currentUser)
        
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
                            let username = object.objectForKey("username") as! String
                            let email = object.objectForKey("email") as! String
                            let phoneNumber = object.objectForKey("phoneNumber") as! String
                            
                            self.nameLabel.text = name
                            self.usernameLabel.text = username
                            self.emailLabel.text = email
                            self.phoneNumberLabel.text = phoneNumber
                            
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    println("No user")
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "updateNameSegue" {
            let updateNameVC: UpdateNameViewController = segue.destinationViewController as! UpdateNameViewController
            updateNameVC.name = self.nameLabel.text!
        } else if segue.identifier == "updateUsernameSegue" {
            let updateUsernameVC: UpdateUsernameViewController = segue.destinationViewController as! UpdateUsernameViewController
            updateUsernameVC.username = self.usernameLabel.text!
        } else if segue.identifier == "updateEmailSegue" {
            let updateEmailVC: EmailViewController = segue.destinationViewController as! EmailViewController
            updateEmailVC.email = self.emailLabel.text!
        } else if segue.identifier == "updatePhoneNumber" {
            let updatePhoneVC: UpdatePhoneViewController = segue.destinationViewController as! UpdatePhoneViewController
            updatePhoneVC.phoneNumber = self.phoneNumberLabel.text!
        } else if segue.identifier == "changePasswordSegue" {
            let changePasswordVC: ChangePasswordViewController = segue.destinationViewController as! ChangePasswordViewController
            changePasswordVC.email = self.emailLabel.text!
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.getUserInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//        self.getUserInfo()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }


}
