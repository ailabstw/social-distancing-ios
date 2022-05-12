//
//  VaccinationCertificateCardCell.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/3/23.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import UIKit
import Foundation

class VaccinationCertificateCardCell: UICollectionViewCell {
    private lazy var whiteContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.shadowRadius = 5
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowColor = Color.whiteContainerShadow.cgColor
        view.layer.shadowOpacity = 0.3
        view.backgroundColor = Color.whiteContainerBackground
        return view
    }()
    
    private lazy var qrCodeImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, standardizedNameLabel, birthDateLabel, doseDateLabel])
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.name
        label.textColor = Color.nameLabel
        return label
    }()
    
    private lazy var standardizedNameLabel: UILabel = {
        let label = UILabel()
        label.font = Font.standardizedName
        label.textColor = Color.standardizedNameLabel
        return label
    }()
    
    private lazy var birthDateLabel: UILabel = {
        let label = UILabel()
        label.font = Font.birthDate
        label.textColor = Color.birthDateLabel
        return label
    }()
    
    private lazy var doseDateLabel: UILabel = {
        let label = UILabel()
        label.font = Font.doseDate
        label.textColor = Color.doseDateLabel
        label.textAlignment = .center
        label.layer.cornerRadius = 6
        label.layer.borderColor = Color.doseDateBorder.cgColor
        label.layer.borderWidth = 1
        return label
    }()
    
    private var cardModel: VaccinationCertificateCardModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let model = cardModel {
            qrCodeImageView.image = UIImage(qrCode: model.qrCode, of: qrCodeImageView.bounds.size)
        }
    }
    
    private func setupViews() {
        addSubview(whiteContainer)
        whiteContainer.addSubview(qrCodeImageView)
        whiteContainer.addSubview(stackView)
    }
    
    private func setupConstraints() {
        whiteContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        
        qrCodeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(self.snp.width).offset(-80)
            make.height.equalTo(qrCodeImageView.snp.width).multipliedBy(1)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(qrCodeImageView.snp.bottom).offset(20).priority(.low)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(127)
        }
        
        doseDateLabel.snp.makeConstraints { make in
            make.height.equalTo(38)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func configure(by model: VaccinationCertificateCardModel) {
        cardModel = model
        nameLabel.text = model.displayname
        standardizedNameLabel.text = model.standardizedName
        birthDateLabel.text = model.birthDate
        doseDateLabel.text = "\(Localizations.VaccinationCertificateCardCell.doseDate) \(model.doseDate)"
    }
}

extension VaccinationCertificateCardCell {
    enum Color {
        static let whiteContainerBackground = UIColor.white
        static let whiteContainerShadow = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.1)
        static let nameLabel = UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)
        static let standardizedNameLabel = UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)
        static let birthDateLabel = UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)
        static let doseDateLabel = UIColor(red: 46/255, green: 182/255, blue: 169/255, alpha: 1)
        static let doseDateBorder = UIColor(red: 46/255, green: 182/255, blue: 169/255, alpha: 1)
    }
    
    enum Font {
        static let name = UIFont(size: 24, weight: .medium)
        static let standardizedName = UIFont(size: 14, weight: .semibold)
        static let birthDate = UIFont(size: 14, weight: .thin)
        static let doseDate = UIFont(size: 14, weight: .regular)
    }
}

extension Localizations {
    enum VaccinationCertificateCardCell {
        static let doseDate = NSLocalizedString("VaccinationCertificateCardCell.doseDate", value: "Date of vaccination", comment: "")
    }
}
