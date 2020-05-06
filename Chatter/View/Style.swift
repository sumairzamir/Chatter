//
//  Style.swift
//  Chatter
//
//  Created by Sumair Zamir on 05/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import UIKit

class Style {
    
    static func styleTextField(_ textfield: UITextField) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 10, width: textfield.frame.width, height: 2)
        bottomLine.backgroundColor = UIColor.systemBlue.cgColor
        textfield.borderStyle = .none
        textfield.layer.addSublayer(bottomLine)
    }
    
    static func styleButtonBlue(_ button: UIButton) {
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 10
        button.tintColor = UIColor.white
    }
    
    static func styleButtonHollow(_ button: UIButton) {
        button.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
        button.layer.cornerRadius = 10
        button.tintColor = UIColor.systemBlue
    }
    
}
