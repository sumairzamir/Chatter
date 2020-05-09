//
//  SceneDelegate.swift
//  Chatter
//
//  Created by Sumair Zamir on 26/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // Set dark mode as default
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        window?.overrideUserInterfaceStyle = .dark
    }

}

