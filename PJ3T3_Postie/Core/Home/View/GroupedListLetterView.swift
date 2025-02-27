//
//  GroupedListLetterView.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 2/1/24.
//

import SwiftUI

struct GroupedListLetterView: View {
    @ObservedObject var firestoreManager = FirestoreManager.shared
    @ObservedObject var storageManager = StorageManager.shared
    @State private var isMenuActive = false
    
    var recipient: String
    
    @AppStorage("isThemeGroupButton") private var isThemeGroupButton: Int = 0
    @State private var isSideMenuOpen = false
    
    var body: some View {
        let filteredLetters = firestoreManager.letters.filter {
            $0.recipient == recipient || $0.writer == recipient
        }.sorted {
            $0.date < $1.date
        }
        
        ZStack(alignment: .bottomTrailing) {
            postieColors.backGroundColor
                .ignoresSafeArea()
            
            ScrollView {
                ForEach(filteredLetters, id: \.self) { letter in
                    NavigationLink {
                        LetterDetailView(letter: letter)
                    } label: {
                        LetterItemView(letter: letter)
                    }
                    .disabled(isMenuActive)
                }
                
                // ScrollView margin 임시
                Rectangle()
                    .frame(height: 80)
                    .foregroundStyle(Color.postieBlack.opacity(0))
            }
            
            AddLetterButton(isMenuActive: $isMenuActive, autoFilledName: recipient)
        }
        .modifier(GroupedTitleBarViewModifier(isMenuActive: $isMenuActive, title: recipient))
    }
}

//#Preview {
//    GroupedListLetterView()
//}
