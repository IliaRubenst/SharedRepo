//
//  CustomButton.swift
//  userLoginWithNode
//
//  Created by Vitaly on 10.10.2023.
//

import UIKit

enum FontSize {
    case big
    case medium
    case small
}

class CustomButton: UIButton {
    init(title: String, hasBackGround: Bool = false, fontSize: FontSize) {
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        
        self.backgroundColor = hasBackGround ? .systemBlue : .clear
        
        let titleColor: UIColor = hasBackGround ? .white : .systemBlue
        self.setTitleColor(titleColor, for: .normal)
        
        switch fontSize {
        case .big:
            self.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        case .medium:
            self.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        case .small:
            self.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
