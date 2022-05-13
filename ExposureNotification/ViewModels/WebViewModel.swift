//
//  WebViewModel.swift
//  COVID19 Quarantine
//
//  Created by Shiva Huang on 2020/4/22.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import CoreKit
import Foundation

extension WebViewModel {
    static let personalDataProtectionNote = WebViewModel(title: Localizations.PersonalDataProtectionNote.title, urlString: "https://ailabs.tw/taiwan-social-distancing-apppersonal-data-protection-note/")
    static let faq = SafariViewModel(title: Localizations.FAQ.title, urlString: "https://www.cdc.gov.tw/Category/Page/R8bAd_yiVi22CIr73qM2yw")
    static let applyVaccinationCertificate = SafariViewModel(title: Localizations.VaccinationCertificateCard.apply, urlString: "https://dvc.mohw.gov.tw/vapa/apply/Index.init.ctr?openExternalBrowser=1")
    static let bookingVaccination = SafariViewModel(title: Localizations.VaccinationCertificateCard.appointment, urlString: "https://www.cdc.gov.tw/Category/List/u4l1b_gHhf9WDjhEtRmRRw")
    static let vaccinationCertificateFAQ = SafariViewModel(title: Localizations.FAQ.title, urlString: "https://dvc.mohw.gov.tw/vapa/template/vapa/common/pdf/QA.pdf")
}

class PrivacyWebViewModel: WebViewModel {
    @Observed(queue: .main)
    private(set) var reviewed: Bool = false
    
    private override init(title: String, urlString: String) {
        super.init(title: title, urlString: urlString)
    }
    
    override func webViewDidReachBottom() {
        reviewed = true
    }
    
    func acceptPrivacy() {
        NotificationCenter.default.post(name: .acceptedPrivacy, object: self)
    }
}

extension Notification.Name {
    static let acceptedPrivacy = Notification.Name("acceptedPrivacy")
}

extension Localizations {
    enum PersonalDataProtectionNote {
        static let title = NSLocalizedString("PersonalDataProtectionNote.Title",
                                             value: "Privacy Policy and Terms of Use",
                                             comment: "The title of personal data protection note view")
    }
    
    enum FAQ {
        static let title = NSLocalizedString("FAQ.Title",
                                             value: "FAQ",
                                             comment: "The title of FAQ view")
    }
}
