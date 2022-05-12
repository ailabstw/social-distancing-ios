//
//  IntroductionViewModel.swift
//  Tracer
//
//  Created by Shiva Huang on 2020/4/1.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import CoreKit
import Foundation

extension Notification.Name {
    static let appIntroductionCompleted = Notification.Name("appIntroductionCompleted")
}

class IntroductionViewModel {
    enum IntroductionType {
        case unsupported
        case firstTimeUse
        case about
    }

    static let unsupportedIntroductions: [Introduction] = {
        [
            Introduction(title: Localizations.Introduction.UnsupportedOSVersion.title,
                         content: Localizations.Introduction.UnsupportedOSVersion.message,
                         figureName: "graphUpdate",
                         action: (title: Localizations.Introduction.UnsupportedOSVersion.button,
                                  block: { AppCoordinator.shared.openSettingsApp() }))
        ]
    }()

    static let firstTimeUseIntroductions: [Introduction] = {
        [
            Introduction(title: Localizations.Introduction.ProtectingFamily.title,
                         content: Localizations.Introduction.ProtectingFamily.message,
                         figureName: "graphFamily",
                         action: nil),
            Introduction(title: Localizations.Introduction.PrivacyProtection.title,
                         content: Localizations.Introduction.PrivacyProtection.message,
                         figureName: "graphTech",
                         action: nil),
            Introduction(title: Localizations.Introduction.StopSpreading.title,
                         content: Localizations.Introduction.StopSpreading.message,
                         figureName: "graphPrivacy",
                         action: nil),
            Introduction(title: Localizations.Introduction.VaccinationCertificate.title,
                         content: Localizations.Introduction.VaccinationCertificate.message,
                         figureName: "graphHCert",
                         action: (title: Localizations.IntroductionView.Button.startUsing,
                                  block: { UserPreferenceManager.shared.isIntroductionWatched = true }))
        ]
    }()
    
    static let aboutIntroductions: [Introduction] = {
        [
            Introduction(title: Localizations.Introduction.ProtectingFamily.title,
                         content: Localizations.Introduction.ProtectingFamily.message,
                         figureName: "graphFamily",
                         action: nil),
            Introduction(title: Localizations.Introduction.PrivacyProtection.title,
                         content: Localizations.Introduction.PrivacyProtection.message,
                         figureName: "graphTech",
                         action: nil),
            Introduction(title: Localizations.Introduction.StopSpreading.title,
                         content: Localizations.Introduction.StopSpreading.message,
                         figureName: "graphPrivacy",
                         action: nil),
            Introduction(title: Localizations.Introduction.VaccinationCertificate.title,
                         content: Localizations.Introduction.VaccinationCertificate.message,
                         figureName: "graphHCert",
                         action: nil)
        ]
    }()

    @Observed(queue: .main)
    private(set) var title: String = ""
    
    private(set) lazy var introductions: [Introduction] = IntroductionViewModel.aboutIntroductions
    
    init(type: IntroductionType) {
        switch type {
        case .unsupported:
            introductions = IntroductionViewModel.unsupportedIntroductions
        case .firstTimeUse:
            introductions = IntroductionViewModel.firstTimeUseIntroductions
        case .about:
            title = Localizations.IntroductionView.title
            introductions = IntroductionViewModel.aboutIntroductions
        }
    }
    
    func introduction(before intro: Introduction) -> Introduction? {
        guard let currentIndex = introductions.firstIndex(of: intro),
            introductions.index(before: currentIndex) >= introductions.startIndex else {
                return nil
        }
        
        return introductions[introductions.index(before: currentIndex)]
    }
    
    func introduction(after intro: Introduction) -> Introduction? {
        guard let currentIndex = introductions.firstIndex(of: intro),
            introductions.index(after: currentIndex) < introductions.endIndex else {
                return nil
        }
        
        return introductions[introductions.index(after: currentIndex)]
    }
}

extension Localizations {
    enum IntroductionView {
        static let title = NSLocalizedString("IntroductionView.Title",
                                             value: "App Introduction",
                                             comment: "The title of introduction view for app introduction")

        enum Button {
            static let startUsing = NSLocalizedString("Introduction.Button.StartUsing",
                                                      value: "Get Started",
                                                      comment: "The button title of introduction about start using")
        }
    }

    enum Introduction {
        enum UnsupportedOSVersion {
            static let title = NSLocalizedString("Introduction.UnsupportedOSVersion.Title",
                                                 value: "Please Upgrade Your Operating System",
                                                 comment: "The title of introduction about unsupported iOS version")
            static let message = NSLocalizedString("Introduction.UnsupportedOSVersion.Message",
                                                   value: "Taiwan Social Distancing App supports iOS 13.7 or later.",
                                                   comment: "The content message of introduction about unsupported iOS version")
            static let button = NSLocalizedString("Introduction.UnsupportedOSVersion.Button",
                                                  value: "Upgrade Your Operating System",
                                                  comment: "The button title of introduction about unsupported iOS version")
        }

        enum ProtectingFamily {
            static let title = NSLocalizedString("Introduction.ProtectingFamily.Title",
                                                 value: "Stay Safe, Keep Your Family Safe",
                                                 comment: "The title of introduction about protecting family")
            static let message = NSLocalizedString("Introduction.ProtectingFamily.Message",
                                                   value: "The Taiwan Social Distancing App was developed by the Taiwan AI Labs in cooperation with the Executive Yuan and the Taiwan Centers for Disease Control in order to reduce the likelihood of disease transmission and keep people safe.",
                                                   comment: "The content message of introduction about protecting family")
        }

        enum PrivacyProtection {
            static let title = NSLocalizedString("Introduction.PrivacyProtection.Title",
                                                 value: "Privacy and Data Protection",
                                                 comment: "The title of introduction about privacy and personal data protection")
            static let message = NSLocalizedString("Introduction.PrivacyProtection.Message",
                                                   value: "Taiwan Social Distancing App use is anonymous - users do not need to register and no user data will be collected. The only form of data transmission involved is the observation of Bluetooth signals between handheld devices to calculate the distance between each user. \n\nUser privacy will be ensured via decentralized storage of anonymous IDs for individual devices; contact data will be compiled by each respective device.",
                                                   comment: "The content message of introduction about privacy and personal data protection")
        }

        enum StopSpreading {
            static let title = NSLocalizedString("Introduction.StopSpreading.Title",
                                                 value: "Reduce the Spread of Pandemic",
                                                 comment: "The title of introduction about stop spreading")
            static let message = NSLocalizedString("Introduction.StopSpreading.Message",
                                                   value: "Users who have tested positive can choose to anonymously publish their device's anonymous IDs. When users with a positive test publish their results, people who have been in proximity to this device and maintained contact for a certain period of time will receive a notification. This process guarantees the anonymity and personal privacy of those who share their positive test results while contributing to keeping our communities informed and diligent in taking preventative and cautionary measures.",
                                                   comment: "The content message of introduction about stop spreading")
        }
        
        enum VaccinationCertificate {
            static let title = NSLocalizedString("Introduction.VaccinationCertificate.Title",
                                                 value: "Vaccination Certificate",
                                                 comment: "The title of introduction about vaccination certificate")
            static let message = NSLocalizedString("Introduction.VaccinationCertificate.Message",
                                                   value: "The App provides an easy way to securely store and present COVID-19 Vaccination Certificate for you and your loved ones. You also can use the QR code of the vaccination certificates for other people or organizations to verify your vaccination status. No internet connection is required and Your data is only stored locally on your mobile device.",
                                                   comment: "The content message of introduction about vaccination certificate")
        }
    }
}
