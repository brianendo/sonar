//
//  RadarTableViewCell.swift
//  SonarFirebase
//
//  Created by Brian Endo on 8/27/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit

protocol RadarTableViewCellDelegate {
    func addURL(message: String)
}

class RadarTableViewCell: UITableViewCell, UITextViewDelegate {

    var viewController: RadarViewController?
    
    var url: NSURL?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textView.delegate = self
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
//        let webViewController = WebViewController()
//        webViewController.urlToLoad = URL

        self.viewController?.cellURL = URL
        self.viewController?.performSegueWithIdentifier("presentWebView", sender: self)
//        self.viewController?.presentViewController(webViewController, animated: true, completion: nil)
        println("Reached")
        return false


    }
    
    
}
