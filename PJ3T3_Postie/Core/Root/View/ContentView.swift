//
//  ContentView.swift
//  PJ3T3_Postie
//
//  Created by Eunsu JEONG on 1/15/24.
//

import SwiftUI

struct ContentView: View {
    //ViewModels
    @ObservedObject var authViewModel = AuthManager.shared
    @StateObject private var viewModel = AppViewModel()
    @AppStorage("isThemeGroupButton") private var isThemeGroupButton: Int = 0
    @StateObject private var tabSelection = TabSelection()
    
    init() {
        let tbAppearance: UITabBarAppearance = UITabBarAppearance()
        tbAppearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().scrollEdgeAppearance = tbAppearance
        UITabBar.appearance().standardAppearance = tbAppearance
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
                                    Image(systemName: "house")
                                    
                                    Text("홈")
                                }
                                .tag(0)
                            
                            ShopView()
                                .tabItem {
                                    Image(systemName: "cart")
                                    
                                    Text("편지지")
                                }
                                .tag(1)
                            
                            MapView()
                                .tabItem {
                                    Image(systemName: "map")
                                    
                                    Text("지도")
                                }
                                .tag(2)
                            
//                            테스트용 뷰입니다. 배포시 주석처리
//                            SettingView()
//                                .tabItem {
//                                    Image(systemName: "person")
//                                    Text("Setting")
//                                }
//                                .tag(3)
                        }
                        .accentColor(ThemeManager.themeColors[isThemeGroupButton].tabBarTintColor)
                    } else {
                        if authViewModel.hasAccount {
                            LoadingView(text: "포스티 시작하는 중")
                        } else {
                            if authViewModel.hasAccount {
                                ProgressView()
                            } else {
                                NicknameView()
                            }
                        }
                    }
                } else {
                    LoginView()
                }
            } else {
                SplashScreenView()
            }
        }
    }
}

#Preview {
    ContentView()
}
