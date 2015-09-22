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
    var createdAt: NSDate
    var name: String
    
    init(content: String?, creator: String?, key: String?, createdAt: NSDate?, name:String?) {
        self.content = content!
        self.creator = creator!
        self.key = key!
        self.createdAt = createdAt!
        self.name = name!
    }
    

}