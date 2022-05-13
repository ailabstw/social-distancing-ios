//
//  Checkbox.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/19.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Checkbox: UIView {
    var checkedImage = Style.checkedImage
    var uncheckedImage = Style.uncheckedImage
    
    var defaultTintColor = Style.defaultTintColor {
        didSet {
            updateBackground()
        }
    }
    
    var disabledTintColor = Style.disabledTintColor {
        didSet {
            updateBackground()
        }
    }
    
    var tapHandler: ((Bool) -> Void)?
    
    var isChecked: Bool = false {
        didSet {
            updateBackground()
        }
    }
    
    var isEnabled: Bool = false {
        didSet {
            isUserInteractionEnabled = isEnabled
            updateBackground()
        }
    }
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.image = checkedImage
        image.contentMode = .scaleToFill
        return image
    }()
    
    init() {
        super.init(frame: .zero)
        updateBackground()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapCheckbox))
        addGestureRecognizer(gesture)
        
        backgroundColor = .clear

        layer.cornerRadius = 4
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
        
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func updateBackground() {
        if #available(iOS 13, *) {
            imageView.image = isChecked ? checkedImage?.withTintColor(getCurrentTintColor()) : uncheckedImage?.withTintColor(getCurrentTintColor())
        } else {
            imageView.image = isChecked ? checkedImage : uncheckedImage
        }
    }
    
    @objc private func didTapCheckbox(_ sender: UIButton) {
        isChecked.toggle()
        tapHandler?(isChecked)
    }
    
    private func getCurrentTintColor() -> UIColor {
        isEnabled ? defaultTintColor : disabledTintColor
    }
}

extension Checkbox {
    enum Style {
        static let checkedImage = UIImage(named: "iconCheckbox")
        static let uncheckedImage = UIImage(named: "iconCheckboxUnchecked")
        static let defaultTintColor = UIColor(red: (46/255.0), green: (182/255.0), blue: (169/255.0), alpha: 1)
        static let disabledTintColor = UIColor(red: (159/255.0), green: (214/255.0), blue: (208/255.0), alpha: 1)
    }
}
