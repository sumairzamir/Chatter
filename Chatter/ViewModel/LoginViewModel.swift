//
//  LoginViewModel.swift
//  Chatter
//
//  Created by Sumair Zamir on 14/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import Firebase

class LoginViewModel {
    
    var userEmail = ""
    var userPassword = ""
    
    func login(completionHandler: @escaping (Bool, Error?) -> Void) {
        FirebaseParameters.auth.signIn(withEmail: userEmail, password: userPassword) { (result, error) in
            guard error != nil else {
                DispatchQueue.main.async {
                    completionHandler(true,nil)
                }
                return
            }
            completionHandler(false,error)
        }
    }
    
}
