//
//  StyleTextField.swift
//  Chatter
//
//  Created by Sumair Zamir on 17/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import UIKit

class StyleTextField: UITextField {
    
    func leftViewSettings(_ image: UIImage, textField: UITextField) {
        
        let leftPadding = 5
        let imageSize = 20
        let height = Int(textField.frame.height)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: leftPadding + imageSize, height: height))
        let imageView = UIImageView(frame: CGRect(x: leftPadding, y: 0, width: imageSize, height: height))
        
        imageView.image = image
        container.addSubview(imageView)
        container.bringSubviewToFront(imageView)
        leftView = container
        leftViewMode = .always
        
    }
}
