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
    
    var signUpViewModel = SignUpViewModel()
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var registerActivityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        registerNewUser()
        setRegisterRequest(true)
    }
    
    func registerNewUser() {
        signUpViewModel.newUserDisplayName = displayNameTextField.text!
        signUpViewModel.newUserEmail = emailTextField.text!
        signUpViewModel.newUserPassword = passwordTextField.text!
        signUpViewModel.registerNewUser(completionHandler: handleNewUser(success:error:))
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
        navigationController?.setNavigationBarHidden(false, animated: true)
        configureTextFields()
    }
    
    func configureTextFields() {
        Style.styleTextFieldLine(displayNameTextField)
        Style.styleTextFieldLine(emailTextField)
        Style.styleTextFieldLine(passwordTextField)
        Style.styleButtonWhite(signUpButton)
        configureTextFieldLeftView()
    }
    
    func configureTextFieldLeftView() {
        Style.leftViewImage("senderAvatarSymbol", imageWidth: 20, imageHeight: 20, textField: displayNameTextField)
        Style.leftViewImage("emailSymbol", imageWidth: 20, imageHeight: 20, textField: emailTextField)
        Style.leftViewImage("passwordSymbol", imageWidth: 20, imageHeight: 15, textField: passwordTextField)
    }
    
}
