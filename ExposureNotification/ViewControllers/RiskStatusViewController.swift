//
//  RiskStatusViewController.swift
//  COVID19
//
//  Created by Shiva Huang on 2020/4/8.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import SafariServices
import SnapKit
import UIKit
import Updates

class RiskStatusViewController: UIViewController {
    private let viewModel: RiskStatusViewModel
    
    private lazy var banner: UIButton = {
        let button = UIButton()

        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = Font.statusTitle
        button.titleLabel?.lineBreakMode = .byWordWrapping

        button.addTarget(self, action: #selector(didTapHeading(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var bannerBorder: UIView = {
        let view = UIView()

        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 6
        if #available(iOS 13.0, *) {
            view.layer.cornerCurve = .continuous
        }
        
        return view
    }()

    private lazy var bannerBadge: UIView = {
        let view = UIView()

        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true

        return view
    }()
    
    private lazy var detailTextView: UITextView = {
        let textView = UITextView()

        textView.textAlignment = .center
        textView.font = Font.statusDetail
        textView.backgroundColor = .clear
        textView.isUserInteractionEnabled = true
        textView.isSelectable = false
        textView.isEditable = false
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        return textView
    }()

    private lazy var appUpdatesAvailableButton: UIButton = {
        let button = UIButton(type: .custom)

        button.setTitle(Localizations.NewVersionAvailableAlert.message, for: .normal)
        button.setTitleColor(Color.warning, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapAppUpdatesAvailableButton(_:)), for: .touchUpInside)

        return button
    }()
    
    private lazy var console: UIView = {
        let view = UIView()
        let content = UILayoutGuide()
        
        view.backgroundColor = Color.consoleBackground
        
        view.addLayoutGuide(content)
        view.addSubview(engageButton)
        view.addSubview(uptimeLabel)
        view.addSubview(lastCheckedDateTimeLabel)
        view.addSubview(versionLabel)
        
        content.snp.makeConstraints {
            $0.top.equalTo(view.snp.top)
            $0.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        engageButton.snp.makeConstraints {
            $0.centerX.equalTo(content)
            $0.top.equalTo(content).offset(39)
            $0.height.equalTo(48)
            $0.width.equalTo(240)
        }

        uptimeLabel.snp.makeConstraints {
            $0.centerX.equalTo(content)
            $0.top.equalTo(engageButton.snp.bottom).offset(20)
            $0.width.equalToSuperview().inset(4)
        }

        lastCheckedDateTimeLabel.snp.makeConstraints {
            $0.centerX.equalTo(content)
            $0.top.equalTo(uptimeLabel.snp.bottom)
        }

        versionLabel.snp.makeConstraints {
            $0.centerX.equalTo(content)
            $0.bottom.equalTo(content).offset(-12)
        }
        
        return view
    }()

    private lazy var engageButton: StyledButton = {
        let button = StyledButton(style: .major)

        button.setTitle(Localizations.RiskStatusView.EngageButton.enable, for: .normal)
        button.addTarget(self, action: #selector(didTapEngageButton(_:)), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true

        return button
    }()
    
    private lazy var uptimeLabel: UILabel = {
        let label = UILabel()

        label.textColor = Color.footerText
        label.textAlignment = .center
        label.font = Font.upTime
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()

    private lazy var lastCheckedDateTimeLabel: UILabel = {
        let label = UILabel()

        label.textColor = Color.footerText
        label.textAlignment = .center
        label.font = Font.upTime

        return label
    }()

    private lazy var versionLabel: UILabel = {
        let label = UILabel()

        label.textColor = Color.footerText
        label.textAlignment = .center
        label.font = Font.version
        label.text = "V\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0")"

        return label
    }()

    init(viewModel: RiskStatusViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
        configureNavigationItems()
        configureUI()
        configureViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.isHintPresentable = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
        super.viewWillDisappear(animated)
    }
    
    private func configureNavigationItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: Image.iconMenu, style: .plain, target: self, action: #selector(didTapMoreBarButton(_:)))
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(image: Image.iconQRScanner, style: .plain, target: self, action: #selector(didTapQRCodeScanner(_:)))
        ]

        #if DEBUG
        navigationItem.leftBarButtonItems?.append(UIBarButtonItem.init(title: "     ", style: .plain, target: self, action: #selector(didTapEngineerBarButton(_:))))
        #endif
    }
    
    private func configureUI() {
        let stack: UIStackView = {
            let _stack = UIStackView()
            
            _stack.axis = .vertical
            _stack.spacing = 13
            _stack.alignment = .center

            _stack.addArrangedSubview(banner)
            _stack.addArrangedSubview(detailTextView)
            _stack.insertSubview(bannerBorder, at: 0)
            _stack.insertSubview(bannerBadge, at: 0)
            
            banner.snp.makeConstraints {
                $0.leading.greaterThanOrEqualTo(_stack.safeAreaLayoutGuide).offset(32)
                $0.trailing.lessThanOrEqualTo(_stack.safeAreaLayoutGuide).offset(-32)
                $0.height.equalTo(banner.titleLabel!).offset(10)
            }
            
            bannerBorder.snp.makeConstraints {
                $0.width.equalTo(banner).offset(18)
                $0.height.equalTo(banner).offset(10)
                $0.center.equalTo(banner)
            }

            bannerBadge.snp.makeConstraints {
                $0.size.equalTo(CGSize(width: 10, height: 10))
                $0.top.equalTo(bannerBorder).offset(-4)
                $0.right.equalTo(bannerBorder).offset(4)
            }
            
            detailTextView.snp.makeConstraints {
                $0.width.equalToSuperview().offset(-70)
                $0.height.greaterThanOrEqualTo(160)
            }
            
            return _stack
        }()

        let layoutGuide: UILayoutGuide = UILayoutGuide()
        
        view.backgroundColor = Color.background

        view.addLayoutGuide(layoutGuide)
        view.addSubview(stack)
        view.addSubview(appUpdatesAvailableButton)
        view.addSubview(console)

        layoutGuide.snp.makeConstraints {
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(console.snp.top)
        }

        stack.snp.makeConstraints {
            $0.centerY.left.right.equalTo(layoutGuide)
        }

        appUpdatesAvailableButton.snp.makeConstraints {
            $0.leading.greaterThanOrEqualTo(layoutGuide).offset(32)
            $0.trailing.lessThanOrEqualTo(layoutGuide).offset(-32)
            $0.centerX.equalTo(layoutGuide)
            $0.bottom.equalTo(layoutGuide).offset(-40)
        }
        
        console.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-200)
        }
    }

    private func configureViewModel() {
        viewModel.$title { [weak self] (title) in
            self?.title = title
        }
        
        viewModel.$status { [weak self] (status) in
            switch status {
            case .risky, .clear:
                self?.bannerBorder.isHidden = false
                self?.bannerBadge.isHidden = false
                self?.banner.isEnabled = true

            case .notTracing:
                self?.bannerBorder.isHidden = false
                self?.bannerBadge.isHidden = true
                self?.banner.isEnabled = false

            case .unknown:
                self?.bannerBorder.isHidden = true
                self?.bannerBadge.isHidden = true
                self?.banner.isEnabled = false
            }
        }

        viewModel.$exposureNotificationStatus { [weak self] (status) in
            guard let self = self else {
                return
            }

            switch status {
            case .active:
                self.engageButton.setTitle(Localizations.RiskStatusView.EngageButton.enabled, for: .normal)
                self.engageButton.isHidden = false
                self.engageButton.isEnabled = false

            case .inactive:
                self.engageButton.setTitle(Localizations.RiskStatusView.EngageButton.enable, for: .normal)
                self.engageButton.isHidden = false
                self.engageButton.isEnabled = true

            case .unknown:
                self.engageButton.isHidden = true
                self.engageButton.isEnabled = false
            }
        }
        
        viewModel.$riskStatus { [weak self] (status) in
            guard let self = self else {
                return
            }
            
            let tintColor: UIColor
            switch status {
            case .clear:
                tintColor = Color.safe
                
            case .risky:
                tintColor = Color.warning
            }
            
            self.banner.setTitleColor(tintColor, for: .normal)
            self.bannerBorder.layer.borderColor = tintColor.cgColor
            self.bannerBadge.backgroundColor = tintColor
            self.detailTextView.textColor = tintColor
        }

        viewModel.$engagementStatistic { [weak self] (statistic) in
            guard statistic.engageDate != .distantPast else {
                self?.uptimeLabel.text = ""
                return
            }

            self?.uptimeLabel.text = Localizations.RiskStatusView.engageDateAndUptimeRatioLabel(uptimeRatio: statistic.uptimeRatio, engageDate: statistic.engageDate)
        }

        viewModel.$lastCheckedDateTime { [weak self] (lastCheckedDateTime) in
            guard lastCheckedDateTime != .distantPast else {
                self?.lastCheckedDateTimeLabel.text = ""
                return
            }

            self?.lastCheckedDateTimeLabel.text = Localizations.RiskStatusView.lastCheckTimeLabel(checkDate: ExposureManager.shared.dateLastPerformedExposureDetection)
        }
        
        viewModel.$diagnosis { [weak self] (diagnosis) in
            self?.banner.setTitle(diagnosis.banner, for: .normal)
            self?.detailTextView.attributedText = self?.buildDiagnosisDetail(diagnosis.detail)
        }

        viewModel.$appUpdatesAvailable { [weak self] (isAvailable) in
            self?.appUpdatesAvailableButton.isHidden = isAvailable == false
        }

        viewModel.$pendingHints { [weak self] (hints) in
            if let hint = hints.first {
                self?.showHint(hint)
            } else {
                AppCoordinator.shared.hideOverlay()
            }
        }

        viewModel.engageErrorHandler = { [weak self] (reason) in
            switch reason {
            case .disabled, .unauthorized:
                #if DEBUG
                fatalError("Engage error .disabled should be handled in RiskStatusViewModel.")
                #endif

            case .bluetoothOff:
                let confirm = UIAlertController(title: Localizations.EnableBluetoothAlert.title, message: Localizations.EnableBluetoothAlert.message, preferredStyle: .alert)
                confirm.addAction(UIAlertAction(title: Localizations.Alert.Button.cancel, style: .cancel, handler: nil))
                confirm.addAction(UIAlertAction(title: Localizations.EnableBluetoothAlert.Button.enable, style: .default) { _ in
                    AppCoordinator.shared.openSettingsApp()
                })
                self?.present(confirm, animated: true, completion: nil)

            case .denied:
                AppCoordinator.shared.openSettingsApp()

            case .restricted:
                //TODO: Show message to unlock restriction
                break

            case .unsupported:
                //TODO: Show message to upgrade OS
                break
            }
        }

        viewModel.appUpdatesHandler = { [weak self] in
            guard let `self` = self else {
                return
            }

            let alert = UIAlertController(title: Localizations.NewVersionAvailableAlert.title,
                                          message: Localizations.NewVersionAvailableAlert.message,
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: Localizations.Alert.Button.later,
                                          style: .cancel,
                                          handler: nil))
            alert.addAction((UIAlertAction(title: Localizations.NewVersionAvailableAlert.Button.updateNow,
                                           style: .default,
                                           handler: { [weak self] _ in
                                            guard let `self` = self else {
                                                return
                                            }

                                            UpdatesUI.presentAppStore(presentingViewController: self)
                                           })))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @objc private func didTapHeading(_ sender: UIButton) {
        self.navigationController?.pushViewController(DailySummaryViewController(viewModel: DailySummaryViewModel()), animated: true)
    }

    @objc private func didTapAppUpdatesAvailableButton(_ sender: UIButton) {
        viewModel.appUpdatesHandler?()
    }

    @objc private func didTapEngageButton(_ sender: UIButton) {
        viewModel.engageExposureNotification()
    }
    
    @objc private func didTapMoreBarButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: Localizations.RiskStatusView.MoreActionSheet.title, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: Localizations.IntroductionView.title, style: .default) { [weak self] action in
            self?.navigationController?.pushViewController(IntroductionViewController(viewModel: IntroductionViewModel(type: .about)), animated: true)
        })

        alert.addAction(UIAlertAction(title: Localizations.DailySummaryViewModel.title, style: .default) { [weak self] action in
            self?.navigationController?.pushViewController(DailySummaryViewController(viewModel: DailySummaryViewModel()), animated: true)
        })

        //TODO: Alert Cancellation
        if viewModel.riskStatus == .risky {
            alert.addAction(UIAlertAction(title: Localizations.AlertCancellationViewModel.title, style: .default) { [weak self] action in
                let confirm = UIAlertController(title: Localizations.RiskStatusView.AlertCancellationAlert.title,
                                                message: Localizations.RiskStatusView.AlertCancellationAlert.message,
                                                preferredStyle: .alert)
                confirm.addAction(UIAlertAction(title: Localizations.Alert.Button.yes, style: .default) { [weak self] action in
                    self?.navigationController?.pushViewController(AlertCancellationViewController(viewModel: AlertCancellationViewModel()), animated: true)
                })
                confirm.addAction(UIAlertAction(title: Localizations.Alert.Button.no, style: .cancel, handler: nil))
                self?.present(confirm, animated: true, completion: nil)
            })
        }
        
        alert.addAction(UIAlertAction(title: Localizations.RiskStatusView.MoreActionSheet.Item.uploadIDs, style: .default) { [weak self] action in
            let confirm = UIAlertController(title: Localizations.RiskStatusView.UploadIDsAlert.title,
                                            message: Localizations.RiskStatusView.UploadIDsAlert.message,
                                            preferredStyle: .alert)
            confirm.addAction(UIAlertAction(title: Localizations.Alert.Button.yes, style: .default) { [weak self] action in
                self?.navigationController?.pushViewController(UploadKeysViewController(viewModel: UploadKeysViewModel()), animated: true)
            })
            confirm.addAction(UIAlertAction(title: Localizations.Alert.Button.no, style: .cancel, handler: nil))
            self?.present(confirm, animated: true, completion: nil)
        })

        alert.addAction(UIAlertAction(title: Localizations.PersonalDataProtectionNote.title, style: .default) { [weak self] action in
            self?.navigationController?.pushViewController(WebViewController(viewModel: .personalDataProtectionNote), animated: true)
        })

        alert.addAction(UIAlertAction(title: Localizations.DataControlViewModel.title, style: .default) { [weak self] action in
            self?.navigationController?.pushViewController(DataControlViewController(viewModel: DataControlViewModel()), animated: true)
        })
        
        alert.addAction(UIAlertAction(title: Localizations.FAQ.title, style: .default) { [weak self] action in
            self?.present(SFSafariViewController(viewModel: .faq), animated: true, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: Localizations.Alert.Button.cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc private func didTapQRCodeScanner(_ sender: UIBarButtonItem) {
        presentQRCodeScanner()
    }

    #if DEBUG
    @objc private func didTapEngineerBarButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Development", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Clear", style: .default) { [weak self] action in
            self?.viewModel.debugSetRiskStatus(.clear)
        })
        
        alert.addAction(UIAlertAction(title: "Risky", style: .default) { [weak self] action in
            self?.viewModel.debugSetRiskStatus(.risky)
        })

        alert.addAction(UIAlertAction(title: "detect", style: .default) { action in
           _ = ExposureManager.shared.detectExposures { (success) in
                logger.info("detectExposures: \(success)")
            }
        })

        alert.addAction(UIAlertAction(title: "Clear Hints", style: .default, handler: { _ in
            HintManager.shared.resetPresentedHints()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    #endif

    func presentQRCodeScanner() {
        let scannerViewModel = QRCodeScannerViewModel()
        func presentScanner() {
            let viewController = UINavigationController(rootViewController: QRCodeScannerViewController(viewModel: scannerViewModel))
//                viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        }

        switch scannerViewModel.authorizationStatus {
        case .unauthorized:
            let alert = UIAlertController(title: Localizations.AccessCameraAlert.title,
                                          message: Localizations.AccessCameraAlert.message,
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: Localizations.Alert.Button.notAllow,
                                          style: .cancel,
                                          handler: nil))
            alert.addAction(UIAlertAction(title: Localizations.Alert.Button.ok,
                                          style: .default,
                                          handler: { _ in
                                            AppCoordinator.shared.openSettingsApp()
                                          }))

            self.present(alert, animated: true, completion: nil)

        case .authorized:
            presentScanner()

        case .notDetermined:
            scannerViewModel.$authorizationStatus { (authorization) in
                switch authorization {
                case .authorized:
                    presentScanner()

                default:
                    break
                }
            }
            scannerViewModel.configure()
        }
    }
    
    private func showHint(_ hint: Hint) {
        switch hint {
        case .dailySummaryHint:
            AppCoordinator.shared.showOverlay(for: hint, from: bannerBorder)

        case .qrCodeScannerHint:
            AppCoordinator.shared.showOverlay(for: hint, from: navigationItem.leftBarButtonItem!)

        default:
            return
        }
    }
}

extension RiskStatusViewController {
    enum Color {
        static let background = UIColor(red: (235/255.0), green: (235/255.0), blue: (235/255.0), alpha: 1)

        static let safe = UIColor(red: (46/255.0), green: (182/255.0), blue: (169/255.0), alpha: 1)
        static let warning = UIColor(red: (217/255.0), green: (115/255.0), blue: (115/255.0), alpha: 1)
        
        static let footerText = UIColor(red: (73/255.0), green: (97/255.0), blue: (94/255.0), alpha: 1)
        static let consoleBackground = UIColor.white
        static let riskyDetailGrey = UIColor(red: (73/255.0), green: (97/255.0), blue: (94/255.0), alpha: 1)
    }
    
    enum Font {
        static let statusTitle = UIFont(name: "PingFangTC-Semibold", size: 20.0)!
        static let statusDetail = UIFont(name: "PingFangTC-Regular", size: 17.0)!
        static let riskyDetail = UIFont(name: "PingFangTC-Regular", size: 14.0)!
        static let riskyDetailBold = UIFont(name: "PingFangTC-Semibold", size: 14.0)!
        static let upTime = UIFont(name: "PingFangTC-Regular", size: 13.0)!
        static let version = UIFont(name: "PingFangTC-Regular", size: 12.0)!
    }

    enum Image {
        static let iconMenu = UIImage(named: "iconMenu")!.withRenderingMode(.alwaysOriginal)
        static let iconQRScanner = UIImage(named: "iconQRCode")!.withRenderingMode(.alwaysOriginal)
    }
}

extension Localizations {
    enum RiskStatusView {
        static func engageDateAndUptimeRatioLabel(uptimeRatio: Double, engageDate: Date) -> String {
            String(format: NSLocalizedString("RiskStatusView.EngageDateAndUptimeRatioLabel",
                                             value: "Exposure Notification operating ratio %.01f%%\n Since enabled at %@",
                                             comment: "The label text on risk status view to indicate the engaged date and uptime ratio"),
                   uptimeRatio * 100,
                   engageDate.displayDateTimeDescription)
        }

        static func lastCheckTimeLabel(checkDate: Date) -> String {
            String(format: NSLocalizedString("RiskStatusView.LastCheckTimeLabel",
                                             value: "Last checked at %@",
                                             comment: "The label text on risk status view to indicate the last time checking exposures"),
                   checkDate.displayDateTimeDescription)
        }

        static let detailTextParagraphHeaderSeparator = NSLocalizedString("RiskStatusView.DetailTextParagraphHeaderSeparator",
                                                           value: ":",
                                                           comment: "The punctuation at the beginning of each paragraph to indicate header").first!

        enum EngageButton {
            static let enable = NSLocalizedString("RiskStatusView.EngageButton.Enable",
                                                  value: "Enable Exposure Notification",
                                                  comment: "The button title on risk status view to enable exposure notification")
            static let enabled = NSLocalizedString("RiskStatusView.EngageButton.Enabled",
                                                   value: "Notification is Enabled",
                                                   comment: "The button title on risk status view to indicate exposure notification has been enabled")
        }

        enum MoreActionSheet {
            static let title = NSLocalizedString("RiskStatusView.MoreActionSheet.Title",
                                                 value: "More",
                                                 comment: "The title of action sheet on risk status view for more features")
            enum Item {
                static let uploadIDs = NSLocalizedString("RiskStatusView.MoreActionSheet.Item.UploadIDs.Title",
                                                         value: "Upload Anonymous IDs",
                                                         comment: "The title of action sheet on risk status view for upload anonymous IDs")
            }
        }

        enum AlertCancellationAlert {
            static let title = NSLocalizedString("RiskStatusView.AlertCancellationAlert.Title",
                                                 value: "Are you sure you want to reset your status?",
                                                 comment: "The title of alert on risk status view for alert cancellation")
            static let message = NSLocalizedString("RiskStatusView.AlertCancellationAlert.Message",
                                                   value: "Reset status upon completion of contact tracing assessment.",
                                                   comment: "The message body of alert on risk status view for alert cancellation")
        }

        enum UploadIDsAlert {
            static let title = NSLocalizedString("RiskStatusView.UploadIDsAlert.Title",
                                                 value: "Have You Had a Positive Test?",
                                                 comment: "The title of alert on risk status view for upload anonymous IDs")
            static let message = NSLocalizedString("RiskStatusView.UploadIDsAlert.Message",
                                                   value: "Upload your anonymous IDs to reduce transmission.",
                                                   comment: "The message body of alert on risk status view for upload anonymous IDs")
        }
    }
    
    enum NewVersionAvailableAlert {
        static let title = NSLocalizedString("NewVersionAvailableAlert.Title",
                                             value: "New Version Available",
                                             comment: "The title of new version available alert")
        static let message = NSLocalizedString("NewVersionAvailableAlert.Message",
                                               value: "Please update in App Store.",
                                               comment: "The message body of new version available alert")
        enum Button {
            static let updateNow = NSLocalizedString("NewVersionAvailableAlert.Button.UpdateNow",
                                                     value: "Update Now",
                                                     comment: "The updates now button title of new version available alert")
        }
    }

    enum AccessCameraAlert {
        static let title = NSLocalizedString("AccessCameraAlert.Title",
                                             value: "Taiwan Social Distancing Would Like to Access the Camera",
                                             comment: "The title of alert for requesting to access user's camera")
        static let message = NSLocalizedString("AccessCameraAlert.Message",
                                               value: "Taiwan Social Distancing uses the camera to scan QR code for 1922 SMS contact tracing registration.",
                                               comment: "The body message of alert for requesting to access user's camera")
    }
}

extension RiskStatusViewController {
    private func buildDiagnosisDetail(_ detail: String) -> NSAttributedString {
        switch viewModel.riskStatus {
        case .risky:
            return formatRiskyDetailIfNeeded(detail)
        case .clear:
            return NSAttributedString(string: detail, attributes: normalAttributes())
        }
    }
    
    private func formatRiskyDetailIfNeeded(_ detail: String) -> NSAttributedString {
        let sentences = detail.split(separator: "\n")
        let maybeBullet = sentences.count > 1 ? "\u{2022} " : ""
        let attributes = riskyAttributes(bullet: maybeBullet)
        let boldAttributes: [NSAttributedString.Key : Any] = [.font: Font.riskyDetailBold]

        return sentences
            .map {
                // Create styled paragraph which prepended by bullet
                NSMutableAttributedString(string:"\(maybeBullet)\($0)", attributes: attributes)
            }
            .map {
                // If separator is found, make any words before the first separator bold.
                if let separatorIndex = $0.string.firstIndex(of: Localizations.RiskStatusView.detailTextParagraphHeaderSeparator) {
                    $0.addAttributes(boldAttributes, range: NSRange(($0.string.startIndex..<separatorIndex), in: $0.string))
                }

                return $0
            }
            .reduce(into: NSMutableAttributedString()) { (result, element: NSMutableAttributedString) in
                // Combine all paragraphs
                if result.length != 0 {
                    result.append(NSAttributedString(string: "\n"))
                }
                result.append(element)
            }
    }
    
    private func riskyAttributes(bullet: String = "") -> [NSAttributedString.Key: Any] {
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = Font.riskyDetail
        attributes[.foregroundColor] = Color.riskyDetailGrey
        attributes[.paragraphStyle] = {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.headIndent = (bullet as NSString).size(withAttributes: attributes).width
            paragraphStyle.lineSpacing = 6
            paragraphStyle.alignment = bullet.isEmpty ? .center : .left
            return paragraphStyle
        }()

        return attributes
    }
    
    private func normalAttributes() -> [NSAttributedString.Key: Any] {
        var attributes = [NSAttributedString.Key: Any]()
        attributes[.font] = Font.statusDetail
        attributes[.foregroundColor] = Color.safe
        attributes[.paragraphStyle] = {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            paragraphStyle.alignment = .center
            return paragraphStyle
        }()

        return attributes
    }
}
