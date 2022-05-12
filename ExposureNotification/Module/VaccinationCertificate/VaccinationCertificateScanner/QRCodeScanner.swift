//
//  QRCodeScanner.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/15.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import AVFoundation
import Foundation

class QRCodeScanner: NSObject {
    enum SessionConfigurationResult {
        case notConfigured
        case success
        case configurationFailed
    }
    
    private(set) var sessionConfigurationResult: SessionConfigurationResult = .notConfigured
    private let sessionQueue = DispatchQueue(label: "vaccination_certificate_session_queue")
    
    let session = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput?
    var metadataOutput: AVCaptureMetadataOutput?
    var delegate: QRCodeScannerDelegate?
    
    override init() {
        super.init()
        configure()
    }
    
    private func configure() {
        guard sessionConfigurationResult == .notConfigured else {
            return
        }

        sessionQueue.async {
            self.configureSession()
        }
    }
    
    private func configureSession() {        
        guard sessionConfigurationResult == .notConfigured else {
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
    
    func start(completion: (() -> Void)? = nil) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            switch self.sessionConfigurationResult {
            case .success:
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
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.sessionConfigurationResult == .success {
                self.session.stopRunning()
            }

            DispatchQueue.main.async {
                completion?()
            }
        }
    }
}

protocol QRCodeScannerDelegate {
    func didCaptureQRCode(_ code: String)
    func didCaptureOthers()
}

extension QRCodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first(where: { $0.type == .qr }) else {
            delegate?.didCaptureOthers()
            return
        }
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }

        logger.info("QR Code: \(stringValue)")
        delegate?.didCaptureQRCode(stringValue)
    }
}
