//
//  NoticeView.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 2/11/24.
//

import SwiftUI

struct NoticeView: View {
    
    @EnvironmentObject var remoteConfigManager: RemoteConfigManager
    @ObservedObject var firestoreNoticeManager = FirestoreNoticeManager.shared
    @StateObject private var viewModel = NoticeViewModel()
    
    @State var latestNoticeUUID: String = ""
    @Binding var hasNewNotice: Bool
    
    var body: some View {
        ZStack {
            postieColors.backGroundColor
                .ignoresSafeArea()
            
            HStack {
                Spacer()
                
                VStack {
                    Spacer()
                    
                    if firestoreNoticeManager.notices.isEmpty {
                        VStack {
                            Image(viewModel.isThemeGroupButton == 4 ? "postyThinkingSketchWhite" : "postyThinkingSketch")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                            
                            Text("공지사항을 불러오는 중입니다.")
                                .foregroundStyle(postieColors.tabBarTintColor)
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    ForEach(firestoreNoticeManager.notices.sorted(by: { $0.date > $1.date }), id:\.self) { notice in
                        DisclosureGroup {
                            ZStack {
                                postieColors.receivedLetterColor
                                    .ignoresSafeArea()
                                
                                VStack(alignment: .leading) {
                                    Text("안녕하세요. 포스티 팀입니다! 💌\n")
                                        .font(.callout)
                                    
//                                    if let imageURL = post.imageURL {
//                                        Image(systemName: "photo")
//                                            .resizable()
//                                            .scaledToFit()
//                                    }
                                    
                                    let noticeText = viewModel.parseText(notice.content.replacingOccurrences(of: "\\n", with: "\n"))
                                    
                                    ForEach(noticeText, id: \.0) { part in
                                        Text(part.0)
                                            .font(.callout)
                                            .fontWeight(part.1 ? .bold : .regular)
                                            .onAppear {
                                                if notice.id == latestNoticeUUID {
                                                    hasNewNotice = false
                                                    UserDefaultsManager.set(latestNoticeUUID, forKey: .lastestNoticeUUID)
                                                }
                                            }
                                    }
                                    
                                    HStack {
                                        Spacer()
                                        
                                        Text("From. ")
                                            .font(.custom("SourceSerifPro-Black", size: 16))
                                        + Text("포스티팀")
                                            .font(.callout)
                                    }
                                }
                                .padding()
                            }
                            .padding(.top, 10)
                        } label: {
                            VStack(alignment: .leading) {
                                HStack(alignment: .firstTextBaseline, spacing: 0) {
                                    Text(notice.date.toString())
                                        .font(.caption)
                                        .foregroundColor(postieColors.dividerColor)
                                        .padding(.trailing, 4)
                                    
                                    if hasNewNotice, notice.id == latestNoticeUUID {
                                        Text("New")
                                            .font(.caption)
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 4)
                                            .background {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .foregroundStyle(.red)
                                            }
                                    }
                                }
                                
                                Text(notice.title)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        
                        DividerView()
                    }
                }
                .onAppear {
                    if firestoreNoticeManager.notices.isEmpty {
                        firestoreNoticeManager.fetchAllNotices()
                    }
                    latestNoticeUUID = remoteConfigManager.getString(from: .latest_notice_uuid) ?? ""
                }
            }
            .padding(.leading)
            .padding(.trailing)
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Text("공지사항")
                    .bold()
                    .foregroundStyle(postieColors.tintColor)
            }
        }
        .toolbarBackground(postieColors.backGroundColor, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
//    NoticeView()
//}
