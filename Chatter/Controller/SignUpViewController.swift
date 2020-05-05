//
//  SignUpViewController.swift
//  Chatter
//
//  Created by Sumair Zamir on 02/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//  Comment

import Foundation
import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var secondNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    @IBAction func signUpTapped(_ sender: Any) {
        

        let firstName = firstNameTextField.text!
        let secondName = secondNameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if let error = error {
                
                print("error creating user \(error.localizedDescription)")
                
            } else {
                
                let db = Firestore.firestore()
                
                db.collection("users").addDocument(data: ["firstName": firstName, "secondName": secondName, "uid": result!.user.uid]) { (error) in
                    
                    if error != nil {
                        print("error after firestore \(error!.localizedDescription)")
                    }
                    
                    self.performSegue(withIdentifier: "ForumViewController", sender: nil)
                    
                }
                
            }
            
        }
        
    }
    
    
}
