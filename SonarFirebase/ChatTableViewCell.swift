//
//  ChatTableViewCell.swift
//  SonarFirebase
//
//  Created by Brian Endo on 9/2/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Parse

class ChatTableViewCell: UITableViewCell, UITextViewDelegate {

    var viewController: ChatTableViewController?
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var cellContentView: UIView!
    
    @IBOutlet weak var creatorLabel: UILabel!
    
    @IBOutlet weak var contentTextView: UITextView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentTextView.delegate = self
        self.profileImageView.frame = CGRectMake(0, 0, 50, 50)
        self.profileImageView.layer.borderWidth = 0.5
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
        self.profileImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.profileImageView.image = UIImage(named: "Placeholder.png")
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        // Use RadarViewController and access its variables
        
        self.viewController?.cellURL = URL
        self.viewController?.performSegueWithIdentifier("presentWebViewFromChat", sender: self)
        return false
        
        
    }

}
