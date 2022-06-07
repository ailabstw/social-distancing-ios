//
//  StyledButton.swift
//  COVID19
//
//  Created by zakk ho on 2020/4/16.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import UIKit

class StyledButton: UIButton {
    
    enum Style {
        case major
        case secondary
        case normal
        case urgent
        
        var defaultBackground: UIColor {
            switch self {
            case .major:
                return UIColor(red: (46/255.0), green: (182/255.0), blue: (169/255.0), alpha: 1)
            case .secondary:
                return UIColor(red: (133/255.0), green: (159/255.0), blue: (156/255.0), alpha: 1)
            case .normal:
                return UIColor(red: (230/255.0), green: (134/255.0), blue: (37/255.0), alpha: 1)
            case .urgent:
                return UIColor(red: (175/255.0), green: (72/255.0), blue: (72/255.0), alpha: 1)
            }
        }
        
        var pressedBackground: UIColor {
            switch self {
            case .major:
                return UIColor(red: (28/255.0), green: (150/255.0), blue: (138/255.0), alpha: 1)
            case .secondary:
                return UIColor(red: (89/255.0), green: (124/255.0), blue: (120/255.0), alpha: 1)
            case .normal:
                return UIColor(red: (185/255.0), green: (99/255.0), blue: (13/255.0), alpha: 1)
            case .urgent:
                return UIColor(red: (175/255.0), green: (72/255.0), blue: (72/255.0), alpha: 1)
            }
        }
        
        var disabledBackground: UIColor {
            switch self {
            case .major:
                return UIColor(red: (159/255.0), green: (214/255.0), blue: (208/255.0), alpha: 1)
            case .secondary:
                return UIColor(red: (193/255.0), green: (204/255.0), blue: (203/255.0), alpha: 1)
            case .normal:
                return UIColor(red: (233/255.0), green: (194/255.0), blue: (155/255.0), alpha: 1)
            case .urgent:
                return UIColor(red: (227/255.0), green: (186/255.0), blue: (186/255.0), alpha: 1)
            }
        }
    }

    var style: Style = .normal {
        didSet {
            updateBackground()
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            updateBackground()
        }
    }
    
    override open var isEnabled: Bool {
        didSet {
            updateBackground()
        }
    }
    
    init(style: Style = .normal) {
        super.init(frame: .zero)

        self.style = style
        updateBackground()

        setTitleColor(UIColor.white, for: .normal)
        titleLabel?.font = UIFont(name: "PingFangTC-Regular", size: 16.0)!
        layer.cornerRadius = 8
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func updateBackground() {
        switch (self.isEnabled, isHighlighted) {
        case (false, _):
            backgroundColor = style.disabledBackground

        case (_, true):
            backgroundColor = style.pressedBackground

        default:
            backgroundColor = style.defaultBackground
        }
    }
}
