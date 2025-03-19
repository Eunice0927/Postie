//
//  ContentView.swift
//  PJ3T3_Postie
//
//  Created by Eunsu JEONG on 1/15/24.
//

import SwiftUI
import OSLog
import CoreLocation

//struct TestView: View {
//    var body: some View {
//        NaverMap(coord: coord)
//    }
//}

struct ContentView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @ObservedObject var authViewModel = AuthManager.shared
    @StateObject private var viewModel = AppViewModel()
    @AppStorage("isThemeGroupButton") private var isThemeGroupButton: Int = 0
    @StateObject private var tabSelection = TabSelection()
    
    init() {
        let tbAppearance: UITabBarAppearance = UITabBarAppearance()
        tbAppearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().scrollEdgeAppearance = tbAppearance
        UITabBar.appearance().standardAppearance = tbAppearance
        Utils.logEvent(event: .appStart, params: [:])
    }

    var body: some View {
        Group {
            // 로딩 끝나면 화면 재생
            if viewModel.isLoading {
                //ViewModel의 userSession이 Published로 구현되어 있기 때문에 해당 뷰에 업데이트가 발생하면 ContentView에 새로운 userSession값을 가지고 뷰를 재구성하도록 신호를 보낸다.
                // ContentView는 viewModel에 업데이트가 없는지 listen하는 상태
                if authViewModel.userSession != nil { // userSession이 있으면 SettingView를 보여줌
                    if authViewModel.currentUser != nil {
                        TabView(selection: $tabSelection.selectedTab) {
                            HomeView(tabSelection: tabSelection)
                                .tabItem {
                                    Image(systemName: "tray")
                                    
                                    Text("보관함")
                                }
                                .tag(0)
                            
                            MapView()
                                .tabItem {
                                    Image(systemName: "map")
                                    
                                    Text("지도")
                                }
                                .onTapGesture {
                                    CLLocationManager().requestWhenInUseAuthorization()
                                                }
                                .tag(1)
                            
                            ShopView()
                                .tabItem {
                                    Image(systemName: "cart")
                                    
                                    Text("편지지")
                                }
                                .tag(2)
                            
                            //테스트용 뷰입니다. 배포시 주석처리
//                            FirebaseTestView()
//                                .tabItem {
//                                    Image(systemName: "person")
//                                    Text("Setting")
//                                }
//                                .tag(3)
                        }
                        .accentColor(postieColors.tabBarTintColor)
                    } else {
                        if authViewModel.hasAccount {
                            LoadingView(text: "포스티 시작하는 중")
                                .background(ClearBackground())
                        } else {
                            NicknameView()
                        }
                    }
                } else {
                    LoginView()
                }
            } else {
                SplashScreenView()
            }
        }
        .alert(alertManager.title, isPresented: $alertManager.isOneButtonAlertPresented) {
            if let button = alertManager.singleButton, let action = button.action, let title = button.title {
                Button(title, role: button.role) {
                    action()
                }
            }
        } message: {
            Text(alertManager.message)
        }
        .alert(alertManager.title, isPresented: $alertManager.isTwoButtonAlertPresented) {
            if let leftButton = alertManager.leftButton, let title = leftButton.title {
                Button(title, role: leftButton.role) {
                    if let action = leftButton.action {
                        action()
                    }
                }
            }
            
            if let rightButton = alertManager.rightButton, let title = rightButton.title {
                Button(title, role: rightButton.role) {
                    if let action = rightButton.action {
                        action()
                    }
                }
            }
        } message: {
            Text(alertManager.message)
        }
        .onAppear {
            Task {
                guard await AppStoreUpdateChecker.isNewVersionAvailable() else {
                    Logger.version.info("신규 버전 없음")
                    return
                }
                
                Logger.version.info("신규 버전 있음, alert 띄우자")
                let isForceUpdate = remoteConfigManager.getBool(from: .is_force_update)
                print("remoteConfigManager - force update: \(isForceUpdate)")
                alertManager.showUpdateAlert(isForceUpdate: isForceUpdate)
            }
        }
        .customOnChange(scenePhase) { appStatus in
            let isForceUpdate = remoteConfigManager.getBool(from: .is_force_update)
            guard appStatus == .active, isForceUpdate  else { return }
            alertManager.showUpdateAlert(isForceUpdate: isForceUpdate)
        }
    }
//    func requestLocationPermission() {
//        locationManager.requestWhenInUseAuthorization()
//    }
}

#Preview {
    ContentView()
}
