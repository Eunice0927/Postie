//
//  AlertView.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 2/14/24.
//

import SwiftUI
import UserNotifications

struct AlertView: View {
    @StateObject private var viewModel = AlertViewModel()
    
    func moveToNotificationSetting() {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    var body: some View {
        ZStack {
            postieColors.backGroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    Toggle(isOn: $viewModel.allAlert) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("전체 알림")
                                .foregroundStyle(postieColors.tabBarTintColor)
                            
                            Text("모든 편지 알림을 받을 수 있습니다.")
                                .font(.footnote)
                                .foregroundColor(postieColors.dividerColor)
                        }
                    }
                    .onTapGesture {
                        moveToNotificationSetting()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        Task {
                            await viewModel.changeToggleState()
                        }
                    }
                    .padding(.bottom)
                    
                    DividerView()
                        .padding(.bottom, 5)
                    
                    Toggle(isOn: $viewModel.slowAlert) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("느린 우체통 알림")
                                .foregroundStyle(postieColors.tabBarTintColor)
                            
                            Text("정해둔 시간이 지나 편지를 열 수 있게 되면 알림을 받을 수 있습니다.")
                                .font(.footnote)
                                .foregroundColor(postieColors.dividerColor)
                        }
                    }
                    .onTapGesture {
                        moveToNotificationSetting()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        Task {
                            await viewModel.changeToggleState()
                        }
                    }
                    .disabled(!viewModel.allAlert)
                    
                }
                .padding()
            }
            .tint(viewModel.isThemeGroupButton == 4 ? .postieDarkGray : postieColors.tintColor)
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Text("알림 설정")
                    .bold()
                    .foregroundStyle(postieColors.tintColor)
            }
        }
        .toolbarBackground(postieColors.backGroundColor, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
//    AlertView()
//}
