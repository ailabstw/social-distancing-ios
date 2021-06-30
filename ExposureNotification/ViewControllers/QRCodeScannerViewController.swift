//
//  QRCodeScannerViewController.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/5/26.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import AVFoundation
import MessageUI
import SnapKit
import UIKit

class QRCodeScannerViewController: UIViewController {

    private lazy var previewView: PreviewView = {
        let previewView = PreviewView()

        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        previewView.session = viewModel.session
        previewView.alpha = 0

        return previewView
    }()

    private lazy var invalidQRCodeToastLabel: UILabel = {
        let label = UILabel()

        label.text = Localizations.QRCodeScannerViewController.invalidQRCodeToastLabel
        label.textAlignment = .center

        return label
    }()

    private lazy var invalidQRCodeToast: UIView = {
        let view = UIView()

        view.backgroundColor = Color.background
        if #available(iOS 13, *) {
            view.layer.cornerCurve = .continuous
        }
        view.layer.cornerRadius = 20.0
        view.clipsToBounds = true
        view.isHidden = true

        view.addSubview(invalidQRCodeToastLabel)

        invalidQRCodeToastLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        view.snp.makeConstraints {
            $0.leading.equalTo(invalidQRCodeToastLabel).offset(-20)
            $0.trailing.equalTo(invalidQRCodeToastLabel).offset(20)
        }

        return view
    }()

    private var viewModel: QRCodeScannerViewModel

    init(viewModel: QRCodeScannerViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(* ,unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        // Enable HintManager, HintManager may be disable because open scanner from shortcut.
        HintManager.shared.isEnabled = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Image.iconClose, style: .done, target: self, action: #selector(close(_:)))

        view.backgroundColor = Color.background

        view.addSubview(previewView)
        view.addSubview(invalidQRCodeToast)

        previewView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        invalidQRCodeToast.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.leading).offset(16)
            $0.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.trailing).offset(-16)
            $0.height.equalTo(40)
        }

        viewModel.configure()

        viewModel.$title { [weak self] (title) in
            self?.title = title
        }

        viewModel.$scanResult { [weak self] (result) in
            switch result {
            case .sms(let sms):
                self?.invalidQRCodeToast.isHidden = true

                guard MFMessageComposeViewController.canSendText() else {
                    logger.error("SMS services are not available")
                    return
                }

                let composer = MFMessageComposeViewController()
                composer.messageComposeDelegate = self

                composer.recipients = [sms.recipient]
                composer.body = sms.body

                self?.present(composer, animated: true, completion: { [weak self] in
                    self?.viewModel.stop()
                })

            case .invalid:
                self?.invalidQRCodeToast.isHidden = false

            case .none:
                self?.invalidQRCodeToast.isHidden = true
            }

        }
        
        viewModel.$sessionConfigurationResult { [unowned self] (result) in
            switch result {
            case .success:
                self.viewModel.start {
                    UIView.animate(withDuration: 0.1) { [ weak self] in
                        self?.previewView.alpha = 1.0
                    }
                }

            default:
                break
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        viewModel.stop()

        super.viewDidDisappear(animated )
    }

    @objc private func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    func resumeScan() {
        guard viewModel.sessionConfigurationResult == .success else {
            return
        }

        if let composer = presentedViewController {
            UIView.animate(withDuration: 0.1) { [ weak self] in
                self?.previewView.alpha = 1.0
                composer.view.alpha = 0.0
            } completion: { [weak self] _ in
                self?.presentedViewController?.dismiss(animated: false, completion: nil)
            }
        }

        viewModel.start()
    }
}

extension QRCodeScannerViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if result == .cancelled {
            self.view.isHidden = true
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

class PreviewView: UIView {

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        return layer
    }

    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}

extension QRCodeScannerViewController {
    enum Color {
        static let background = UIColor(red: (235/255.0), green: (235/255.0), blue: (235/255.0), alpha: 1)

        static let safe = UIColor(red: (46/255.0), green: (182/255.0), blue: (169/255.0), alpha: 1)
        static let warning = UIColor(red: (217/255.0), green: (115/255.0), blue: (115/255.0), alpha: 1)

        static let footerText = UIColor(red: (73/255.0), green: (97/255.0), blue: (94/255.0), alpha: 1)
    }

    enum Font {
        static let statusTitle = UIFont(name: "PingFangTC-Semibold", size: 20.0)!
        static let statusDetail = UIFont(name: "PingFangTC-Regular", size: 17.0)!
        static let upTime = UIFont(name: "PingFangTC-Regular", size: 13.0)!
        static let version = UIFont(name: "PingFangTC-Regular", size: 12.0)!
    }

    enum Image {
        static let iconClose: UIImage = {
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "xmark")!.withRenderingMode(.alwaysOriginal)
            } else {
                return UIImage(named: "iconClose")!.withRenderingMode(.alwaysOriginal)
            }
        }()
    }
}

extension Localizations {
    enum QRCodeScannerViewController {
        static let invalidQRCodeToastLabel = NSLocalizedString("QRCodeScannerViewController.InvalidQRCodeToastLabel",
                                                               comment: "The toast message for QR code is not a 1922 SMS contact tracing QR code")

        enum SendSMSAlert {
            static let title = NSLocalizedString("QRCodeScannerViewController.SendSMSAlert.Title",
                                                 comment: "The title of alert for asking to go to Messages app to send SMS")
        }
    }
}
