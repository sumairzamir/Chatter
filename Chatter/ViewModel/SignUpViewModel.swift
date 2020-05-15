//
//  SignUpViewModel.swift
//  Chatter
//
//  Created by Sumair Zamir on 15/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import Firebase

class SignUpViewModel {
    
    var newUserEmail = ""
    var newUserPassword = ""
    var newUserDisplayName = ""
    
    func registerNewUser(completionHandler: @escaping (Bool, Error?) -> Void) {
        FirebaseParameters.auth.createUser(withEmail: newUserEmail, password: newUserPassword) { (result, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completionHandler(false,error)
                }
            } else {
                FirebaseParameters.db.collection("users").addDocument(data: ["displayName": self.newUserDisplayName, "uid": result!.user.uid]) { (error) in
                    guard error != nil else {
                        DispatchQueue.main.async {
                            completionHandler(true,nil)
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        completionHandler(false,error)
                    }
                }
            }
        }
    }
    
}
