//
//  VaccinationCertificateEmptyView.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/3/23.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import UIKit

protocol VaccinationCertificateEmptyViewDelegate: AnyObject {
    func handleAddAction()
}

class VaccinationCertificateEmptyView: UIView {
    weak var delegate: VaccinationCertificateEmptyViewDelegate?
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(descriptionLabel)
        stack.addArrangedSubview(addButton)
        return stack
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView(image: Image.graphAdd)
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Localizations.VaccinationCertificateEmptyView.description
        label.numberOfLines = 0
        label.textAlignment = .justified
        label.font = Font.description
        label.textColor = Color.description
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Color.addButtonBackground
        button.layer.cornerRadius = 8
        button.setTitle(Localizations.VaccinationCertificateEmptyView.addButton, for: .normal)
        button.setTitleColor(Color.addButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(didTapAddButton(_:)), for: .touchDown)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.top.bottom.equalTo(safeAreaLayoutGuide).inset(40)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(290)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(60)
        }
        
        addButton.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(stackView.snp.width).inset(24)
            make.width.greaterThanOrEqualTo(240)
            make.height.equalTo(48)
        }
    }
    
    @objc func didTapAddButton(_ sender: UIButton) {
        delegate?.handleAddAction()
    }
}

extension VaccinationCertificateEmptyView {
    enum Font {
        static let description = UIFont(size: 17, weight: .regular)
    }
    
    enum Color {
        static let addButtonTitle = UIColor.white
        static let addButtonBackground = UIColor(red: 46/255, green: 182/255, blue: 169/255, alpha: 1)
        static let description = UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)
    }
    
    enum Image {
        static let graphAdd = UIImage(named: "graphAdd")
    }
}

extension Localizations {
    enum VaccinationCertificateEmptyView {
        static let description = NSLocalizedString("VaccinationCertificateEmptyView.description", value: "Carry a digital copy of the vaccination certificate by scanning the QR code of the Digital COVID-19 certificate.", comment: "")
        static let addButton = NSLocalizedString("VaccinationCertificateEmptyView.addButton", value: "Add Vaccination Certificate", comment: "")
    }
}
