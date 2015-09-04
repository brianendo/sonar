//
//  Post.swift
//  SonarFirebase
//
//  Created by Brian Endo on 9/1/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import Foundation

class Post: NSObject {
    var content: String
    var creator: String
    var key: String
    var date: NSDate
    var name: String
    
    init(content: String?, creator: String?, key: String?, date: NSDate?, name:String?) {
        self.content = content!
        self.creator = creator!
        self.key = key!
        self.date = date!
        self.name = name!
    }
    

}