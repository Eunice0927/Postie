//
//  ProfileEditView.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 2/7/24.
//

import SwiftUI

struct ProfileEditView: View {
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = " postieTest"
    @State private var isShowingProfileImageEditor = false
    @Binding var isThemeGroupButton: Int
    @Binding var profileImage: String
    @Binding var profileImageTemp: String
    
    var body: some View {
        let postieColors = ThemeManager.themeColors[isThemeGroupButton]
        
        ZStack {
            postieColors.backGroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    
                    Button (action: {
                        isShowingProfileImageEditor = true
                        print(profileImageTemp)
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 170, height: 170)
                                .foregroundStyle(.postieGray)
                            
                            Image(profileImageTemp)
                                .resizable()
                                .frame(width: 170, height: 170)
                            
                            Image(systemName: "pencil.circle.fill")
                                .font(.title)
                                .foregroundColor(postieColors.tabBarTintColor)
                                .offset(x: 60, y: 60)
                        }
                    }
                    .sheet(isPresented: $isShowingProfileImageEditor) {
                        ProfileImageEditView(isThemeGroupButton: $isThemeGroupButton, profileImageTemp: $profileImageTemp)
                            .padding()
                            .presentationDetents([.medium])
                    }
                    
                    Spacer()
                }
                
                Text("이름")
                    .foregroundStyle(postieColors.dividerColor)
                
                DividerView(isThemeGroupButton: $isThemeGroupButton)
                
                TextField(" 닉네임을 입력하세요", text: $name)
                    .padding(.bottom)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            Rectangle()
                                .frame(height: 50)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(postieColors.receivedLetterColor)
                                )
                            
                            Text("취소")
                                .foregroundStyle(postieColors.tabBarTintColor)
                                .padding()
                        }
                    }
                    
                    Button(action: {
                        profileImage = profileImageTemp
                        dismiss()
                    }) {
                        ZStack {
                            Rectangle()
                                .frame(height: 50)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(postieColors.tintColor)
                                )
                            
                            Text("저장")
                                .foregroundStyle(isThemeGroupButton == 4 ? .postieBlack : .postieWhite)
                                .padding()
                        }
                    }
                    .onChange(of: profileImage) { newValue in
                        saveToUserDefaults(value: newValue, key: "profileImage")
                    }
                }
            }
        }
    }
}

struct ProfileImageEditView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var isSelectedProfileImage = 0
    @Binding var isThemeGroupButton: Int
    @Binding var profileImageTemp: String
    
    var body: some View {
        let postieColors = ThemeManager.themeColors[isThemeGroupButton]
        
        VStack {
            Text("나만의 프로필을 설정해보세요!")
                .bold()
                .font(.title2)
                .foregroundStyle(postieColors.tabBarTintColor)
            
            ScrollView(.horizontal) {
                HStack {
                    Button (action: {
                        isSelectedProfileImage = 0
                        profileImageTemp = "postyReceivingBeige"
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 172, height: 172)
                                .foregroundStyle(isSelectedProfileImage == 0 ? postieColors.tintColor : postieColors.tintColor.opacity(0))
                            
                            Circle()
                                .frame(width: 170, height: 170)
                                .foregroundStyle(postieColors.profileColor)
                            
                            Image("postyReceivingBeige")
                                .resizable()
                                .frame(width: 170, height: 170)
                        }
                    }
                    
                    Button (action: {
                        isSelectedProfileImage = 1
                        profileImageTemp = "postySmile"
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 172, height: 172)
                                .foregroundStyle(isSelectedProfileImage == 1 ? postieColors.tintColor : postieColors.tintColor.opacity(0))
                            
                            Circle()
                                .frame(width: 170, height: 170)
                                .foregroundStyle(postieColors.profileColor)
                            
                            Image("postySmile")
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                    }
                    
                    Button (action: {
                        isSelectedProfileImage = 2
                        profileImageTemp = "postySending"
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 172, height: 172)
                                .foregroundStyle(isSelectedProfileImage == 2 ? postieColors.tintColor : postieColors.tintColor.opacity(0))
                            
                            Circle()
                                .frame(width: 170, height: 170)
                                .foregroundStyle(postieColors.profileColor)
                            
                            Image("postySending")
                                .resizable()
                                .frame(width: 150, height: 150)
                        }
                        
                    }
                    
                    Button (action: {
                        isSelectedProfileImage = 3
                        profileImageTemp = "postyReceiving"
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 172, height: 172)
                                .foregroundStyle(isSelectedProfileImage == 3 ? postieColors.tintColor : postieColors.tintColor.opacity(0))
                            
                            Circle()
                                .frame(width: 170, height: 170)
                                .foregroundStyle(postieColors.profileColor)
                            
                            Image("postyReceiving")
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                    }
                    
                    Button (action: {
                        isSelectedProfileImage = 4
                        profileImageTemp = "postyTrumpet"
                        print(profileImageTemp)
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 172, height: 172)
                                .foregroundStyle(isSelectedProfileImage == 4 ? postieColors.tintColor : postieColors.tintColor.opacity(0))
                            
                            Circle()
                                .frame(width: 170, height: 170)
                                .foregroundStyle(postieColors.profileColor)
                            
                            Image("postyTrumpet")
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                    }
                    
                    Button (action: {
                        isSelectedProfileImage = 5
                        profileImageTemp = "postyThinking"
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 172, height: 172)
                                .foregroundStyle(isSelectedProfileImage == 5 ? postieColors.tintColor : postieColors.tintColor.opacity(0))
                            
                            Circle()
                                .frame(width: 170, height: 170)
                                .foregroundStyle(postieColors.profileColor)
                            
                            Image("postyThinking")
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                    }
                }
                .onChange(of: profileImageTemp) { newValue in
                    saveToUserDefaults(value: newValue, key: "profileImageTemp")
                }
                .padding()
            }
            
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    ZStack {
                        Rectangle()
                            .frame(height: 50)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(postieColors.receivedLetterColor)
                            )
                        
                        Text("취소")
                            .foregroundStyle(postieColors.tabBarTintColor)
                            .padding()
                    }
                }
                
                Button(action: {
                    dismiss()
                    print(profileImageTemp)
                }) {
                    ZStack {
                        Rectangle()
                            .frame(height: 50)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(postieColors.tintColor)
                            )
                        
                        Text("저장")
                            .foregroundStyle(isThemeGroupButton == 4 ? .postieBlack : .postieWhite)
                            .padding()
                    }
                }
            }
        }
    }
}

//#Preview {
//    ProfileEditView()
//}
