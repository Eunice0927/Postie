//
//  PJ3T3_PostieApp.swift
//  PJ3T3_Postie
//
//  Created by Eunsu JEONG on 1/15/24.
//

import OSLog
import SwiftUI

import FirebaseCore
import FirebaseMessaging
import NMapsMap

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound] // 필요한 알림 권한을 설정
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        // UNUserNotificationCenterDelegate를 구현한 메서드를 실행시킴
        application.registerForRemoteNotifications()
        
        // 파이어베이스 Meesaging 설정
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // 백그라운드에서 푸시 알림을 탭했을 때 실행
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logger.firebase.info("APNs Token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Defult Configuration", sessionRole: connectingSceneSession.role)
    }
}

@main
struct PJ3T3_PostieApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isThemeGroupButton") private var isThemeGroupButton: Int = 0
    
    @StateObject private var alertManager = AlertManager()
    @StateObject private var remoteConfig = RemoteConfigManager()
    
    private var clientID: String? {
        get { getValueOfPlistFile("MapApiKeys", "NAVER_GEOCODE_ID") }
    }
    
    init() {
        NMFAuthManager.shared().clientId = clientID
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(ThemeManager.themeColors[isThemeGroupButton].tabBarTintColor)
                .customOnChange(scenePhase) { newPhase in
                    if newPhase == .active {
                        UNUserNotificationCenter.current().setBadgeCount(0) { error in
                            guard let error else {
                              // Badge count was successfully updated
                              return
                            }
                            // Replace this with proper error handling
                            Logger.notification.info("Failed to reset badge count: \(error) info")
                          }
                    }
                }
                .environmentObject(alertManager)
                .environmentObject(remoteConfig)
        }
    }
}
