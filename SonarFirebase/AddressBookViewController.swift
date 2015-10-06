//
//  AddressBookViewController.swift
//  Sonar
//
//  Created by Brian Endo on 10/1/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import AddressBook
import Parse
import MessageUI
import Firebase

class AddressBookViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var userArray = [AddressBookPerson]()
    
    var inviteArray = [AddressBookPerson]()
    
    var username = ""
    var creatorname = ""
    
    var adbk : ABAddressBook!
    
    func loadUsername() {
        let url = "https://sonarapp.firebaseio.com/users/" + currentUser
        let userRef = Firebase(url: url)
        
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let name = snapshot.value["name"] as? String
            if snapshot.value["username"] is NSNull {
                self.creatorname = name!
            } else {
                let username = snapshot.value["username"] as? String
                self.username = username!
                self.creatorname = name!
            }
        })
    }
    
    func createAddressBook() -> Bool {
        if self.adbk != nil {
            return true
        }
        var err : Unmanaged<CFError>? = nil
        let adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if adbk == nil {
            println(err)
            self.adbk = nil
            return false
        }
        self.adbk = adbk
        self.getContactNames()
        return true
    }
    
    func determineStatus() -> Bool {
        let status = ABAddressBookGetAuthorizationStatus()
        switch status {
        case .Authorized:
            return self.createAddressBook()
        case .NotDetermined:
            var ok = false
            ABAddressBookRequestAccessWithCompletion(nil) {
                (granted:Bool, err:CFError!) in
                dispatch_async(dispatch_get_main_queue()) {
                    if granted {
                        ok = self.createAddressBook()
                    }
                }
            }
            if ok == true {
                return true
            }
            self.adbk = nil
            return false
        case .Restricted:
            self.adbk = nil
            return false
        case .Denied:
            self.adbk = nil
            return false
        }
    }
    
    func getContactNames() {
        if !self.determineStatus() {
            println("not authorized")
            return
        }
        let people = ABAddressBookCopyArrayOfAllPeople(adbk).takeRetainedValue() as NSArray as [ABRecord]
        
        
        let peopleSorted = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(adbk, nil, ABPersonSortOrdering(kABPersonSortByFirstName)).takeRetainedValue() as NSArray as [ABRecordRef]
        for person in peopleSorted {
            let name = ABRecordCopyCompositeName(person).takeRetainedValue() as String
            let numbers = ABRecordCopyValue(person, kABPersonPhoneProperty).takeUnretainedValue()
            let numberOfNumbers = ABMultiValueGetCount(numbers)
            for (var numberIndex: CFIndex = 0; numberIndex < numberOfNumbers; numberIndex++) {
                let label = ABMultiValueCopyLabelAtIndex(numbers, numberIndex).takeRetainedValue() as String
                if (String(stringInterpolationSegment: label) == String(kABPersonPhoneMobileLabel)) {
                    let number = ABMultiValueCopyValueAtIndex(numbers, numberIndex).takeRetainedValue() as! String
                    println(name)
                    println(number)
                    
                    var user = PFQuery(className:"FirebaseUser")
                    user.whereKey("phoneNumber", equalTo: number)
                    
                    user.findObjectsInBackgroundWithBlock {
                        (objects: [AnyObject]?, error: NSError?) -> Void in
                        
                        if error == nil {
                            // The find succeeded.
                            if objects!.count == 0 {
                                println("Add user to Invite to Sonar List")
                                let person = AddressBookPerson(name: name, number: number)
                                self.inviteArray.append(person)
                                self.tableView.reloadData()
                            } else {
                                println("User has an account")
                                let person = AddressBookPerson(name: name, number: number)
                                self.userArray.append(person)
                                self.tableView.reloadData()
                            }
                        } else {
                            // Log details of the failure
                            println("Error: \(error!) \(error!.userInfo!)")
                        }
                    }
                }
            }
        }
    }
    
    func prepareSMSmessage(username:String,cell_number:String)
    {
        
        if (MFMessageComposeViewController.canSendText()) {
        
            var messageVC = MFMessageComposeViewController()
        
        
        
            messageVC.body = "Join Sonar! My username is: \(username)"
            println(messageVC.body)
        
            messageVC.recipients = [cell_number]
            messageVC.messageComposeDelegate = self
        
            self.presentViewController(messageVC, animated: true, completion:nil)
        } else {
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        switch (result.value) {
        case MessageComposeResultCancelled.value:
            println("Message was cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.value:
            println("Message failed")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.value:
            println("Message was sent")
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Address Book"
        
        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.loadUsername()
        
        self.determineStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.userArray.count
        } else {
            return self.inviteArray.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Contacts in Sonar"
        } else {
            return "Invite to Sonar"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: AddressBookTableViewCell = tableView.dequeueReusableCellWithIdentifier("personCell", forIndexPath: indexPath) as! AddressBookTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if indexPath.section == 0 {
            let person = self.userArray[indexPath.row].name
            cell.nameLabel.text = person
            cell.toggleButton.setTitle("Add", forState: .Normal)
            cell.toggleButton.setTitle("Added", forState: .Selected)
            
            cell.toggleButton.tag = indexPath.row
            cell.toggleButton.addTarget(self, action: "addContact:", forControlEvents: .TouchUpInside)
        } else {
            let person = self.inviteArray[indexPath.row].name
            cell.nameLabel.text = person
            cell.toggleButton.setTitle("Invite", forState: .Normal)
            cell.toggleButton.tag = indexPath.row
            cell.toggleButton.addTarget(self, action: "inviteContact:", forControlEvents: .TouchUpInside)
        }
        
        
        
        return cell
    }
    
    func addContact(sender: UIButton){
        
        let phoneNumber = self.inviteArray[sender.tag].number
        
        if (sender.selected == false) {
            
            sender.selected = true
            
            var user = PFQuery(className:"FirebaseUser")
            user.whereKey("phoneNumber", equalTo: phoneNumber)
            
            user.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    if let objects = objects as? [PFObject] {
                        let object = objects[0]
                        let id = object.objectForKey("firebaseId") as! String
                        
                        let userUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/added/"
                        let userActivityRef = Firebase(url: userUrl)
                        userActivityRef.childByAppendingPath(id).setValue(true)
                        
                        let otherUserUrl = "https://sonarapp.firebaseio.com/user_activity/" + id + "/addedme/"
                        let otherUserActivityRef = Firebase(url: otherUserUrl)
                        otherUserActivityRef.childByAppendingPath(currentUser).setValue(true)
                        
                        
                        let readUrl = "https://sonarapp.firebaseio.com/user_activity/" + id + "/read/"
                        let readRef = Firebase(url: readUrl)
                        readRef.setValue(false)
                        
                        let pushURL = "https://sonarapp.firebaseio.com/users/" + id + "/pushId"
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
                        
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
            
            
            
        } else {
            sender.selected = false
            var user = PFQuery(className:"FirebaseUser")
            user.whereKey("phoneNumber", equalTo: phoneNumber)
            
            user.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    if let objects = objects as? [PFObject] {
                        let object = objects[0]
                        let id = object.objectForKey("firebaseId") as! String
                        
                        let userUrl = "https://sonarapp.firebaseio.com/user_activity/" + currentUser + "/added/" + id
                        let userActivityRef = Firebase(url: userUrl)
                        userActivityRef.removeValue()
                        
                        let otherUserUrl = "https://sonarapp.firebaseio.com/user_activity/" + id + "/addedme/" + currentUser
                        let otherUserActivityRef = Firebase(url: otherUserUrl)
                        otherUserActivityRef.removeValue()
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        }
    }
    
    func inviteContact(sender: UIButton){
        sender.setTitle("Invited", forState: .Normal)
        
        let phoneNumber = self.inviteArray[sender.tag].number
        
        self.prepareSMSmessage(self.username, cell_number: phoneNumber)
    }
    
    

}