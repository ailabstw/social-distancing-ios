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
                                                 value: "Allow",
                                                 comment: "The button title on alert to allow app to grant permission")
            static let cancel = NSLocalizedString("Alert.Button.Cancel",
                                                  value: "Cancel",
                                                  comment: "The button title on alert to cancel action")
            static let notAllow = NSLocalizedString("Alert.Button.NotAllow",
                                                    value: "Don't Allow",
                                                    comment: "The button title on alert to not allow app to grant permission")
            static let later = NSLocalizedString("Alert.Button.Later",
                                                 value: "Later",
                                                 comment: "The button title on alert for doing something later")
            static let no = NSLocalizedString("Alert.Button.No",
                                              value: "No",
                                              comment: "The button title on alert for No")
            static let ok = NSLocalizedString("Alert.Button.OK",
                                              value: "OK",
                                              comment: "The button title on alert for OK")
            static let submit = NSLocalizedString("Alert.Button.Submit",
                                                  value: "Submit",
                                                  comment: "The button title on alert to submit data")
            static let yes = NSLocalizedString("Alert.Button.Yes",
                                               value: "Yes",
                                               comment: "The button title on alert for Yes")
        }

        enum Message {
            static let uploadFailed = NSLocalizedString("Alert.Message.UploadFailed",
                                                        value: "Upload Failed",
                                                        comment: "The message on alert to indicate the upload is failed")
            static let uploadSucceed = NSLocalizedString("Alert.Message.UploadSucceed",
                                                         value: "Upload Successful",
                                                         comment: "The message on alert to indicate the upload is succeed")
            static let verifyAPIFailed = NSLocalizedString("Alert.Message.verifyFailed",
                                                           value: "Invalid verification code",
                                                           comment: "The message on alert to indicate the upload is failed")
            static let missingKeyData = NSLocalizedString("Alert.Message.missingKeyData",
                                                          value: "No data between start and end dates",
                                                          comment: "The message on alert to indicate the no data between start and end date")
        }
    }
}

extension Localizations {
    enum EnableBluetoothAlert {
        static let title = NSLocalizedString("EnableBluetoothAlert.Title",
                                             value: "Activate your Bluetooth",
                                             comment: "The title on enabling bluetooth alert")
        static let message = NSLocalizedString("EnableBluetoothAlert.Message",
                                               value: "Your device and the devices around you will exchange anonymous IDs via Bluetooth.",
                                               comment: "The message body on enabling bluetooth alert")

        enum Button {
            static let enable = NSLocalizedString("EnableBluetoothAlert.Button.Enable",
                                                  value: "OK",
                                                  comment: "The button title on enabling bluetooth alert to enable bluetooth")
        }
    }

    enum NotificationNotEnabledAlert {
        static let title = NSLocalizedString("NotificationNotEnabledAlert.Title",
                                             value: "Exposure Notification is not enabled",
                                             comment: "The title on notification not enabled alert")
        static let message = NSLocalizedString("NotificationNotEnabledAlert.Message",
                                               value: "Enable Exposure Notification for possible contact with COVID-Positive persons.",
                                               comment: "The body message on notification not enabled alert")
    }
}

extension Localizations {
    enum BluetoothNotEnabledNotification {
        static let title = NSLocalizedString("BluetoothNotEnabledNotification.Title",
                                             value: "Exposure Notification Disabled",
                                             comment: "The title on bluetooth not enabled notification")
        static let message = NSLocalizedString("BluetoothNotEnabledNotification.Message",
                                               value: "Exposure Notification disabled due to Bluetooth is deactivated",
                                               comment: "The body message on bluetooth not enabled notification")
    }

    enum DetectionResultNotification {
        static let title = NSLocalizedString("DetectionResultNotification.Title",
                                             value: "Contact Tracing Results",
                                             comment: "The title on detection result notification")
        enum Message {
            static let clear = NSLocalizedString("DetectionResultNotification.Message.Clear",
                                                 value: "No exposure detected",
                                                 comment: "The body message on detection result notification for not risky")
            static let risky = NSLocalizedString("DetectionResultNotification.Message.Risky",
                                                 value: "You may be at risk for exposure to COVID-19, open the app for more details",
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
