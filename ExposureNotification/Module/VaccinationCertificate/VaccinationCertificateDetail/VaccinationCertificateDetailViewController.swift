//
//  VaccinationCertificateDetailViewController.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/3/25.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreKit

protocol VaccinationCertificateDetailDelegate: AnyObject {
    func didSwitchToPrevCertificate(qrCode: String)
    func didSwitchToNextCertificate(qrCode: String)
}

class VaccinationCertificateDetailViewController: UIViewController {
    private let viewModel: VaccinationCertificateDetailViewModel
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let qrCodeSize: CGSize = CGSize(width: 188, height: 188)
    private lazy var qrCodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(qrCode: viewModel.code, of: qrCodeSize)
        return imageView
    }()
    
    private lazy var goPrevButton: UIButton = {
        let button = StyledButton(style: .major)
        button.setImage(UIImage(named: "iconArrowLeft"), for: .normal)
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(didTapPrev(_:)), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        return button
    }()
    
    private lazy var goNextButton: UIButton = {
        let button = StyledButton(style: .major)
        button.setImage(UIImage(named: "iconArrowRight"), for: .normal)
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(didTapNext(_:)), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
        return button
    }()
    
    private lazy var userInfoView: VaccinationCertificateUserInfoView = {
        let userInfoView = VaccinationCertificateUserInfoView()
        if let model = viewModel.model {
            userInfoView.configure(by: model)
        }
        return userInfoView
    }()
    
    private lazy var certificateDetailView: VaccinationCertificateDetailView = {
        let detailView = VaccinationCertificateDetailView()
        detailView.configure(by: viewModel.vaccinationProperties)
        return detailView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle(Localizations.VaccinationCertificateDetail.deleteButton, for: .normal)
        button.titleLabel?.font = UIFont(size: 16, weight: .regular)
        button.backgroundColor = UIColor(red: 175/255, green: 72/255, blue: 72/255, alpha: 1)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapDelete(_:)), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: VaccinationCertificateDetailDelegate?
    
    init(viewModel: VaccinationCertificateDetailViewModel, delegate: VaccinationCertificateDetailDelegate? = nil) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupBinding()
    }
    
    private func setupViews() {
        title = Localizations.VaccinationCertificateDetail.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconClose")!.withRenderingMode(.alwaysOriginal),
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapClose(_:)))
        
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(qrCodeImageView)
        scrollView.addSubview(goPrevButton)
        scrollView.addSubview(goNextButton)
        scrollView.addSubview(userInfoView)
        scrollView.addSubview(certificateDetailView)
        scrollView.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        qrCodeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(33)
            make.centerX.equalToSuperview()
            make.size.equalTo(qrCodeSize)
        }
        
        goPrevButton.snp.makeConstraints { make in
            make.height.width.equalTo(35)
            make.trailing.equalTo(qrCodeImageView.snp.leading).offset(-34)
            make.centerY.equalTo(qrCodeImageView)
        }
        
        goNextButton.snp.makeConstraints { make in
            make.height.width.equalTo(35)
            make.leading.equalTo(qrCodeImageView.snp.trailing).offset(34)
            make.centerY.equalTo(qrCodeImageView)
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
    
    private func setupBinding() {
        viewModel.$code { [weak self] code in
            guard let self = self else { return }
            self.qrCodeImageView.image = UIImage.init(qrCode: code, of: self.qrCodeSize)
        }
        
        viewModel.$model { [weak self] maybeModel in
            guard let model = maybeModel else { return }
            self?.userInfoView.configure(by: model)
        }
        
        viewModel.$vaccinationProperties { [weak self] newProperties in
            self?.certificateDetailView.configure(by: newProperties)
        }
        
        viewModel.$hasNextCode { [weak self] hasNext in
            self?.goNextButton.isEnabled = hasNext
            self?.checkPrevAndNextButtonShouldShow()
        }
        
        viewModel.$hasPrevCode { [weak self] hasPrev in
            self?.goPrevButton.isEnabled = hasPrev
            self?.checkPrevAndNextButtonShouldShow()
        }
    }
    
    @objc private func didTapClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapPrev(_ sender: UIButton) {
        viewModel.goPrevCode()
        delegate?.didSwitchToPrevCertificate(qrCode: viewModel.code)
    }
    
    @objc private func didTapNext(_ sender: UIButton) {
        viewModel.goNextCode()
        delegate?.didSwitchToNextCertificate(qrCode: viewModel.code)
    }
    
    @objc private func didTapDelete(_ sender: UIButton) {
        let alert = UIAlertController(title: Localizations.VaccinationCertificateDetail.deleteAlertTitle,
                                      message: Localizations.VaccinationCertificateDetail.deleteAlertMessage(name: viewModel.model!.name),
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Localizations.Alert.Button.yes, style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.deleteCurrentCode()
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: Localizations.Alert.Button.no, style: .default, handler: { _ in }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func checkPrevAndNextButtonShouldShow() {
        let isOnlyOneQRCode = !viewModel.hasPrevCode && !viewModel.hasNextCode
        goPrevButton.isHidden = isOnlyOneQRCode
        goNextButton.isHidden = isOnlyOneQRCode
    }
}

extension Localizations {
    enum VaccinationCertificateDetail {
        static let title = NSLocalizedString("VaccinationCertificate.title", value: "Vaccination Certificate", comment: "")
        static let deleteButton = NSLocalizedString("VaccinationCertificate.deleteButton", value: "Remove this vaccination certificate", comment: "")
        static let deleteAlertTitle = NSLocalizedString("VaccinationCertificateDetail.deleteAlertTitle", value: "Are you sure you want to remove it?", comment: "")
        
        static func deleteAlertMessage(name: String) -> String {
            return String(format: NSLocalizedString("VaccinationCertificateDetail.deleteAlertMessage", value: "Are you sure you wan to remove %@ vaccination certificate?", comment: ""), name)
        }
    }
}
