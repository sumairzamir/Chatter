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
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var chatterLogo: UIImageView!
    @IBOutlet weak var avatarSelect1: UIButton!
    @IBOutlet weak var avatarSelect2: UIButton!
    
    var videoPlayer: AVQueuePlayer?
    var videoLooper: AVPlayerLooper?
    var videoPlayerLayer: AVPlayerLayer?
    
    let disposeBag = DisposeBag()
    
    var loginViewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        configureVideo()
    }
    
    @IBAction func tapAvatar1(_ sender: Any) {
        FirebaseParameters.rxUserAvatar.onNext("blue")
    }
    
    @IBAction func tapAvatar2(_ sender: Any) {
        FirebaseParameters.rxUserAvatar.onNext("black")
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        loginViewModel.userEmail = emailTextField.text!
        loginViewModel.userPassword = passwordTextField.text!
        loginViewModel.login(completionHandler: handleLoggingIn(success:error:))
        setLoggingIn(true)
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
        Style.styleTextFieldBackground(emailTextField)
        Style.styleTextFieldBackground(passwordTextField)
        Style.styleButtonBlack(loginButton)
        Style.styleButtonHollow(registerButton)
        chatterLogo.alpha = 0.75
        avatarSelect1.tintColor = .blue
        avatarSelect2.tintColor = .black
    }
    
    func configureVideo() {
        let bundlePath = Bundle.main.path(forResource: "loginvideo", ofType: "mp4")
        guard bundlePath != nil else {
            return
        }
        let url = URL(fileURLWithPath: bundlePath!)
        let item = AVPlayerItem(url: url)
        videoPlayer = AVQueuePlayer(playerItem: item)
        videoLooper = AVPlayerLooper(player: videoPlayer!, templateItem: item)
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayerLayer?.frame = CGRect(x: -view.frame.size.width*1.5, y: 0, width: view.frame.size.width*4, height: view.frame.size.height)
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        videoPlayer?.playImmediately(atRate: 1)
    }
    
}

extension UIViewController {
    
    func showLogicFailure(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
