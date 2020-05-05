//
//  LoginViewController.swift
//  Chatter
//
//  Created by Sumair Zamir on 02/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    func configureUI() {
        
        Style.styleTextField(emailTextField)
        Style.styleTextField(passwordTextField)
        Style.styleButtonBlue(loginButton)
        Style.styleButtonHollow(registerButton)
        
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error!.localizedDescription)
                
            } else {

                self.performSegue(withIdentifier: "ChatViewController", sender: nil)
            }
            
            
        }
        
        
    }
    
    
    
}
