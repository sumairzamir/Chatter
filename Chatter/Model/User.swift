//
//  User.swift
//  Chatter
//
//  Created by Sumair Zamir on 30/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import MessageKit

struct User: SenderType, Equatable {
    var senderId: String
    var displayName: String
    
}
