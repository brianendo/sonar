//
//  ChatTableViewCell.swift
//  SonarFirebase
//
//  Created by Brian Endo on 9/2/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell, UITextViewDelegate {

    var viewController: ChatTableViewController?
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    @IBOutlet weak var creatorLabel: UILabel!
    
    @IBOutlet weak var contentTextView: UITextView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentTextView.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        // Use RadarViewController and access its variables
        
        self.viewController?.cellURL = URL
        self.viewController?.performSegueWithIdentifier("presentWebViewFromChat", sender: self)
        return false
        
        
    }

}
