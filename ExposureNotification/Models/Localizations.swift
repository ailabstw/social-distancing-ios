//
//  Localizations.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/5/24.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import Foundation

enum Localizations { }

extension Localizations {
    enum Alert {
        enum Button {
            static let allow = NSLocalizedString("Alert.Button.Allow",
                                                 comment: "The button title on alert to allow app to grant permission")
            static let cancel = NSLocalizedString("Alert.Button.Cancel",
                                                  comment: "The button title on alert to cancel action")
            static let notAllow = NSLocalizedString("Alert.Button.NotAllow",
                                                    comment: "The button title on alert to not allow app to grant permission")
            static let later = NSLocalizedString("Alert.Button.Later",
                                                 comment: "The button title on alert for doing something later")
            static let no = NSLocalizedString("Alert.Button.No",
                                              comment: "The button title on alert for No")
            static let ok = NSLocalizedString("Alert.Button.OK",
                                              comment: "The button title on alert for OK")
            static let submit = NSLocalizedString("Alert.Button.Submit",
                                                  comment: "The button title on alert to submit data")
            static let yes = NSLocalizedString("Alert.Button.Yes",
                                               comment: "The button title on alert for Yes")
        }

        enum Message {
            static let uploadFailed = NSLocalizedString("Alert.Message.UploadFailed",
                                                        comment: "The message on alert to indicate the upload is failed")
            static let uploadSucceed = NSLocalizedString("Alert.Message.UploadSucceed",
                                                         comment: "The message on alert to indicate the upload is succeed")
        }
    }
}

extension Localizations {
    enum EnableBluetoothAlert {
        static let title = NSLocalizedString("EnableBluetoothAlert.Title",
                                             comment: "The title on enabling bluetooth alert")
        static let message = NSLocalizedString("EnableBluetoothAlert.Message",
                                               comment: "The message body on enabling bluetooth alert")

        enum Button {
            static let enable = NSLocalizedString("EnableBluetoothAlert.Button.Enable",
                                                  comment: "The button title on enabling bluetooth alert to enable bluetooth")
        }
    }

    enum NotificationNotEnabledAlert {
        static let title = NSLocalizedString("NotificationNotEnabledAlert.Title",
                                             comment: "The title on notification not enabled alert")
        static let message = NSLocalizedString("NotificationNotEnabledAlert.Message",
                                               comment: "The body message on notification not enabled alert")
    }
}

extension Localizations {
    enum BluetoothNotEnabledNotification {
        static let title = NSLocalizedString("BluetoothNotEnabledNotification.Title",
                                             comment: "The title on bluetooth not enabled notification")
        static let message = NSLocalizedString("BluetoothNotEnabledNotification.Message",
                                               comment: "The body message on bluetooth not enabled notification")
    }

    enum DetectionResultNotification {
        static let title = NSLocalizedString("DetectionResultNotification.Title",
                                             comment: "The title on detection result notification")
        enum Message {
            static let clear = NSLocalizedString("DetectionResultNotification.Message.Clear",
                                                 comment: "The body message on detection result notification for not risky")
            static let risky = NSLocalizedString("DetectionResultNotification.Message.Risky",
                                                 comment: "The body message on detection result notification for risky")
        }
    }
}

extension Localizations {
    enum ShortcutItem {
        enum QRCodeScanningAction {
            static let title = NSLocalizedString("ShortcutItem.QRCodeScanningAction.Title",
                                                 value: "Scan 1922 QR Code",
                                                 comment: "The title on home screen shortcut for scanning 1922 SMS QR code")
        }
    }
}
