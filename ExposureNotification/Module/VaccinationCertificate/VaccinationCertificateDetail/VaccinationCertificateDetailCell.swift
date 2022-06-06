//
//  VaccinationCertificateDetailCell.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/5/4.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import UIKit

class VaccinationCertificateDetailCell: UICollectionViewCell {
    enum Style {
        case normal
        case expired
    }
    
    private let qrCodeSize: CGSize = CGSize(width: 188, height: 188)
    
    private lazy var expiredLabel: UILabel = {
        let label = UILabel()
        label.text = Localizations.VaccinationCertificateDetailCell.expiredlabel
        label.textColor = Color.expiredLabel
        label.font = Font.expiredLabel
        label.isHidden = true
        return label
    }()
    
    private lazy var expiredBorder: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = Color.expiredBorder.cgColor
        view.layer.cornerRadius = 6
        if #available(iOS 13.0, *) {
            view.layer.cornerCurve = .continuous
        }
        view.isHidden = true
        return view
    }()
    
    private lazy var scrollView = UIScrollView()
    private lazy var qrCodeImageView = UIImageView()    
    private lazy var userInfoView = VaccinationCertificateUserInfoView()
    private lazy var certificateDetailView = VaccinationCertificateDetailView()
    
    private lazy var deleteButton: UIButton = {
        let button = StyledButton(style: .urgent)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        button.setTitle(Localizations.VaccinationCertificateDetail.deleteButton, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapDelete(_:)), for: .touchUpInside)
        return button
    }()
    
    private var model: VaccinationCertificateDetailModel?
    private var style: Style = .normal {
        didSet {
            switch style {
            case .normal:
                expiredLabel.isHidden = true
                expiredBorder.isHidden = true
            case .expired:
                expiredLabel.isHidden = false
                expiredBorder.isHidden = false
            }
        }
    }
    
    var deletionHandler: (() -> Void)?
    
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
        scrollView.showsVerticalScrollIndicator = false
        
        contentView.addSubview(scrollView)
        scrollView.addSubview(expiredLabel)
        scrollView.addSubview(expiredBorder)
        scrollView.addSubview(qrCodeImageView)
        scrollView.addSubview(userInfoView)
        scrollView.addSubview(certificateDetailView)
        scrollView.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        expiredLabel.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
        
        expiredBorder.snp.makeConstraints { make in
            make.center.equalTo(qrCodeImageView)
            make.width.equalTo(qrCodeImageView).offset(16)
            make.height.equalTo(qrCodeImageView).offset(16)
        }
        
        qrCodeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(33)
            make.centerX.equalToSuperview()
            make.size.equalTo(qrCodeSize)
        }
        
        userInfoView.snp.makeConstraints { make in
            make.top.equalTo(qrCodeImageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        certificateDetailView.snp.makeConstraints { make in
            make.top.equalTo(userInfoView.snp.bottom).offset(34)
            make.leading.trailing.equalToSuperview().inset(16)
            make.width.equalToSuperview().inset(16)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(certificateDetailView.snp.bottom).offset(23)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
            make.width.lessThanOrEqualTo(scrollView.snp.width).inset(8)
            make.bottom.equalToSuperview().inset(23)
        }
    }
    
    func configure(model: VaccinationCertificateDetailModel, properties: [VaccinationCertificateDetailViewModel.Property]) {
        self.model = model
        qrCodeImageView.image = UIImage.init(qrCode: model.qrCode, of: qrCodeSize)
        userInfoView.configure(by: model)
        certificateDetailView.configure(by: properties)
        style = model.isExpired ? .expired : .normal
    }
    
    @objc private func didTapDelete(_ sender: UIButton) {
        deletionHandler?()
    }
}

extension VaccinationCertificateDetailCell {
    enum Color {
        static let expiredLabel = UIColor(red: 217/255, green: 115/255, blue: 115/255, alpha: 1)
        static let expiredBorder = UIColor(red: 217/255, green: 115/255, blue: 115/255, alpha: 1)
        static let deleteButtonBackground = UIColor(red: 175/255, green: 72/255, blue: 72/255, alpha: 1)
    }
    
    enum Font {
        static let expiredLabel = UIFont(size: 16, weight: .regular)
        static let deleteButtonTitle = UIFont(size: 16, weight: .regular)
    }
}


extension Localizations {
    enum VaccinationCertificateDetailCell {
        static let expiredlabel = NSLocalizedString("VaccinationCertificate.expiredLabel", value: "Expired", comment: "")
    }
}
