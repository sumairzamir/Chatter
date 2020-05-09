//
//  NetworkParameters.swift
//  Chatter
//
//  Created by Sumair Zamir on 09/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import Firebase

class NetworkParameters {
    
    static let db = Firestore.firestore()
    
    static var messages: [Message] = []
    static var currentUserUid = Auth.auth().currentUser?.uid
    static var currentDisplayName = ""
    
    static var scrollAnimated = false
    static var networkConnected = true
    
}
