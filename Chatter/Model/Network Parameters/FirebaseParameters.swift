//
//  NetworkParameters.swift
//  Chatter
//
//  Created by Sumair Zamir on 09/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

class FirebaseParameters {
    
    static let db = Firestore.firestore()
    static let auth = Auth.auth()
    
}
