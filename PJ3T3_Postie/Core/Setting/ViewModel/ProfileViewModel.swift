//
//  ProfileViewModel.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 7/7/24.
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var alertBody = ""
    @Published var isLogOutAlert: Bool = false
    @Published var isSignOutAlert: Bool = false
    @Published var isshowingMembershipView = false
    @Published var isShowingProfileEditView = false
    @Published var isDeleteAccountDialogPresented = false
    @Published var showLoading = false
    @Published var showAlert = false
    @Published var selectedThemeButton: Int = 0
}
