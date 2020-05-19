//
//  Style.swift
//  Chatter
//
//  Created by Sumair Zamir on 05/05/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import UIKit
import RxSwift

class Style {
    
    static let otherUserAvatarColour = UIColor.black
    static let rxUserAvatarColour = BehaviorSubject(value: "white")
    
    static var rxUserAvatarColourObserver:Observable<String> {
        return rxUserAvatarColour.asObservable()
    }
    
    class func avatarImageView(_ imageView: UIImageView) {
        imageView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
        imageView.layer.cornerRadius = 10
    }
    
    enum Colour: String {
        case blue
        case white
        
        var colours: UIColor {
            switch self {
            case .blue:
                return UIColor.systemBlue
            case .white:
                return UIColor.white
            }
        }
    }
    
}

extension Style {
    
    class func styleTextFieldBackground(_ textfield: UITextField) {
        textfield.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        textfield.textColor = .black
        textfield.layer.cornerRadius = 10
    }
    
    class func styleTextFieldLine(_ textfield: UITextField) {
        DispatchQueue.main.async {
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 10, width: textfield.frame.width, height: 2)
            bottomLine.backgroundColor = UIColor.white.cgColor
            textfield.layer.addSublayer(bottomLine)
            textfield.borderStyle = .none
            textfield.textColor = .white
        }
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
    
    class func leftViewImage(_ imageName: String, imageWidth: CGFloat, imageHeight: CGFloat, textField: UITextField) {
        
        let disposeBag = DisposeBag()
        
        let padding: CGFloat = 10
        let imageSize = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        let containerSize = CGRect(x: 0, y: 0, width: imageWidth + padding, height: textField.frame.height)
        
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.frame = imageSize
        imageView.contentMode = .scaleAspectFit
        
        let container = UIView(frame: containerSize)
        container.addSubview(imageView)
        container.bringSubviewToFront(imageView)
        imageView.center = container.center
        
        textField.leftView = container
        textField.leftViewMode = .always
        rxUserAvatarColour.subscribe(onNext: { (avatarColor) in
            textField.tintColor = Colour(rawValue: avatarColor)?.colours.withAlphaComponent(0.75)}).disposed(by: disposeBag)
    }
    
    
}
