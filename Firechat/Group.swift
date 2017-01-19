//
//  Group.swift
//  Firechat
//
//  Created by Nicolas Suarez-Canton Trueba on 1/15/17.
//  Copyright © 2017 Nicolas Suarez-Canton Trueba. All rights reserved.
//

import UIKit

class Group: NSObject {
    var id: String?
    var name: String?
    var members = [String]()
    var groupImageUrl: String?
    var timestamp: String?
    var creator: String?
}

