//
//  VaccinationCertificateUserInfoView.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/6.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import UIKit

class VaccinationCertificateUserInfoView: UIView {
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.nameLabel
        label.textColor = Color.nameLabel
        return label
    }()
    
    private lazy var standardizedNameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.standardizedNameLabel
        label.textColor = Color.standardizedNameLabel
        return label
    }()
    
    private lazy var birthDateLabel: UILabel = {
        let label = UILabel()
        label.font = Font.birthDateLabel
        label.textColor = Color.birthDateLabel
        return label
    }()
    
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.font = Font.hintLabel
        label.textColor = Color.hintLabel
        label.text = Localizations.VaccinationCertificateUserInfoView.hint
        return label
    }()
    
    private lazy var doseDateLabel: UILabel = {
        let label = UILabel()
        label.font = Font.doseDateLabel
        label.textColor = Color.doseDateLabel
        label.textAlignment = .center
        label.layer.cornerRadius = 6
        label.layer.borderColor = Color.doseDateBorder
        label.layer.borderWidth = 1
        return label
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
        addSubview(nameLabel)
        addSubview(standardizedNameLabel)
        addSubview(birthDateLabel)
        addSubview(hintLabel)
        addSubview(doseDateLabel)
    }
    
    private func setupConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
        
        standardizedNameLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        birthDateLabel.snp.makeConstraints { make in
            make.top.equalTo(standardizedNameLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(birthDateLabel.snp.bottom).offset(3)
            make.centerX.equalToSuperview()
        }
        
        doseDateLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(8)
            make.height.equalTo(38)
            make.width.equalTo(238)
            make.bottom.centerX.equalToSuperview()
        }
    }
    
    func configure(by model: VaccinationCertificateDetailModel) {
        nameLabel.text = model.name
        standardizedNameLabel.text = model.standardizedName
        birthDateLabel.text = model.birthDate
        doseDateLabel.text = "\(Localizations.VaccinationCertificateUserInfoView.doseDate) \(model.doseDate)"
    }
}

extension VaccinationCertificateUserInfoView {
    enum Color {
        static let nameLabel = UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)
        static let standardizedNameLabel = UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)
        static let birthDateLabel = UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)
        static let hintLabel = UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)
        static let doseDateLabel = UIColor(red: 46/255, green: 182/255, blue: 169/255, alpha: 1)
        static let doseDateBorder = UIColor(red: 46/255, green: 182/255, blue: 169/255, alpha: 1).cgColor
    }
    
    enum Font {
        static let nameLabel = UIFont(size: 24, weight: .medium)
        static let standardizedNameLabel = UIFont(size: 14, weight: .semibold)
        static let birthDateLabel = UIFont(size: 14, weight: .thin)
        static let hintLabel = UIFont(size: 13, weight: .regular)
        static let doseDateLabel = UIFont(size: 14, weight: .regular)
    }
}

extension Localizations {
    enum VaccinationCertificateUserInfoView {
        static let hint = NSLocalizedString("VaccinationCertificate.hint", value: "Valid in combination with a government issued ID", comment: "")
        static let doseDate = NSLocalizedString("VaccinationCertificateUserInfoView.doseDate", comment: "")
    }
}
