//
//  QRCodeScannerViewModel.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/5/26.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import AVFoundation
import CoreKit
import Foundation

class QRCodeScannerViewModel: NSObject {
    // MARK: Session Management

    enum AuthorizationStatus {
        case notDetermined
        case unauthorized
        case authorized
    }

    enum SessionConfigurationResult {
        case notConfigured
        case success
        case configurationFailed
    }

    enum ScannerResult: Equatable {
        case none
        case sms(SMS)
        case invalid
    }

    @Observed(queue: .main)
    private(set) var title: String = Localizations.QRCodeScannerViewModel.title

    @Observed(queue: .main)
    private(set) var scanResult: ScannerResult = .none

    @Observed(queue: .main)
    private(set) var sessionConfigurationResult: SessionConfigurationResult = .notConfigured

    @Observed(queue: .main)
    private(set) var authorizationStatus: AuthorizationStatus = .notDetermined

    let session = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput?
    var metadataOutput: AVCaptureMetadataOutput?

    private let sessionQueue = DispatchQueue(label: "session queue")

    private var observers: [NSObjectProtocol] = []

    override init() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            authorizationStatus = .authorized

        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. Suspend the session queue to delay session
             setup until the access request has completed.

             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            authorizationStatus = .notDetermined


        default:
            // The user has previously denied or not been allowed to access media capture devices.
            authorizationStatus = .unauthorized
        }
    }

    func configure() {
        guard sessionConfigurationResult == .notConfigured else {
            return
        }

        if authorizationStatus == .notDetermined {
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                self.authorizationStatus = granted ? .authorized : .unauthorized
                self.sessionQueue.resume()
            })
        }

        sessionQueue.async {
            self.configureSession()
        }
    }

    // Call this on the session queue.
    /// - Tag: ConfigureSession
    private func configureSession() {
        guard authorizationStatus == .authorized, sessionConfigurationResult == .notConfigured else {
            return
        }

        session.beginConfiguration()

        /*
         Do not create an AVCaptureMovieFileOutput when setting up the session because
         Live Photo is not supported when AVCaptureMovieFileOutput is added to the session.
         */
        session.sessionPreset = .photo

        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?

            // Choose the back dual camera, if available, otherwise default to a wide angle camera.

            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                // If a rear dual camera is not available, default to the rear wide angle camera.
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                // If the rear wide angle camera isn't available, default to the front wide angle camera.
                defaultVideoDevice = frontCameraDevice
            }
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                sessionConfigurationResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                logger.error("Couldn't add video device input to the session.")
                sessionConfigurationResult = .configurationFailed
                session.commitConfiguration()
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if (session.canAddOutput(metadataOutput)) {
                session.addOutput(metadataOutput)
                self.metadataOutput = metadataOutput

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            } else {
                logger.error("Couldn't add metadata output to the session.")
                sessionConfigurationResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            logger.error("Couldn't configure session: \(error)")
            sessionConfigurationResult = .configurationFailed
            session.commitConfiguration()
            return
        }

        sessionConfigurationResult = .success
        session.commitConfiguration()
    }

    private func addObservers() {
        if let videoDeviceInput = videoDeviceInput {
            NotificationCenter.default.addObserver(forName: .AVCaptureDeviceSubjectAreaDidChange,
                                                   object: videoDeviceInput.device,
                                                   queue: nil) { [weak self] _ in
                let devicePoint = CGPoint(x: 0.5, y: 0.5)
                self?.focus(with: .continuousAutoFocus,
                            exposureMode: .continuousAutoExposure,
                            at: devicePoint,
                            monitorSubjectAreaChange: false)
            }
        }
    }

    private func removeObservers() {
        observers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }

    func start(completion: (() -> Void)? = nil) {
        sessionQueue.async {
            switch self.sessionConfigurationResult {
            case .success:
                self.addObservers()
                self.session.startRunning()

            default:
                break
            }

            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    func stop(completion: (() -> Void)? = nil) {
        sessionQueue.async {
            if self.sessionConfigurationResult == .success {
                self.session.stopRunning()
                self.removeObservers()
            }

            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    func focus(with focusMode: AVCaptureDevice.FocusMode,
               exposureMode: AVCaptureDevice.ExposureMode,
               at devicePoint: CGPoint,
               monitorSubjectAreaChange: Bool) {

        sessionQueue.async {
            guard let device = self.videoDeviceInput?.device else {
                return
            }

            do {
                try device.lockForConfiguration()

                /*
                 Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
                 Call set(Focus/Exposure)Mode() to apply the new point of interest.
                 */
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }

                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }

                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                logger.error("Could not lock device for configuration: \(error)")
            }
        }
    }
}

extension QRCodeScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        if let metadataObject = metadataObjects.first(where: {
            $0.type == .qr
        }) {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let stringValue = readableObject.stringValue,
                  let message = SMS(stringValue) else {
                scanResult = .invalid
                return
            }

            logger.info("QR Code: \(stringValue)")

            let sms = ScannerResult.sms(message)
            if scanResult != sms {
                scanResult = sms
            }
        } else {
            scanResult = .none
        }
    }
}

extension Localizations {
    enum QRCodeScannerViewModel {
        static let title = NSLocalizedString("QRCodeScannerViewModel.Title",
                                             comment: "The title of 1922 SMS Contact Tracing Scanner")
    }
}
