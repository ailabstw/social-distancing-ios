//
//  VaccinationCertificateModel.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/3/24.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation

struct VaccinationCertificateModel {
    let name: String
    let standardizedName: String
    let uniqueIdentifier: String
    let doseNumber: Int
    let totalDoses: Int
    let medicinalProduct: String
    let manufacturer: String
    let country: String
    let issuer: String
    let vaccineType: String
    let targetedDisease: String
    let doseDate: Date
    let birthDate: Date
}

struct VaccinationCertificateCardModel {
    let qrCode: String
    let displayname: String
    let standardizedName: String
    let birthDate: String
    let doseDate: String
}

struct VaccinationCertificateListModel {
    let qrCode: String
    let displayname: String
    let doseDate: String
}

struct VaccinationCertificateDetailModel {
    let name: String
    let standardizedName: String
    let uniqueIdentifier: String
    let doses: String
    let medicinalProduct: String
    let manufacturer: String
    let country: String
    let issuer: String
    let vaccineType: String
    let targetedDisease: String
    let doseDate: String
    let birthDate: String
}
