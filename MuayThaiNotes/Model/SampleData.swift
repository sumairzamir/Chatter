//
//  SampleData.swift
//  MuayThaiNotes
//
//  Created by Aiman Nabeel on 30/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import MessageKit

class SampleData {
    
    static let shared = SampleData()
    
    let sumair = User(senderId: "01", displayName: "Sumair")
    let aiman = User(senderId: "02", displayName: "Aiman")
    
    //why do you need lazy here?
    lazy var senders = [sumair, aiman]
    
    var currentSender: User {
        return sumair
    }
    
    
}
