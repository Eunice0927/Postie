//
//  InformationView.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 2/11/24.
//

import SwiftUI

struct InformationView: View {
    @StateObject private var viewModel = InformationViewModel()
    @AppStorage("isThemeGroupButton") private var isThemeGroupButton: Int = 0
    
    var body: some View {
        var appVersion: String {
            if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
               let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
                return "\(version)"
            }
            return "버전 정보 없음"
        }
        
        ZStack {
            postieColors.backGroundColor
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("앱 정보")
                        .foregroundStyle(postieColors.tintColor)
                    
                    DividerView()
                        .padding(.bottom, 5)
                    
                    HStack {
                        Text("버전정보")
                            .foregroundStyle(postieColors.tabBarTintColor)
                        
                        Spacer()
                        
                        Text(appVersion)
                            .foregroundStyle(postieColors.dividerColor)
                    }
                    .padding(.bottom)
                    
                    Text("법률 조항")
                        .foregroundStyle(postieColors.tintColor)
                    
                    DividerView()
                        .padding(.bottom, 5)
                    
                    NavigationLink(destination: InformationWebView(urlToLoad: "https://delirious-antler-185.notion.site/5d018b0df8754b90a70a2ce2e5eedb7a?pvs=4")) {
                        HStack {
                            Text("이용약관")
                                .foregroundStyle(postieColors.tabBarTintColor)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(postieColors.dividerColor)
                        }
                        .padding(.bottom)
                    }
                    
                    NavigationLink(destination: InformationWebView(urlToLoad: "https://delirious-antler-185.notion.site/b6b289d7404c47099b5beefc14acdd35?pvs=4")) {
                        HStack {
                            Text("개인정보 처리방침")
                                .foregroundStyle(postieColors.tabBarTintColor)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(postieColors.dividerColor)
                        }
                        .padding(.bottom)
                    }
                    
                    Text("함께하신 분들")
                        .foregroundStyle(postieColors.tintColor)
                    
                    DividerView()
                        .padding(.bottom, 5)
                    
                    LazyVGrid(columns: viewModel.columns, spacing: 9) {
                        ForEach(0..<PersonData.count, id: \.self) { person in
                            InformationViewModel.PersonGridView(person: PersonData[person])
                        }
                    }
                    .padding(.leading, 2)
                    .padding(.trailing, 2)
                    .padding(.bottom)
                    
                    Text("도움주신 분들")
                        .foregroundStyle(postieColors.tintColor)
                    
                    DividerView()
                        .padding(.bottom, 5)
                    
                    LazyVGrid(columns: viewModel.columns, spacing: 9) {
                        ForEach(0..<ContributeData.count, id: \.self) { person in
                            InformationViewModel.PersonGridView(person: ContributeData[person])
                        }
                    }
                    .padding(.leading, 2)
                    .padding(.trailing, 2)
                    .padding(.bottom)
                }
            }
            .padding(.leading)
            .padding(.trailing)
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Text("앱 정보")
                    .bold()
                    .foregroundStyle(postieColors.tintColor)
            }
        }
        .toolbarBackground(postieColors.backGroundColor, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
//    InformationView()
//}
