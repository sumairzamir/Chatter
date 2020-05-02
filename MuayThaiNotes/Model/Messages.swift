//
//  Messages.swift
//  MuayThaiNotes
//
//  Created by Aiman Nabeel on 30/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import Firebase
import MessageKit

struct Message: MessageType {
    
    var messageId: String
    var sender: SenderType {
        return user
    }
    
    var sentDate: Date
    var kind: MessageKind
    
    var user: User
    
    init(kind: MessageKind, user: User, messageId: String, date: Date) {
        
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
        
    }
    
     init(text: String, user: User, messageId: String, date: Date) {
           self.init(kind: .text(text), user: user, messageId: messageId, date: date)
       }
    
    init(custom: Any?, user: User, messageId: String, date: Date) {
           self.init(kind: .custom(custom), user: user, messageId: messageId, date: date)
       }
}
