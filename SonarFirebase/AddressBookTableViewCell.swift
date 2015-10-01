//
//  AddressBookTableViewCell.swift
//  Sonar
//
//  Created by Brian Endo on 10/1/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit

class AddressBookTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var toggleButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
