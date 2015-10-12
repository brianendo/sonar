//
//  AddressBookPerson.swift
//  Sonar
//
//  Created by Brian Endo on 10/1/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import Foundation

class AddressBookPerson: NSObject {
    var name: String?
    var number: String?
    
    init(name: String?, number: String?) {
        self.name = name
        self.number = number
    }
}