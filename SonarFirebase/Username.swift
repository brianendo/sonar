//
//  Username.swift
//  Sonar
//
//  Created by Brian Endo on 10/2/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import Foundation

class Username: NSObject {
    var username: String
    var firebaseId: String
    
    init(username: String?, firebaseId: String?) {
        self.username = username!
        self.firebaseId = firebaseId!
    }
}