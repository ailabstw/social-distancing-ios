//
//  HintView.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/6/9.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import SnapKit
import UIKit

class HintView: UIView {
    private(set) lazy var arrowView: UIImageView = {
        UIImageView(image: Image.arrow)
    }()

    let titleLabel: UILabel = {
        let label = UILabel()

        label.textColor = Color.text
        label.font = Font.title
        label.numberOfLines = 0
        label.textAlignment = .center

        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()

        label.textColor = Color.text
        label.font = Font.subtitle
        label.numberOfLines = 0
        label.textAlignment = .center

        return label
    }()

    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    var subtitle: String? {
        get {
            subtitleLabel.text
        }
        set {
            subtitleLabel.text = newValue
        }
    }

    var arrowPosition: CGFloat = 0.0 {
        didSet {
            arrowView.snp.updateConstraints {
                $0.centerX.equalTo(arrowPosition)
            }
        }
    }

    init(title: String? = nil, subtitle: String? = nil) {
        super.init(frame: .zero)

        self.title = title
        self.subtitle = subtitle

        self.addSubview(arrowView)
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)

        arrowView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 24, height: 24))
            $0.centerX.equalTo(arrowPosition)
            $0.top.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(arrowView.snp.bottom).offset(5)
            $0.leading.greaterThanOrEqualToSuperview().inset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
            $0.centerX.equalTo(arrowView).priority(.medium)
        }

        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(titleLabel)
        }

        self.snp.makeConstraints {
            $0.bottom.greaterThanOrEqualTo(titleLabel)
            $0.bottom.equalTo(subtitleLabel)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HintView {
    enum Color {
        static let text = UIColor.white
    }

    enum Font {
        static let title = UIFont(name: "PingFangTC-Semibold", size: 17.0)!
        static let subtitle = UIFont(name: "PingFangTC-Thin", size: 17.0)!
    }

    enum Image {
        static let arrow: UIImage = {
            if #available(iOS 13, *) {
                return UIImage(systemName: "arrowtriangle.up.fill")!.withTintColor(.white, renderingMode: .alwaysOriginal)
            } else {
                return UIImage(named: "arrow")!
            }
        }()
    }
}
