//
//  Notification+App.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/16/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary

extension Notification.Name {
//    static let DataCounterDidReport = Notification.Name("DataCounterDidReport")
}

extension NotificationKey {
    static let downloaded = NotificationKey("DownloadedKey")

    static let uploaded = NotificationKey("UploadedKey")
}
