//
//  AppCoordinator.swift
//  Tracer
//
//  Created by Shiva Huang on 2020/3/27.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import Logging
import LoggingSwiftyBeaver
import SnapKit
import UIKit
import UserNotifications

let logger: Logger = {
    let logger = Logger(label: "ExposureNotification", factory: { (label) in
        #if DEBUG
        return SwiftyBeaver.LogHandler(label, destinations: [ConsoleDestination()])
        #else
        return Logging.SwiftLogNoOpLogHandler()
        #endif
    })

    return logger
}()

class AppCoordinator: UIViewController {
    
    enum Status {
        case unsupported
        case onboarding
        case ready
    }

    static let shared = AppCoordinator()
    
    private var status: Status! {
        didSet {
            statusDidChange()
        }
    }

    private var contentViewController: UIViewController? {
        didSet {
            guard let controller = contentViewController else {
                assertionFailure("Error: Set coordinator's contentViewController to nil.")
                return
            }
            
            oldValue?.willMove(toParent: nil)
            oldValue?.view.snp.removeConstraints()
            oldValue?.view.removeFromSuperview()
            oldValue?.removeFromParent()
            
            self.addChild(controller)
            contentView.addSubview(controller.view)
            controller.view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private lazy var contentView: UIView = { UIView() }()

    private var observers: [NSObjectProtocol] = []

    private init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.addSubview(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let image = UIImage()
        UINavigationBar.appearance().setBackgroundImage(image, for: .default)
        UINavigationBar.appearance().shadowImage = image
        UINavigationBar.appearance().tintColor = Color.barTint
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: Color.barTitle,
                                                            .font: Font.barTitle]

        if ExposureManager.supportedExposureNotificationsVersion != .version2 {
            transitStatus(to: .unsupported)
        } else if UserPreferenceManager.shared.isIntroductionWatched {
            transitStatus(to: .ready)
        } else {
            transitStatus(to: .onboarding)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerNotificationObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)

        observers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }
    
    // TODO: More precise state transition control
    func transitStatus(to newStatus: Status) {
        switch (status, newStatus) {
        case (_, .unsupported):
            status = newStatus

        case (_, .onboarding):
            status = newStatus
            
        case (_, .ready):
            status = newStatus
        }
    }

    private func statusDidChange() {
        switch status {
        case .none:
            break

        case .unsupported:
            contentViewController = IntroductionViewController(viewModel: IntroductionViewModel(type: .unsupported))

        case .onboarding:
            contentViewController = IntroductionViewController(viewModel: IntroductionViewModel(type: .firstTimeUse))
            
        case .ready:
            contentViewController = UINavigationController(rootViewController: RiskStatusViewController(viewModel: RiskStatusViewModel()))
            installShortcutItems()
        }
    }
    
    private func registerNotificationObserver() {
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(forName: UIScene.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] (_) in
                NotificationCenter.default.post(name: .willEnterForegroundNotification, object: self)
            }
            
            NotificationCenter.default.addObserver(forName: UIScene.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] (_) in
                NotificationCenter.default.post(name: .didEnterBackgroundNotification, object: self)
            }
        } else {
            NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] (_) in
                NotificationCenter.default.post(name: .willEnterForegroundNotification, object: self)
            }
            
            NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] (_) in
                NotificationCenter.default.post(name: .didEnterBackgroundNotification, object: self)
            }
        }

        observers = [
            UserPreferenceManager.shared.$isIntroductionWatched { [unowned self] in
                logger.info("UserPreferenceManager.shared.isIntroductionWatched changed to \(UserPreferenceManager.shared.isIntroductionWatched)")
                self.transitStatus(to: .ready)
            },
            ExposureManager.shared.$exposureNotificationStatus { [unowned self] in
                if ExposureManager.shared.exposureNotificationStatus == .active {
                    self.enablePushNotifications()
                }
            }
        ]
    }

    func openSettingsApp() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
}

extension AppCoordinator {
    func enablePushNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings {[weak self] settings in
            func showAlert() {
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(title: Localizations.NotificationNotEnabledAlert.title,
                                                  message: Localizations.NotificationNotEnabledAlert.message,
                                                  preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: Localizations.Alert.Button.cancel, style: .cancel))
                    alert.addAction(UIAlertAction(title: Localizations.Alert.Button.allow, style: .default) { (_) in
                        AppCoordinator.shared.openSettingsApp()
                    })

                    self?.present(alert, animated: true, completion: nil)
                }
            }

            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
                    if granted == false {
                        showAlert()
                    }
                }

            case .denied, .provisional, .ephemeral:
                showAlert()

            case .authorized:
                break

            @unknown default:
                break
            }
        }
    }
}

extension AppCoordinator {
    // List of known shortcut actions.
    enum ActionType: String {
        case qrCodeScanningAction = "QRCodeScanningAction"
    }

    func installShortcutItems() {
        // Shortcut is supported by iPhone 6s and later, but iPhone 6s can't run iOS 12.5, so we use iOS 13 as the checking criterion.
        if #available(iOS 13, *) {
            UIApplication.shared.shortcutItems = [
                UIApplicationShortcutItem(type: ActionType.qrCodeScanningAction.rawValue,
                                          localizedTitle: Localizations.ShortcutItem.QRCodeScanningAction.title,
                                          localizedSubtitle: nil,
                                          icon: UIApplicationShortcutIcon(systemImageName: "qrcode.viewfinder"),
                                          userInfo: nil)]
        }
    }

    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        /** In this sample an alert is being shown to indicate that the action has been triggered,
            but in real code the functionality for the quick action would be triggered.
        */
        if let actionTypeValue = ActionType(rawValue: shortcutItem.type) {
            switch actionTypeValue {
            case .qrCodeScanningAction:
                guard status == .ready else {
                    return true
                }

                if let contentViewController = contentViewController as? UINavigationController,
                   let riskViewController = contentViewController.viewControllers.first as? RiskStatusViewController {
                    contentViewController.popToRootViewController(animated: false)
                    riskViewController.presentQRCodeScanner()
                }
            }
        }

        return true
    }
}

extension Notification.Name {
    static let willEnterForegroundNotification = Notification.Name("willEnterForegroundNotification")
    static let didEnterBackgroundNotification = Notification.Name("didEnterBackgroundNotification")
}

extension AppCoordinator {
    enum Color {
        static let barTitle = UIColor(red: (73/255.0), green: (97/255.0), blue: (94/255.0), alpha: 1)
        static let barTint = UIColor(red: (46/255.0), green: (182/255.0), blue: (169/255.0), alpha: 1)
    }
    
    enum Font {
        static let barTitle = UIFont(name: "PingFangTC-Semibold", size: 20.0)!
    }
}
