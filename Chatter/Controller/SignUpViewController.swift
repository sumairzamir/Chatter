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
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    func configureUI() {
        
        Style.styleTextField(displayNameTextField)
        Style.styleTextField(emailTextField)
        Style.styleTextField(passwordTextField)
        Style.styleButtonBlue(signUpButton)
        
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        

        let displayName = displayNameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if let error = error {
                
                print("error creating user \(error.localizedDescription)")
                
            } else {
                
                let db = Firestore.firestore()
                
                db.collection("users").addDocument(data: ["displayName": displayName, "uid": result!.user.uid]) { (error) in
                    
                    if error != nil {
                        print("error after firestore \(error!.localizedDescription)")
                    }
                    
                    self.performSegue(withIdentifier: "ChatViewController", sender: nil)
                    
                }
                
            }
            
        }
        
    }
    
    
}
