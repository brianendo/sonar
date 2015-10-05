//
//  RadarTableViewCell.swift
//  SonarFirebase
//
//  Created by Brian Endo on 8/27/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase

class RadarTableViewCell: UITableViewCell, UITextViewDelegate {

    var viewController: RadarViewController?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var textView: MyTextView!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    @IBOutlet weak var cellContentView: UIView!
    
    
    var timeInterval: NSTimeInterval = 0 {
        didSet {
            if timeInterval > 60 {
                let time = Int(timeInterval/60)
                self.timeLeftLabel.text = "\(time) m"
                self.postImageView.image = UIImage(named: "GreenPulse")
            } else if (timeInterval <= 60 && timeInterval > 50) {
                let time = Int(timeInterval)
                self.timeLeftLabel.text = "\(time) s"
                self.postImageView.image = UIImage(named: "YellowPulse")
            } else if timeInterval <= 50 {
                let time = Int(timeInterval)
                self.timeLeftLabel.text = "\(time) s"
                self.postImageView.image = UIImage(named: "RedPulse")
            }else if timeInterval <= 0 {
                self.timeLeftLabel.text = "Dead"
            }
        }
    }
    
    func updateUI() {
        if self.timeInterval > 0 {
            --self.timeInterval
        } else if self.timeInterval <= 0 {
            self.timeLeftLabel.text = "Dead"
            let notification = NSNotification(name: "DeleteDeadCell", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textView.delegate = self
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("updateUI"), name: "CustomCellUpdate", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {

        // Use RadarViewController and access its variables
        self.viewController?.cellURL = URL
        self.viewController?.performSegueWithIdentifier("presentWebView", sender: self)
        return false


    }
    
    
}
