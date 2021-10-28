//
//  TogglableTableViewCell.swift
//  COVID19
//
//  Created by Shiva Huang on 2020/5/26.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import UIKit

class TogglableTableViewCell: UITableViewCell {
    var viewModel: TogglableCellViewModel? {
        didSet {
            oldValue?.$state.cancel()
            oldValue?.$isEnabled.cancel()

            textLabel?.text = viewModel?.title
            textLabel?.adjustsFontSizeToFitWidth = true
            switcher.isOn = false
            switcher.removeTarget(nil, action: nil, for: .touchUpInside)
            switcher.addTarget(self, action: #selector(toggle(_:)), for: .touchUpInside)

            viewModel?.$state { [weak self] (state) in
                guard let self = self else {
                    return
                }
                
                switch state {
                case .on:
                    self.switcher.isOn = true
                    self.accessoryView = self.switcher
                    
                case .off:
                    self.switcher.isOn = false
                    self.accessoryView = self.switcher
                    
                case .processing:
                    self.accessoryView = self.spinner
                }
            }
            
            viewModel?.$isEnabled { [weak self] (isEnabled) in
                self?.switcher.isEnabled = isEnabled
            }
        }
    }
    
    private lazy var switcher: UISwitch = {
        UISwitch()
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let view: UIActivityIndicatorView = {
            if #available(iOS 13.0, *) {
                return UIActivityIndicatorView(style: .medium)
            } else {
                return UIActivityIndicatorView(style: .gray)
            }
        }()

        view.startAnimating()
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryView = switcher
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        viewModel = nil
    }
    
    @objc private func toggle(_ sender: UISwitch) {
        viewModel?.toggle()
    }
}
