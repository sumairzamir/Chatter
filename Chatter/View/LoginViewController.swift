//
//  LoginViewController.swift
//  Chatter
//
//  Created by Sumair Zamir on 02/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import RxSwift

class LoginViewController: UIViewController {
    
    var loginViewModel = LoginViewModel()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var chatterLogo: UIImageView!
    @IBOutlet weak var avatarSelect1: UIButton!
    @IBOutlet weak var avatarSelect2: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginViewModel.configureVideo()
        configureUI()
    }
    
    @IBAction func tapAvatar1(_ sender: Any) {
        Style.rxUserAvatarColour.onNext("cyan")
        configureTextFieldLeftView()
    }
    
    @IBAction func tapAvatar2(_ sender: Any) {
        Style.rxUserAvatarColour.onNext("white")
        configureTextFieldLeftView()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        loginUser()
        setLoggingIn(true)
    }
    
    func loginUser() {
        loginViewModel.userEmail = emailTextField.text!
        loginViewModel.userPassword = passwordTextField.text!
        loginViewModel.login(completionHandler: handleLoggingIn(success:error:))
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
        navigationController?.setNavigationBarHidden(true, animated: true)
        chatterLogo.alpha = 0.75
        configureTextFields()
        configureVideoPlayer()
        configureAvatarButtons()
    }
    
    func configureTextFields(){
        Style.styleTextFieldBackground(emailTextField)
        Style.styleTextFieldBackground(passwordTextField)
        Style.styleButtonBlack(loginButton)
        Style.styleButtonHollow(registerButton)
        Style.avatarImageView(avatarImageView)
        configureTextFieldLeftView()
    }
    
    func configureTextFieldLeftView() {
        Style.leftViewImage("emailSymbol", imageWidth: 20, imageHeight: 20, textField: emailTextField)
        Style.leftViewImage("passwordSymbol", imageWidth: 20, imageHeight: 15, textField: passwordTextField)
    }
    
    func configureAvatarButtons() {
        avatarSelect1.tintColor = .systemBlue
        avatarSelect2.tintColor = .white
    }
    
    func configureVideoPlayer() {
        loginViewModel.videoPlayerLayer?.frame = CGRect(x: -view.frame.size.width*1.5, y: 0, width: view.frame.size.width*4, height: view.frame.size.height)
        view.layer.insertSublayer(loginViewModel.videoPlayerLayer!, at: 0)
    }
    
}

extension UIViewController {
    
    func showLogicFailure(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
