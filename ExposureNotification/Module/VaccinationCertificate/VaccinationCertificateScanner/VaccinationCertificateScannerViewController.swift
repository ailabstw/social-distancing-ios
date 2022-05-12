//
//  VaccinationCertificateScannerViewController.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/12.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import CoreKit
import Foundation
import SafariServices
import UIKit

class VaccinationCertificateScannerViewController: UIViewController {
    private lazy var previewView: PreviewView = {
        let previewView = PreviewView()
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        previewView.session = viewModel.session
        return previewView
    }()
    
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.hintLabelText
        label.textAlignment = .center
        return label
    }()

    private lazy var hintToast: UIView = {
        let view = UIView()

        view.backgroundColor = Color.toastBackground
        if #available(iOS 13, *) {
            view.layer.cornerCurve = .continuous
        }
        view.layer.cornerRadius = 20.0
        view.clipsToBounds = true
        view.isHidden = true
        view.addSubview(hintLabel)

        hintLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        view.snp.makeConstraints {
            $0.leading.equalTo(hintLabel).offset(-20)
            $0.trailing.equalTo(hintLabel).offset(20)
        }

        return view
    }()
    
    private lazy var applyButton: UIButton = {
        let button = StyledButton(style: .major)
        button.setTitle(Localizations.VaccinationCertificateScanner.apply, for: .normal)
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(didTapApply(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var importButton: UIButton = {
        let button = StyledButton(style: .major)
        button.setTitle(Localizations.VaccinationCertificateScanner.importCertificate, for: .normal)
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(didTapImport(_:)), for: .touchUpInside)
        return button
    }()
    
    private let viewModel: VaccinationCertificateScannerViewModel
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        return picker
    }()
    private lazy var qrCodeDetector = QRCodeDetector()
    private var hintToastTimer: Timer?
    
    init(viewModel: VaccinationCertificateScannerViewModel) {
        self.viewModel = viewModel
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
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.start()
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.stop()
        super.viewDidDisappear(animated)
    }
    
    private func setupViews() {
        title = Localizations.VaccinationCertificateScanner.title
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Image.iconClose, style: .done, target: self, action: #selector(close(_:)))
        
        view.backgroundColor = Color.background
        
        view.addSubview(previewView)
        view.addSubview(hintToast)
        view.addSubview(applyButton)
        view.addSubview(importButton)
    }
    
    private func setupConstraints() {
        previewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        hintToast.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalToSuperview().inset(16)
        }
        
        applyButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(38)
            make.width.equalTo(200)
            make.bottom.equalTo(importButton.snp.top).offset(-16)
        }
        
        importButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(38)
            make.width.equalTo(200)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }
    
    private func setupBindings() {
        viewModel.$scanResult { [weak self] scanResult in
            guard let self = self else { return }
            self.hintToastTimer?.invalidate()
            
            switch scanResult {
            case .none:
                self.hintToast.isHidden = true
            case .valid:
                self.viewModel.shouldCaptureNext = false
                self.dismiss(animated: true, completion: nil)
            case .expired:
                self.hintToast.isHidden = false
                self.hintLabel.text = Localizations.VaccinationCertificateScanner.expired
            case .invalidFormat:
                self.hintToast.isHidden = false
                self.hintLabel.text = Localizations.VaccinationCertificateScanner.invalidFormat
            case .duplicated:
                self.hintToast.isHidden = false
                self.hintLabel.text = Localizations.VaccinationCertificateScanner.duplicated
            case .countLimitExceeded:
                self.dismiss(animated: true, completion: nil)
            case .notFound:
                self.hintToast.isHidden = false
                self.hintLabel.text = Localizations.VaccinationCertificateScanner.notFound
            }
            
            self.hintToastTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { [weak self] _ in
                self?.hintToast.isHidden = true
            })
        }
    }
    
    @objc private func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapApply(_ sender: UIButton) {
        present(SFSafariViewController(viewModel: .applyVaccinationCertificate), animated: true, completion: nil)
    }
    
    @objc private func didTapImport(_ sender: UIButton) {
        present(imagePicker, animated: true)
    }
}

extension VaccinationCertificateScannerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image: UIImage
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        } else {
            assertionFailure()
            return
        }
        
        picker.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            let code = self.qrCodeDetector.performQRCodeDetection(image: image)
            self.viewModel.didFetchQRCodeFromImage(code)
        })
    }
    
}

extension VaccinationCertificateScannerViewController {
    enum Color {
        static let background = UIColor(red: (235/255.0), green: (235/255.0), blue: (235/255.0), alpha: 1)
        static let toastBackground = UIColor(red: (235/255.0), green: (235/255.0), blue: (235/255.0), alpha: 1)
        static let hintLabelText = UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)
        static let tintColor = UIColor(red: 73/255, green: 97/255, blue: 94/255, alpha: 1)
    }
    
    enum Image {
        static let iconClose: UIImage = {
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "xmark")!.withTintColor(Color.tintColor).withRenderingMode(.alwaysOriginal)
            } else {
                return UIImage(named: "iconClose")!.withRenderingMode(.alwaysOriginal)
            }
        }()
    }
}

extension Localizations {
    enum VaccinationCertificateScanner {
        static let title = NSLocalizedString("VaccinationCertificate.title", value: "Vaccination Certificate", comment: "")
        static let apply = NSLocalizedString("VaccinationCertificate.apply", value: "Apply", comment: "")
        static let importCertificate = NSLocalizedString("VaccinationCertificateScanner.import", value: "Import", comment: "")
        static let expired = NSLocalizedString("VaccinationCertificateScanner.expired", value: "Expired vaccination certificate", comment: "")
        static let duplicated = NSLocalizedString("VaccinationCertificateScanner.duplicated", value: "Duplicated vaccination certificate", comment: "")
        static let notFound = NSLocalizedString("VaccinationCertificateScanner.notFound", value: "Failed to detect vaccination certificate QR code", comment: "")
        static let invalidFormat = NSLocalizedString("VaccinationCertificateScanner.invalidFormat", value: "Invalid vaccination certificate QR Code", comment: "")
    }
}
