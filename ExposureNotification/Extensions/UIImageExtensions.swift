//
//  UIImageExtensions.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/3/23.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    convenience init?(qrCode: String, of size: CGSize) {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            assertionFailure(); return nil
        }
        
        filter.setDefaults()
        let data: Data? = qrCode.data(using: .isoLatin1)
        filter.setValue(data, forKey: "inputMessage")
        
        guard var ciImage = filter.value(forKey: "outputImage") as? CIImage else {
            assertionFailure(); return nil
        }
        
        let scaleX = size.width/ciImage.extent.width
        let scaleY = size.height/ciImage.extent.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        ciImage = ciImage.transformed(by: transform)
        
        self.init(ciImage: ciImage)
    }
}
