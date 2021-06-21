//
//  ENTemporaryExposureKeyExtensions.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/3/29.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import ExposureNotification
import Foundation

extension ENTemporaryExposureKey: Encodable {
    private enum CodingKeys: String, CodingKey {
        case key
        case rollingStartNumber
        case rollingPeriod
        case transmissionRisk
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.keyData.base64EncodedString(), forKey: .key)
        try container.encode(self.rollingStartNumber, forKey: .rollingStartNumber)
        try container.encode(self.rollingPeriod, forKey: .rollingPeriod)
        try container.encode(self.transmissionRiskLevel, forKey: .transmissionRisk)
    }
}
