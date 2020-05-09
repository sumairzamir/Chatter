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
    
    @IBAction func signUpTapped(_ sender: Any) {
        NetworkParameters.userDisplayName = displayNameTextField.text!
        NetworkParameters.userEmail = emailTextField.text!
        NetworkParameters.userPassword = passwordTextField.text!
        
        setRegisterRequest(true)
        
        NetworkLogic.registerNewUser(completionHandler: handleNewUser(success:error:))
    }
    
    func handleNewUser(success: Bool, error: Error?) {
        if success {
            self.performSegue(withIdentifier: "ChatViewController", sender: nil)
            self.setRegisterRequest(false)
        } else {
            self.showLogicFailure(title: "Unable to create user", message: error!.localizedDescription)
            self.setRegisterRequest(false)
        }
    }
    
    func setRegisterRequest(_ registerRequest: Bool) {
        if registerRequest {
            registerActivityIndicator.startAnimating()
        } else {
            registerActivityIndicator.stopAnimating()
        }
        displayNameTextField.isEnabled = !registerRequest
        emailTextField.isEnabled = !registerRequest
        passwordTextField.isEnabled = !registerRequest
        signUpButton.isEnabled = !registerRequest
    }
    
    func configureUI() {
        Style.styleTextField(displayNameTextField)
        Style.styleTextField(emailTextField)
        Style.styleTextField(passwordTextField)
        Style.styleButtonBlue(signUpButton)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}
