//
//  User.swift
//  MuayThaiNotes
//
//  Created by Aiman Nabeel on 30/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import MessageKit

struct User: SenderType, Equatable {
    var senderId: String
    var displayName: String
    
}
