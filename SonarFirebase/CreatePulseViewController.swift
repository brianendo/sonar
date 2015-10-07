//
//  CreatePulseViewController.swift
//  SonarFirebase
//
//  Created by Brian Endo on 8/24/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase

class CreatePulseViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var pulseTextView: UITextView!
    
    @IBOutlet weak var charRemainingLabel: UILabel!
    
    @IBOutlet weak var bottomSpaceToLayoutGuide: NSLayoutConstraint!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    var placeholder = "Your first pulse? Be yourself...unless you're a douche, then maybe change it up a bit."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Pulse"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        self.nextButton.enabled = false
        
        // Do any additional setup after loading the view.
        pulseTextView.delegate = self
        
        // Make the keyboard pop up
        pulseTextView.becomeFirstResponder()
        
        // Placeholder text
        pulseTextView.text = placeholder
        pulseTextView.textColor = UIColor.lightGrayColor()
        
        pulseTextView.selectedTextRange = pulseTextView.textRangeFromPosition(pulseTextView.beginningOfDocument, toPosition: pulseTextView.beginningOfDocument)
        
        var nav = self.navigationController?.navigationBar
        
//        let font = UIFont(name: "Helvetica Neue", size: 20)
        let font = UIFont.systemFontOfSize(25)
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        
        self.bottomView.layer.masksToBounds = true
        self.bottomView.layer.borderColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0).CGColor
        self.bottomView.layer.borderWidth = 0.7
        
        self.nextButton.layer.masksToBounds = true
        self.nextButton.layer.borderColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0).CGColor
        self.nextButton.layer.borderWidth = 0.7
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        print(keyboardFrame)
        self.bottomSpaceToLayoutGuide.constant = keyboardFrame.size.height
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        self.pulseTextView.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = pulseTextView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            pulseTextView.text = placeholder
            pulseTextView.textColor = UIColor.lightGrayColor()
            
            self.charRemainingLabel.text = "100"
            pulseTextView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            self.nextButton.enabled = false
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if pulseTextView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
            pulseTextView.text = nil
            pulseTextView.textColor = UIColor.blackColor()
            
            
        }
        
        // Limit character limit to 100
        let newLength: Int = (pulseTextView.text as NSString).length + (text as NSString).length - range.length
        let remainingChar: Int = 100 - newLength
        
        if pulseTextView.text == placeholder {
            charRemainingLabel.text = "100"
        } else {
            // Make label show remaining characters
            charRemainingLabel.text = "\(remainingChar)"
        }
        // Once text > 100 chars, stop ability to change text
        return (newLength == 100) ? false : true
        
        
        
    }
    
    func textViewDidChange(textView: UITextView) {
        let trimmedString = pulseTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if count(trimmedString) == 0 {
            self.nextButton.enabled = false
        } else {
            self.nextButton.enabled = true
        }
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if pulseTextView.textColor == UIColor.lightGrayColor() {
                pulseTextView.selectedTextRange = pulseTextView.textRangeFromPosition(pulseTextView.beginningOfDocument, toPosition: pulseTextView.beginningOfDocument)
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pulseToTargets" {
            let pickTargetVC: PickTargetViewController = segue.destinationViewController as! PickTargetViewController
            
            pickTargetVC.content = pulseTextView.text
            pickTargetVC.creator = currentUser
            
        }
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        
        
        }
    
    

}
