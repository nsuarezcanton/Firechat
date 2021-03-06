//
//  Message.swift
//  Firechat
//
//  Created by Nicolas Suarez-Canton Trueba on 12/15/16.
//  Copyright © 2016 Nicolas Suarez-Canton Trueba. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: String?
    var toId: String?
    var imageUrl: String?
    
    func getChatPartnerId() -> String? {
        let chatPartnerId: String?
        
        if fromId == FIRAuth.auth()?.currentUser?.uid {
            chatPartnerId = toId
        } else {
            chatPartnerId = fromId
        }
        
        return chatPartnerId
    }
}
