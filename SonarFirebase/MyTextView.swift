//
//  MyTextView.swift
//  Sonar
//
//  Created by Brian Endo on 9/18/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import Foundation

class MyTextView: UITextView {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    override func canBecomeFirstResponder() -> Bool {
        return false
    }
    
    
    
    
}