//
//  AlertViewModel.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 7/4/24.
//

import SwiftUI
import UserNotifications

class AlertViewModel: ObservableObject {
    @Published var isThemeGroupButton: Int
    @Published var allAlert: Bool
    @Published var slowAlert: Bool
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        self.isThemeGroupButton = userDefaults.integer(forKey: "isThemeGroupButton")
        self.allAlert = userDefaults.bool(forKey: "allAlert")
        self.slowAlert = userDefaults.bool(forKey: "slowAlert")
    }
    
    func moveToNotificationSetting() {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    func checkNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }
    
    func changeToggleState() async {
        let permissionGranted = await self.checkNotificationPermission()
        DispatchQueue.main.async {
            self.allAlert = permissionGranted
            self.slowAlert = permissionGranted
        }
    }
}
