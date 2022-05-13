//
//  ExposureManager.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/3/8.
//  Copyright © 2021 AI Labs. All rights reserved.
//

#if canImport(BackgroundTasks)
import BackgroundTasks
#endif
import CoreKit
import ExposureNotification
import Foundation
import PromiseKit
import UserNotifications
import Zip

class ExposureManager {

    static let shared = ExposureManager()

    static let isENManagerAvailable: Bool = {
        NSClassFromString("ENManager") != nil
    }()

    static let supportedExposureNotificationsVersion: SupportedExposureNotificationsAPIVersion = {
        if #available(iOS 13.7, *) {
            return .version2
        } else if #available(iOS 13.5, *) {
            return .version1
        } else if isENManagerAvailable { // iOS 12.5
            return .version2
        } else { // iOS 13.0 ~ 13.4
            return .unsupported
        }
    }()

    private static let backgroundTaskIdentifier = Bundle.main.bundleIdentifier! + ".exposure-notification"
    private let manager: ENManager = ENManager()
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let diagnosisKeysURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("DiagnosisKeys")

    var managerActivated: Bool = false

    private(set) var detectingExposures = false

    enum Status: Equatable {
        case unknown
        case active
        case inactive(InactiveReason)
    }

    enum InactiveReason {
        case notDetermined
        case disabled
        case restricted
        case unauthorized
        case denied
        case bluetoothOff
        case unsupported
    }

    @Notified(notificationName: ExposureManager.exposureNotificationEnabledDidChangeNotification)
    var exposureNotificationEnabled: Bool = false

    @Notified(notificationName: ExposureManager.exposureNotificationStatusDidChangeNotification)
    var exposureNotificationStatus: Status = .unknown

    @Persisted(userDefaultsKey: "revisionToken", notificationName: ExposureManager.revisionTokenDidChangeNotification, defaultValue: nil)
    private(set) var revisionToken: String?

    @Persisted(userDefaultsKey: "dateLastPerformedExposureDetection", notificationName: ExposureManager.dateLastPerformedExposureDetectionDidChangeNotification, defaultValue: .distantPast)
    private(set) var dateLastPerformedExposureDetection: Date

    @Persisted(userDefaultsKey: "detectedDiagnosisKeyFiles", notificationName: ExposureManager.detectedDiagnosisKeyFilesDidChangeNotification, defaultValue: [])
    var detectedDiagnosisKeyFiles: Set<String>

    private var observations: [NSKeyValueObservation] = []

    private init() {
        manager.activate { [unowned self] _ in
            // Ensure Exposure Notifications is enabled if the app is authorized. The app
            // could get into a state where it is authorized, but Exposure Notifications
            // is not enabled, if the user initially denied Exposure Notifications
            // during onboarding, but then flipped on the "COVID-19 Exposure Notifications" switch
            // in Settings.
//            if self.exposureNotificationEnabled == false {
//                self.setExposureNotificationEnabled(true) { (error) in
//                    if let error = error {
//                        logger.error("Error attempting to enable on launch: \(error.localizedDescription)")
//                    }
//                }
//            }
            managerActivated = true

            observations.append(contentsOf: [
                manager.observe(\.exposureNotificationEnabled, options: [.initial, .new]) { [unowned self] (_manager, _) in
                    if exposureNotificationEnabled != _manager.exposureNotificationEnabled {
                        exposureNotificationEnabled = _manager.exposureNotificationEnabled
                    }
                },
                manager.observe(\.exposureNotificationStatus, options: [.initial, .new]) { [unowned self] (_manager, _) in
                    updateStatus()
                }
            ])
        }
    }

    deinit {
        observations.removeAll()

        manager.invalidate()
    }

    private func updateStatus() {
        switch (ENManager.authorizationStatus, manager.exposureNotificationStatus) {
        case (_, _) where Self.supportedExposureNotificationsVersion != .version2:
            exposureNotificationStatus = .inactive(.unsupported)

        case (_, .unknown):
            exposureNotificationStatus = .unknown
            
        case (.unknown, _):
            exposureNotificationStatus = .inactive(.notDetermined)
            
        case (.notAuthorized, _):
            exposureNotificationStatus = .inactive(.denied)

        case (_, .unauthorized):
            exposureNotificationStatus = .inactive(.unauthorized)
            
        case (.restricted, _), (_, .restricted):
            exposureNotificationStatus = .inactive(.restricted)

        case (.authorized, .active):
            exposureNotificationStatus = .active

        case (.authorized, .bluetoothOff):
            exposureNotificationStatus = .inactive(.bluetoothOff)

        case (.authorized, .disabled):
            exposureNotificationStatus = .inactive(.disabled)

        case (_, _):
            logger.warning("Unhandled ENStatus: ENManager.authorizationStatus: \(ENManager.authorizationStatus.rawValue), manager.exposureNotificationStatus: \(manager.exposureNotificationStatus.rawValue)")
        }

        UserManager.shared.updateEngagementStatistic()
    }

    func setExposureNotificationEnabled(_ enabled: Bool, completionHandler: @escaping ENErrorHandler) {
        UserManager.shared.updateEngagementStatistic()

        guard exposureNotificationEnabled != enabled else {
            return
        }

        let oldStatus = exposureNotificationEnabled

        manager.setExposureNotificationEnabled(enabled) { [unowned self] (error) in
            updateStatus()

            if manager.exposureNotificationEnabled != oldStatus {
                NotificationCenter.default.post(name: Self.authorizationStatusDidChangeNotification, object: nil)
            }
            
            completionHandler(error)
        }
    }

    //MARK: - Obtaining Exposure Keys
    private func getDiagnosisKeys() -> Promise<[ENTemporaryExposureKey]> {
        Promise { (seal) in
            let completionHandler: ENGetDiagnosisKeysHandler = { (keys, error) in
                guard error == nil, let keys = keys else {
                    seal.reject(error!)
                    return
                }

                seal.fulfill(keys)
            }
            #if DEBUG
            manager.getTestDiagnosisKeys(completionHandler: completionHandler)
            #else
            manager.getDiagnosisKeys(completionHandler: completionHandler)
            #endif
        }
    }

    func postDiagnosisKeys(using verificationCode: String, from start: Date, to end: Date) -> Promise<Bool> {
        let symmetricKey = {
            SymmetricKey(size: .bits128)
        }()

        let timeSpan = (start.enIntervalNumber..<end.enIntervalNumber)

        return firstly {
            Promise { (seal) in
                APIManager.shared.request(VerificationEndpoint.verify(code: verificationCode))
                    .done { (response: VerificationEndpoint.VerifyResponse) in
                        seal.fulfill(response)
                    }
                    .catch { error in
                        seal.reject(UploadError.verifyFailed)
                    }
            }
        }
        .then { (response: VerificationEndpoint.VerifyResponse) -> Promise<(VerificationEndpoint.VerifyResponse, [ENTemporaryExposureKey])> in
            Promise { (seal) in
                self.getDiagnosisKeys()
                    .filterValues { (key) -> Bool in
                        timeSpan.contains(key.rollingStartNumber)
                    }
                    .done { (keys) in
                        seal.fulfill((response, keys))
                    }
                    .catch { _ in
                        seal.reject(UploadError.keysNotFound)
                    }
            }
        }
        .map { (verifyResponse, keys: [ENTemporaryExposureKey]) -> (VerificationEndpoint, [ENTemporaryExposureKey], Date) in
            (VerificationEndpoint.certificate(token: verifyResponse.token, symmetricKey: symmetricKey, exposureKeys: keys), keys, verifyResponse.symptomDate)
        }
        .then { (certificate, keys, symptomDate) in
            firstly {
                APIManager.shared.request(certificate)
            }
            .map { (response: VerificationEndpoint.CertificateResponse) in
                (response, keys, symptomDate)
            }
        }
        .map { (response: VerificationEndpoint.CertificateResponse, keys: [ENTemporaryExposureKey], symptomDate: Date) in
            UploadEndpoint.publish(symmetricKey: symmetricKey, exposureKeys: keys, certificate: response.certificate, symptomDate: symptomDate)
        }
        .then{ (publish) in
            APIManager.shared.request(publish)
        }
        .then { (response: UploadEndpoint.PublishResponse) -> Promise<Bool> in
            self.revisionToken = response.revisionToken

            return Promise.value(response.insertedExposures != 0)
        }
    }
    
    func verifyCode(using verificationCode: String) -> Promise<VerificationEndpoint.VerifyResponse> {
        return Promise { (seal) in
            APIManager.shared.request(VerificationEndpoint.verify(code: verificationCode))
                .done { (response: VerificationEndpoint.VerifyResponse) in
                    seal.fulfill(response)
                }
                .catch { error in
                    seal.reject(UploadError.verifyFailed)
                }
        }
    }
    
    func checkDiagnosisKeys(from start: Date, to end: Date) -> Promise<[ENTemporaryExposureKey]> {
        let timeSpan = (start.enIntervalNumber..<end.enIntervalNumber)
        
        return Promise { (seal) in
            self.getDiagnosisKeys()
                .filterValues { (key) -> Bool in
                    timeSpan.contains(key.rollingStartNumber)
                }
                .done { (keys) in
                    if keys.count > 0 {
                        return seal.fulfill((keys))
                    } else {
                        return seal.reject(UploadError.keysNotFound)
                    }
                }
                .catch { error in
                    if let enError = error as? ENError, enError.errorCode == ENError.notAuthorized.rawValue {
                        seal.reject(UploadError.userDenied)
                    } else {
                        seal.reject(UploadError.unknown)
                    }
                }
        }
    }
    
    func uploadDiagnosisKeys(token: String, symptomDate: Date, keys: [ENTemporaryExposureKey]) -> Promise<Bool> {
        let symmetricKey = {
            SymmetricKey(size: .bits128)
        }()
        
        return firstly {
            APIManager.shared.request(VerificationEndpoint.certificate(token: token, symmetricKey: symmetricKey, exposureKeys: keys))
        }
        .map { (response: VerificationEndpoint.CertificateResponse) in
            (response, keys, symptomDate)
        }
        .map { (response: VerificationEndpoint.CertificateResponse, keys: [ENTemporaryExposureKey], symptomDate: Date) in
            UploadEndpoint.publish(symmetricKey: symmetricKey, exposureKeys: keys, certificate: response.certificate, symptomDate: symptomDate)
        }
        .then{ (publish) in
            APIManager.shared.request(publish)
        }
        .then { (response: UploadEndpoint.PublishResponse) -> Promise<Bool> in
            self.revisionToken = response.revisionToken

            return Promise.value(response.insertedExposures != 0)
        }
    }

    //MARK:- Obtaining Exposure Information
    private func getExposureConfiguration() -> Promise<ENExposureConfiguration> {
        let dataFromServer = """
        {
        "immediateDurationWeight":100,
        "nearDurationWeight":0,
        "mediumDurationWeight":0,
        "otherDurationWeight":0,
        "infectiousnessForDaysSinceOnsetOfSymptoms":{
            "unknown":1,
            "-14":1,
            "-13":1,
            "-12":1,
            "-11":1,
            "-10":1,
            "-9":1,
            "-8":1,
            "-7":1,
            "-6":1,
            "-5":1,
            "-4":1,
            "-3":1,
            "-2":1,
            "-1":1,
            "0":1,
            "1":1,
            "2":1,
            "3":1,
            "4":1,
            "5":1,
            "6":1,
            "7":1,
            "8":1,
            "9":1,
            "10":1,
            "11":1,
            "12":1,
            "13":1,
            "14":1
        },
        "infectiousnessStandardWeight":100,
        "infectiousnessHighWeight":100,
        "reportTypeConfirmedTestWeight":100,
        "reportTypeConfirmedClinicalDiagnosisWeight":100,
        "reportTypeSelfReportedWeight":100,
        "reportTypeRecursiveWeight":100,
        "reportTypeNoneMap":1,
        "minimumRiskScore":0,
        "attenuationDurationThresholds":[65, 75],
        "attenuationLevelValues":[0, 1, 1, 1, 1, 1, 1, 1],
        "daysSinceLastExposureLevelValues":[1, 2, 3, 4, 5, 6, 7, 8],
        "durationLevelValues":[1, 2, 3, 4, 5, 6, 7, 8],
        "transmissionRiskLevelValues":[1, 2, 3, 4, 5, 6, 7, 8]
        }
        """.data(using: .utf8)!

        return Promise { (seal) in
            do {
                let codableExposureConfiguration = try JSONDecoder().decode(ExposureConfiguration.self, from: dataFromServer)
                let exposureConfiguration = ENExposureConfiguration()
                if Self.isENManagerAvailable {
                    exposureConfiguration.immediateDurationWeight = codableExposureConfiguration.immediateDurationWeight
                    exposureConfiguration.nearDurationWeight = codableExposureConfiguration.nearDurationWeight
                    exposureConfiguration.mediumDurationWeight = codableExposureConfiguration.mediumDurationWeight
                    exposureConfiguration.otherDurationWeight = codableExposureConfiguration.otherDurationWeight
                    var infectiousnessForDaysSinceOnsetOfSymptoms = [Int: Int]()
                    for (stringDay, infectiousness) in codableExposureConfiguration.infectiousnessForDaysSinceOnsetOfSymptoms {
                        if stringDay == "unknown" {
                            if #available(iOS 14.0, *) {
                                infectiousnessForDaysSinceOnsetOfSymptoms[ENDaysSinceOnsetOfSymptomsUnknown] = infectiousness
                            } else {
                                // ENDaysSinceOnsetOfSymptomsUnknown is not available
                                // in earlier versions of iOS; use an equivalent value
                                infectiousnessForDaysSinceOnsetOfSymptoms[NSIntegerMax] = infectiousness
                            }
                        } else if let day = Int(stringDay) {
                            infectiousnessForDaysSinceOnsetOfSymptoms[day] = infectiousness
                        }
                    }
                    exposureConfiguration.infectiousnessForDaysSinceOnsetOfSymptoms = infectiousnessForDaysSinceOnsetOfSymptoms as [NSNumber: NSNumber]
                    exposureConfiguration.infectiousnessStandardWeight = codableExposureConfiguration.infectiousnessStandardWeight
                    exposureConfiguration.infectiousnessHighWeight = codableExposureConfiguration.infectiousnessHighWeight
                    exposureConfiguration.reportTypeConfirmedTestWeight = codableExposureConfiguration.reportTypeConfirmedTestWeight
                    exposureConfiguration.reportTypeConfirmedClinicalDiagnosisWeight = codableExposureConfiguration.reportTypeConfirmedClinicalDiagnosisWeight
                    exposureConfiguration.reportTypeSelfReportedWeight = codableExposureConfiguration.reportTypeSelfReportedWeight
                    exposureConfiguration.reportTypeRecursiveWeight = codableExposureConfiguration.reportTypeRecursiveWeight
                    if let reportTypeNoneMap = ENDiagnosisReportType(rawValue: UInt32(codableExposureConfiguration.reportTypeNoneMap)) {
                        exposureConfiguration.reportTypeNoneMap = reportTypeNoneMap
                    }
                }
                exposureConfiguration.minimumRiskScore = codableExposureConfiguration.minimumRiskScore
                exposureConfiguration.attenuationLevelValues = codableExposureConfiguration.attenuationLevelValues as [NSNumber]
                exposureConfiguration.daysSinceLastExposureLevelValues = codableExposureConfiguration.daysSinceLastExposureLevelValues as [NSNumber]
                exposureConfiguration.durationLevelValues = codableExposureConfiguration.durationLevelValues as [NSNumber]
                exposureConfiguration.transmissionRiskLevelValues = codableExposureConfiguration.transmissionRiskLevelValues as [NSNumber]
                exposureConfiguration.metadata = ["attenuationDurationThresholds": codableExposureConfiguration.attenuationDurationThresholds]
                seal.fulfill(exposureConfiguration)
            } catch {
                seal.reject(error)
            }
        }
    }

    private func getDiagnosisKeyFileURLs() -> Promise<(files: [String], keyFileUrls: [URL])> {
        firstly {
            APIManager.shared.request(ExportEndpoint.index)
        }
        .map { (content) in
            content.split(separator: "\n")
                .map(String.init)
                .filter {
                    self.detectedDiagnosisKeyFiles.contains($0) == false
                }
                .map { (filePath) in
                    (filePath, { _, _ in
                        let fileURL = self.documentsURL.appendingPathComponent(filePath)

                        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                    })
                }
        }
        .then { (tasks) -> Promise<(files: [String], keyFileUrls: [URL])> in
            when(fulfilled: tasks.map { (filePath, destination) in
                APIManager.shared.download(ExportEndpoint.download(path: filePath), to: destination)
            })
            .thenFlatMap { (zipUrl) -> Promise<[URL]> in
                Promise { (seal) in
                    do {
                        let fileExtension = zipUrl.pathExtension
                        let fileName = zipUrl.lastPathComponent
                        let directoryName = fileName.replacingOccurrences(of: ".\(fileExtension)", with: "")
                        let unzipDirectory = self.diagnosisKeysURL.appendingPathComponent(directoryName)

                        try Zip.unzipFile(zipUrl, destination: unzipDirectory, overwrite: true, password: nil)
                        let keyFiles = try FileManager.default.contentsOfDirectory(at: unzipDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
                        seal.fulfill(keyFiles)
                    } catch {
                        seal.reject(error)
                    }

                    try? FileManager.default.removeItem(at: zipUrl)
                }
            }
            .map { (keyFiles) -> (files: [String], keyFileUrls: [URL]) in
                (tasks.map { $0.0 }, keyFiles)
            }
        }
    }

    func detectExposures(completionHandler: ((Bool) -> Void)? = nil) -> Progress {

        let progress = Progress()

        // Disallow concurrent exposure detection, because if allowed we might try to detect the same diagnosis keys more than once
        guard !detectingExposures else {
            completionHandler?(false)
            return progress
        }
        detectingExposures = true
        
        when(fulfilled: getDiagnosisKeyFileURLs(), getExposureConfiguration())
            .then { (keyFiles, configuration) in
                Promise { (seal) in
                    #if !DEBUG
                    guard keyFiles.files.count != 0 else {
                        seal.fulfill(nil)
                        return
                    }
                    #endif
                    logger.info("File urls: \(keyFiles.files.count)")

                    self.manager.detectExposures(configuration: configuration, diagnosisKeyURLs: keyFiles.keyFileUrls) { summary, error in
                        if let error = error {
                            seal.reject(error)
                            return
                        }

                        self.detectedDiagnosisKeyFiles.formUnion(keyFiles.files)
                        seal.fulfill(summary)
                    }
                }
            }
            .done { (summary: ENExposureDetectionSummary?) in
                if progress.isCancelled {
                    completionHandler?(false)
                } else {
                    self.dateLastPerformedExposureDetection = Date()
                    UserManager.shared.updateRiskSummary(summary)
                    completionHandler?(true)
                }
            }
            .ensure {
                if FileManager.default.fileExists(atPath: self.diagnosisKeysURL.path) {
                    do {
                        try FileManager.default.removeItem(at: self.diagnosisKeysURL)
                    } catch {
                        logger.error("\(error)")
                    }
                }

                self.detectingExposures = false
            }
            .catch { (error) in
                logger.error("\(error)")
                completionHandler?(false)
            }

        return progress
    }

    func showBluetoothOffUserNotificationIfNeeded() {
        let identifier = "bluetooth-off"
        if case .inactive(.bluetoothOff) = exposureNotificationStatus {
            let content = UNMutableNotificationContent()
            content.title = Localizations.BluetoothNotEnabledNotification.title
            content.body = Localizations.BluetoothNotEnabledNotification.message
            content.sound = .default
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        logger.error("Error showing error user notification: \(error)")
                    }
                }
            }
        } else {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
        }
    }
}

extension ExposureManager {
    enum SupportedExposureNotificationsAPIVersion {
        case version2
        case version1
        case unsupported
    }
}

extension ExposureManager {
    static let authorizationStatusDidChangeNotification = Notification.Name("ExposureManager.authorizationStatusChangedNotification")
    static let exposureNotificationEnabledDidChangeNotification = Notification.Name("ExposureManager.exposureNotificationEnabledChangedNotification")
    static let exposureNotificationStatusDidChangeNotification = Notification.Name("ExposureManager.exposureNotificationStatusChangedNotification")
    static let revisionTokenDidChangeNotification = Notification.Name("ExposureManager.revisionTokenDidChangeNotification")
    static let dateLastPerformedExposureDetectionDidChangeNotification = Notification.Name("ExposureManager.dateLastPerformedExposureDetectionDidChangeNotification")
    static let detectedDiagnosisKeyFilesDidChangeNotification = Notification.Name("ExposureManager.detectedDiagnosisKeyFilesDidChangeNotification")
}

/// Activities that occurred while the app wasn't running.
struct ENActivityFlags: OptionSet {
    let rawValue: UInt32

    /// App launched to perform periodic operations.
    static let periodicRun = ENActivityFlags(rawValue: 1 << 2)
}

/// Invoked after the app is launched to report activities that occurred while the app wasn't running.
typealias ENActivityHandler = (ENActivityFlags) -> Void

extension ENManager {

    /// On iOS 12.5 only, this will ensure the app receives 3.5 minutes of background processing
    /// every 4 hours. This function is needed on iOS 12.5 because the BackgroundTask framework, used
    /// for Exposure Notifications background processing in iOS 13.5+ does not exist in iOS 12.
    func setLaunchActivityHandler(activityHandler: @escaping ENActivityHandler) {
        let proxyActivityHandler: @convention(block) (UInt32) -> Void = {integerFlag in
            activityHandler(ENActivityFlags(rawValue: integerFlag))
        }

        setValue(proxyActivityHandler, forKey: "activityHandler")
    }
}

extension ExposureManager {
    class func registerBackgroundTask() {
        if #available(iOS 13.5, *) {
            // In iOS 13.5 and later, the Background Tasks framework is available,
            // so create and schedule a background task for downloading keys and
            // detecting exposures
            createBackgroundTaskIfNeeded()
            scheduleBackgroundTaskIfNeeded()
        } else if ExposureManager.isENManagerAvailable {
            // If `ENManager` exists, and the iOS version is earlier than 13.5,
            // the app is running on iOS 12.5, where the Background Tasks
            // framework is unavailable. Specify an EN activity handler here, which
            // allows the app to receive background time for downloading keys
            // and looking for exposures when background tasks aren't available.
            // Apps should should call this method before calling activate().
            ExposureManager.shared.manager.setLaunchActivityHandler { (activityFlags) in
                // ENManager gives apps that register an activity handler
                // in iOS 12.5 up to 3.5 minutes of background time at
                // least once per day. In iOS 13 and later, registering an
                // activity handler does nothing.
                if activityFlags.contains(.periodicRun) {
                    logger.info("Periodic activity callback called (iOS 12.5)")
                    _ = ExposureManager.shared.detectExposures()
                }
            }
        }
    }
}

@available(iOS 13.5, *)
extension ExposureManager {
    class func createBackgroundTaskIfNeeded() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: .main) { task in
            UserManager.shared.updateEngagementStatistic()

            // Notify the user if Bluetooth is off
            ExposureManager.shared.showBluetoothOffUserNotificationIfNeeded()

            // Perform the exposure detection
            let progress = ExposureManager.shared.detectExposures { success in
                task.setTaskCompleted(success: success)
            }

            // Handle running out of time
            task.expirationHandler = {
                progress.cancel()
            }

            // Schedule the next background task
            ExposureManager.scheduleBackgroundTaskIfNeeded()
        }
    }

    class func scheduleBackgroundTaskIfNeeded() {
        guard ENManager.authorizationStatus == .authorized else { return }
        let taskRequest = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        taskRequest.requiresNetworkConnectivity = true
        do {
            try BGTaskScheduler.shared.submit(taskRequest)
        } catch {
            logger.error("Unable to schedule background task: \(error)")
        }
    }
}

extension ExposureManager {
    enum UploadError: Error {
        case verifyFailed
        case keysNotFound
        case userDenied
        case unknown
    }
}
