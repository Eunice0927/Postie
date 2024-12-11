//
//  SettingView.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 6/29/24.
//

import SwiftUI

struct SettingView: View {
    @ObservedObject var authManager = AuthManager.shared
    
    @AppStorage("isThemeGroupButton") private var isThemeGroupButton: Int = 0
    @Binding var isSideMenuOpen: Bool
    @Binding var currentGroupPage: Int
    @Binding var isTabGroupButton: Bool
    @Binding var currentColorPage: Int
    @Binding var profileImage: String
    @Binding var profileImageTemp: String
    
    private func settingItemView(imageName: String, title: String) -> some View {
        HStack {
            Image(systemName: imageName)
                .font(imageName == "megaphone" ? .callout : .body)
            
            Text(title)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(postieColors.dividerColor)
        }
        .padding(.bottom)
    }
    
    var body: some View {
        let user = authManager.currentUser
        
        HStack {
            Spacer()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Setting")
                        .font(.custom("SourceSerifPro-Black", size: 32))
                        .foregroundStyle(postieColors.tintColor)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            self.isSideMenuOpen.toggle()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                    }
                }
                .padding(.top, 5)
                
                Text("프로필 설정")
                    .font(.subheadline)
                    .foregroundStyle(postieColors.tintColor)
                
                DividerView()
                    .padding(.bottom)
                
                NavigationLink(destination: ProfileView(profileImage: $profileImage, profileImageTemp: $profileImageTemp)) {
                    HStack {
                        ZStack {
                            Circle()
                                .frame(width: 80,height: 80)
                                .foregroundStyle(postieColors.profileColor)
                            
                            Image(profileImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .offset(y: -4)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(String(user?.nickname ?? ""))
                            
                            Text(user?.email ?? "")
                        }
                        .foregroundStyle(postieColors.tabBarTintColor)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(postieColors.dividerColor)
                    }
                    .padding(.bottom)
                }
                
                Text("테마 설정")
                    .font(.subheadline)
                    .foregroundStyle(postieColors.tintColor)
                
                DividerView()
                    .padding(.bottom)
                
                NavigationLink(destination: ThemeView(currentColorPage: $currentColorPage, isTabGroupButton: $isTabGroupButton, currentGroupPage: $currentGroupPage)) {
                    settingItemView(imageName: "paintpalette", title: "테마 설정")
                }
                
                Text("앱 설정")
                    .font(.subheadline)
                    .foregroundStyle(postieColors.tintColor)
                
                DividerView()
                    .padding(.bottom)
                
                NavigationLink(destination: AlertView()) {
                    settingItemView(imageName: "bell", title: "알림 설정")
                }
                
                NavigationLink(destination: NoticeView()) {
                    settingItemView(imageName: "megaphone", title: "공지사항")
                }
                
                NavigationLink(destination: QuestionView()) {
                    settingItemView(imageName: "questionmark.circle", title: "문의하기")
                }
                
                NavigationLink(destination: InformationView()) {
                    settingItemView(imageName: "info.circle", title: "앱 정보")
                }
                
                Spacer()
                
                Text("COPYRIGHT 2024 Team Postie RIGHTS RESERVED")
                    .font(.caption2)
                    .foregroundStyle(postieColors.dividerColor)
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width - 100 , alignment: .leading)
            .foregroundStyle(postieColors.tabBarTintColor)
            .background(postieColors.backGroundColor)
        }
        .tint(postieColors.tabBarTintColor)
        .onAppear {
            currentColorPage = isThemeGroupButton
            currentGroupPage = isTabGroupButton ? 0 : 1
        }
    }
}
