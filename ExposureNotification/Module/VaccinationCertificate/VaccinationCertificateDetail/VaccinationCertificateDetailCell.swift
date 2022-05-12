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
    private let qrCodeSize: CGSize = CGSize(width: 188, height: 188)
    
    private lazy var scrollView = UIScrollView()
    private lazy var qrCodeImageView = UIImageView()    
    private lazy var userInfoView = VaccinationCertificateUserInfoView()
    private lazy var certificateDetailView = VaccinationCertificateDetailView()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle(Localizations.VaccinationCertificateDetail.deleteButton, for: .normal)
        button.titleLabel?.font = UIFont(size: 16, weight: .regular)
        button.backgroundColor = UIColor(red: 175/255, green: 72/255, blue: 72/255, alpha: 1)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapDelete(_:)), for: .touchUpInside)
        return button
    }()
    
    private var model: VaccinationCertificateDetailModel?
    
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
        scrollView.addSubview(qrCodeImageView)
        scrollView.addSubview(userInfoView)
        scrollView.addSubview(certificateDetailView)
        scrollView.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
            make.width.equalTo(208)
            make.bottom.equalToSuperview().inset(23)
        }
    }
    
    func configure(model: VaccinationCertificateDetailModel, properties: [VaccinationCertificateDetailViewModel.Property]) {
        self.model = model
        qrCodeImageView.image = UIImage.init(qrCode: model.qrCode, of: qrCodeSize)
        userInfoView.configure(by: model)
        certificateDetailView.configure(by: properties)
    }
    
    @objc private func didTapDelete(_ sender: UIButton) {
        deletionHandler?()
    }
}
