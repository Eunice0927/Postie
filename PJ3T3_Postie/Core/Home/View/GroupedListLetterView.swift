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
    var recipient: String
    @State private var showAlert = false
    @State private var isSideMenuOpen = false
    @Binding var isThemeGroupButton: Int
    
    
    @ViewBuilder
    func GroupedLetterView(letter: Letter) -> some View {
        if letter.recipient == recipient || letter.writer == recipient {
            LetterItemView(isThemeGroupButton: $isThemeGroupButton, letter: letter)
        } else {
            EmptyView()
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.postieBeige
                .ignoresSafeArea()
            
            ScrollView {
                ForEach(firestoreManager.letters, id: \.self) { letter in
                    NavigationLink {
                        LetterDetailView(letter: letter)
                    } label: {
                        GroupedLetterView(letter: letter)
                    }
                }
                
                // ScrollView margin 임시
                Rectangle()
                    .frame(height: 70)
                    .foregroundStyle(Color.postieBlack.opacity(0))
            }
            
            AddLetterButton(isThemeGroupButton: $isThemeGroupButton)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("\(recipient)")
                    .bold()
                    .foregroundStyle(Color.postieOrange)
            }
        }
        .tint(Color.postieBlack)
    }
}

//#Preview {
//    GroupedListLetterView()
//}
