//
//  SignUpViewController.swift
//  Chatter
//
//  Created by Sumair Zamir on 02/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//  Comment

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var registerActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        Style.styleTextField(displayNameTextField)
        Style.styleTextField(emailTextField)
        Style.styleTextField(passwordTextField)
        Style.styleButtonBlue(signUpButton)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let displayName = displayNameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        setRegisterRequest(true)
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.showLogicFailure(title: "Unable to create user", message: error.localizedDescription)
                self.setRegisterRequest(false)
            } else {
                let db = Firestore.firestore()
                db.collection("users").addDocument(data: ["displayName": displayName, "uid": result!.user.uid]) { (error) in
                    if error != nil {
                        self.showLogicFailure(title: "Unable to create user", message: error?.localizedDescription ?? "")
                        self.setRegisterRequest(false)
                    }
                    self.performSegue(withIdentifier: "ChatViewController", sender: nil)
                    self.setRegisterRequest(false)
                }
            }
        }
    }

    func setRegisterRequest(_ logginIn: Bool) {
        if logginIn {
            registerActivityIndicator.startAnimating()
        } else {
            registerActivityIndicator.stopAnimating()
        }
        
        displayNameTextField.isEnabled = !logginIn
        emailTextField.isEnabled = !logginIn
        passwordTextField.isEnabled = !logginIn
        signUpButton.isEnabled = !logginIn
    }
    
}
