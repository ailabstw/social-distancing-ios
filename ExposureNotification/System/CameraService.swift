//
//  CameraService.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/25.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CameraService {
    static let shared = CameraService()
    
    enum AuthorizationStatus {
        case authorized
        case unauthorized
        case unsupported
    }
    
    func requestAuthorizationIfNeeded(completion: @escaping (AuthorizationStatus) -> ()) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            completion(.unsupported)
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(.authorized)
        
        case .denied, .restricted:
            completion(.unauthorized)
        
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (success) in
                DispatchQueue.main.async {
                    completion(success ? .authorized : .unauthorized)
                }
            }
        @unknown default:
            completion(.unauthorized)
        }
    }
}
