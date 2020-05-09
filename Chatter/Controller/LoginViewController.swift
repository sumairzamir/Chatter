//
//  LoginViewController.swift
//  Chatter
//
//  Created by Sumair Zamir on 02/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var chatterLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        NetworkParameters.userEmail = emailTextField.text!
        NetworkParameters.userPassword = passwordTextField.text!
        
        setLoggingIn(true)
        
        NetworkLogic.login(completionHandler: handleLoggingIn(success:error:))
    }
    
    func handleLoggingIn(success: Bool, error: Error?) {
        if success {
            performSegue(withIdentifier: "ChatViewController", sender: nil)
            setLoggingIn(false)
        } else {
            showLogicFailure(title: "Login failed", message: error?.localizedDescription ?? "")
            setLoggingIn(false)
        }
        
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            loginActivityIndicator.startAnimating()
        } else {
            loginActivityIndicator.stopAnimating()
        }
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        registerButton.isEnabled = !loggingIn
    }
    
    func configureUI() {
        Style.styleTextField(emailTextField)
        Style.styleTextField(passwordTextField)
        Style.styleButtonBlue(loginButton)
        Style.styleButtonHollow(registerButton)
        chatterLogo.image?.withTintColor(.white, renderingMode: .alwaysTemplate)
    }
    
}

extension UIViewController {
    
    func showLogicFailure(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
