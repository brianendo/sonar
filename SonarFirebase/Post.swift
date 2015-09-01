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
    
    init(content: String?, creator: String?) {
        self.content = content!
        self.creator = creator!
    }
    

}