//
//  AppDelegate+MessagingDelegate.swift
//  PJ3T3_Postie
//
//  Created by Eunsu JEONG on 1/4/25.
//

import OSLog
import UIKit
import UserNotifications

import FirebaseMessaging

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
    }
}

extension AppDelegate: MessagingDelegate {
    // 파이어베이스 MessagingDelegate 설정
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Logger.firebase.info("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}
