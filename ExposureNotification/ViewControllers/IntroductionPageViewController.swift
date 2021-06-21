//
//  IntroductionPageViewController.swift
//  Tracer
//
//  Created by Shiva Huang on 2020/4/1.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import SnapKit
import UIKit

class IntroductionPageViewController: UIViewController {
    var viewModel: Introduction

    private lazy var titleLabel: UILabel = {
        let label = UILabel()

        label.textAlignment = .center
        label.font = Font.title
        label.textColor = Color.text
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var content: UILabel = {
        let label = UILabel()

        label.textAlignment = .justified
        label.font = Font.content
        label.textColor = Color.text
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var figureImageView: UIImageView = {
        let view = UIImageView()

        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    private lazy var actionButton: StyledButton = {
        let button = StyledButton(style: .major)

        button.addTarget(self, action: #selector(clickedButton(_:)), for: .touchUpInside)

        return button
    }()
    
    init(viewModel: Introduction) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        [titleLabel, content, figureImageView].forEach {
            self.view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(36)
            $0.width.equalTo(view.safeAreaLayoutGuide).offset(-52)
        }
        
        content.snp.makeConstraints {
            $0.centerX.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(23)
            $0.width.equalTo(view.safeAreaLayoutGuide).offset(-52)
        }
        
        figureImageView.snp.makeConstraints {
            $0.centerX.equalTo(content)
            $0.top.greaterThanOrEqualTo(content.snp.bottom).offset(16)
            $0.width.equalTo(view.safeAreaLayoutGuide)
            //$0.bottom.equalTo(view.safeAreaLayoutGuide).offset(37)
        }
        
        if let (title, _) = viewModel.action {
            self.view.addSubview(actionButton)
            actionButton.setTitle(title, for: .normal)
            
            actionButton.snp.makeConstraints {
                $0.bottom.equalToSuperview().offset(-44)
                $0.centerX.equalToSuperview()
                $0.width.equalTo(240)
                $0.height.equalTo(44)
            }
            figureImageView.snp.makeConstraints {
                $0.bottom.equalTo(actionButton.snp.top).offset(-10)
            }
        } else {
            figureImageView.snp.makeConstraints {
                $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-37)
            }
        }
        
        titleLabel.text = viewModel.title
        content.text = viewModel.content
        figureImageView.image = UIImage(named: viewModel.figureName)
    }

    @objc func clickedButton(_ sender: UIButton) {
        guard sender == actionButton,
              let action = viewModel.action else {
            return
        }

        action.block()
    }
}

extension IntroductionPageViewController {
    enum Font {
        static let title = UIFont(name: "PingFangTC-Semibold", size: 20.0)!
        static let content = UIFont(name: "PingFangTC-Regular", size: 17.0)!
    }
    
    enum Color {
        static let text = UIColor(red: 73.0/255.0, green: 97.0/255.0, blue: 94.0/255.0, alpha: 1.0)
    }
}
