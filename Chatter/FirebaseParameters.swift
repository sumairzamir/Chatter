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
    
    // rx avatar experiment
    static let rxUserAvatar = BehaviorSubject(value: "black")
    
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
                return UIColor.white
            }
        }
    }
    
}
