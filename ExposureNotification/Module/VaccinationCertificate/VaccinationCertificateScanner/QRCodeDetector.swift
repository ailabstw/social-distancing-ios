//
//  QRCodeDetector.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/15.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import UIKit

class QRCodeDetector {
    private let detector: CIDetector? = {
        let context = CIContext(options: nil)
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        return CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
    }()
    
    func performQRCodeDetection(image: UIImage) -> String? {
        var ciImage = image.ciImage
        if image.ciImage == nil {
            ciImage = convertUIImageToCIImage(uiImage: image)
        }

        guard let detector = detector else {
            return nil
        }

        var decode: String?
        let features = detector.features(in: ciImage!)
        guard let qrCodeFeatures = features as? [CIQRCodeFeature] else { return nil }
        qrCodeFeatures.forEach { decode = $0.messageString }

        return decode
    }

    private func convertUIImageToCIImage(uiImage: UIImage) -> CIImage {
        var ciImage = uiImage.ciImage
        if ciImage == nil {
            let cgImage = uiImage.cgImage
            ciImage = CIImage(cgImage: cgImage!)
        }
        return ciImage!
    }
}
