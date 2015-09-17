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
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.doneButton.enabled = false
        
        // Do any additional setup after loading the view.
        pulseTextView.delegate = self
        
        // Make the keyboard pop up
        pulseTextView.becomeFirstResponder()
        
        // Placeholder text
        pulseTextView.text = "Ask your friends anything"
        pulseTextView.textColor = UIColor.lightGrayColor()
        
        pulseTextView.selectedTextRange = pulseTextView.textRangeFromPosition(pulseTextView.beginningOfDocument, toPosition: pulseTextView.beginningOfDocument)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
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
            
            pulseTextView.text = "Ask your friends anything"
            pulseTextView.textColor = UIColor.lightGrayColor()
            
            pulseTextView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
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

        // Limit character limit to 80
        var newLength: Int = (pulseTextView.text as NSString).length + (text as NSString).length - range.length
        var remainingChar: Int = 100 - newLength
        
        // Make label show remaining characters
        charRemainingLabel.text = "\(remainingChar)"
        
        // Once text > 100 chars, stop ability to change text
        return (newLength > 100) ? false : true
    }
    
    func textViewDidChange(textView: UITextView) {
        let trimmedString = pulseTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        println(trimmedString)
        if count(trimmedString) == 0 {
            self.doneButton.enabled = false
        } else {
            self.doneButton.enabled = true
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
