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
                                             comment: "The title of introduction view for app introduction")

        enum Button {
            static let startUsing = NSLocalizedString("Introduction.Button.StartUsing",
                                                      comment: "The button title of introduction about start using")
        }
    }

    enum Introduction {
        enum UnsupportedOSVersion {
            static let title = NSLocalizedString("Introduction.UnsupportedOSVersion.Title",
                                                 comment: "The title of introduction about unsupported iOS version")
            static let message = NSLocalizedString("Introduction.UnsupportedOSVersion.Message",
                                                   comment: "The content message of introduction about unsupported iOS version")
            static let button = NSLocalizedString("Introduction.UnsupportedOSVersion.Button",
                                                  comment: "The button title of introduction about unsupported iOS version")
        }

        enum ProtectingFamily {
            static let title = NSLocalizedString("Introduction.ProtectingFamily.Title",
                                                 comment: "The title of introduction about protecting family")
            static let message = NSLocalizedString("Introduction.ProtectingFamily.Message",
                                                   comment: "The content message of introduction about protecting family")
        }

        enum PrivacyProtection {
            static let title = NSLocalizedString("Introduction.PrivacyProtection.Title",
                                                 comment: "The title of introduction about privacy and personal data protection")
            static let message = NSLocalizedString("Introduction.PrivacyProtection.Message",
                                                   comment: "The content message of introduction about privacy and personal data protection")
        }

        enum StopSpreading {
            static let title = NSLocalizedString("Introduction.StopSpreading.Title",
                                                 comment: "The title of introduction about stop spreading")
            static let message = NSLocalizedString("Introduction.StopSpreading.Message",
                                                   comment: "The content message of introduction about stop spreading")
        }
    }
}
