//
//  LoginViewModel.swift
//  Chatter
//
//  Created by Sumair Zamir on 14/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import Firebase
import AVKit

class LoginViewModel {
    
    var userEmail = ""
    var userPassword = ""
    
    var videoPlayer: AVQueuePlayer?
    var videoLooper: AVPlayerLooper?
    var videoPlayerLayer: AVPlayerLayer?
    
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
        videoPlayer?.playImmediately(atRate: 1)
    }

}

extension LoginViewModel {
    
    func login(completionHandler: @escaping (Bool, Error?) -> Void) {
        FirebaseParameters.auth.signIn(withEmail: userEmail, password: userPassword) { (result, error) in
            guard error != nil else {
                DispatchQueue.main.async {
                    completionHandler(true,nil)
                }
                return
            }
            completionHandler(false,error)
        }
    }
    
}
