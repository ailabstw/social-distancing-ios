//
//  VaccinationCertificateDetailView.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/6.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import UIKit

class VaccinationCertificateDetailView: UIView {
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        stack.spacing = 10
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(stack)
    }
    
    private func setupConstraints() {
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(by properties: [VaccinationCertificateDetailViewModel.Property]) {
        stack.arrangedSubviews.forEach {
            stack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        properties.forEach { property in
            let label = UILabel()
            let attrString = NSMutableAttributedString(string: "\(property.title) \(property.value)",
                                                       attributes: [.font: UIFont(size: 14, weight: .regular)!,
                                                                    .foregroundColor: UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)])
            attrString.addAttributes([.font: UIFont(size: 14, weight: .semibold)!],
                                     range: NSRange(location: 0, length: property.title.count))
            label.attributedText = attrString
            label.numberOfLines = 0
            stack.addArrangedSubview(label)
        }
        
        layoutIfNeeded()
    }
}
