//
//  LoginViewModel.swift
//  Chatter
//
//  Created by Sumair Zamir on 14/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

class LoginViewModel {
    
    var userEmail = ""
    var userPassword = ""
    
//     Combine observers?
//    var rxUserEmail = BehaviorSubject(value: "")
//    var rxUserPassword = BehaviorSubject(value: "")
//    
//    var userEmailObservable: Observable<String> {
//        return userEmail.asObservable()
//    }
//
//    var userPasswordObservable: Observable<String> {
//        return userPassword.asObservable()
//    }
    
    func login(completionHandler: @escaping (Bool, Error?) -> Void) {
           NetworkParameters.firebaseAuth.signIn(withEmail: userEmail, password: userPassword) { (result, error) in
               guard error != nil else {
                   NetworkParameters.userUid = Auth.auth().currentUser?.uid
                   DispatchQueue.main.async {
                       completionHandler(true,nil)
                   }
                   return
               }
               completionHandler(false,error)
           }
       }
       
    
    
    
    
    
}
