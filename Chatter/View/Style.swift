//
//  Style.swift
//  Chatter
//
//  Created by Sumair Zamir on 05/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import UIKit

class Style {
    
    class func styleTextFieldBackground(_ textfield: UITextField) {
        textfield.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        textfield.textColor = .black
        textfield.layer.cornerRadius = 10
    }
    
    class func styleTextFieldLine(_ textfield: UITextField) {
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 10, width: textfield.frame.width, height: 2)
            bottomLine.backgroundColor = UIColor.white.cgColor
            textfield.borderStyle = .none
            textfield.layer.addSublayer(bottomLine)
            textfield.textColor = .white
        }
    
    
    class func styleButtonBlack(_ button: UIButton) {
        button.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        button.layer.cornerRadius = 10
        button.tintColor = UIColor.white
    }
    
    class func styleButtonHollow(_ button: UIButton) {
        button.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
        button.layer.cornerRadius = 10
        button.tintColor = UIColor.white
    }
    
    class func styleButtonWhite(_ button: UIButton) {
        button.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        button.layer.cornerRadius = 10
        button.tintColor = UIColor.black
    }
    
    
}
