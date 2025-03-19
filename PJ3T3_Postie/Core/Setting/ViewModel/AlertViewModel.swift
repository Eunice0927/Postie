//
//  AlertViewModel.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 7/4/24.
//

import Foundation
import UserNotifications

class AlertViewModel: ObservableObject {
    @Published var isThemeGroupButton: Int
    @Published var allAlert: Bool
    @Published var slowAlert: Bool
    
    
    init() {
        self.isThemeGroupButton = UserDefaultsManager.get(forKey: .IsThemeGroupButton) ?? 0
        self.allAlert = UserDefaultsManager.get(forKey: .allAlert) ?? false
        self.slowAlert = UserDefaultsManager.get(forKey: .slowAlert) ?? false
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
