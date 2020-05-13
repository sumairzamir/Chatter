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

class NetworkParameters {
    
    static let db = Firestore.firestore()
    static let firebaseAuth = Auth.auth()
    
    static var messages: [Message] = []
    static var userUid = Auth.auth().currentUser?.uid
    static var userDisplayName = ""
    static var userEmail = ""
    static var userPassword = ""
    
    static var scrollAnimated = false
    static var networkConnected = true
    
    // rx avatar experiment
    static let rxUserAvatar = BehaviorSubject(value: "")
    
    static var rxUserAvatarObserver:Observable<String> {
        return rxUserAvatar.asObservable()
    }
    
    enum Colour: String {
        case blue
        case black
        
        var colours: UIColor {
            switch self {
            case .blue:
                return UIColor.blue
            case .black:
                return UIColor.black
            }
        }
    }
    
}
