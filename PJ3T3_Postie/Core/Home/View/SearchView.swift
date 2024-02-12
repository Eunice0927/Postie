//
//  SearchView.swift
//  PJ3T3_Postie
//
//  Created by Eunsu JEONG on 2/6/24.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var firestoreManager = FirestoreManager.shared
    @Binding var isThemeGroupButton: Int
    @State var searchQuery = ""
    @State var filteredLetters: [Letter] = []
    
    var body: some View {
        let postieColors = ThemeManager.themeColors[isThemeGroupButton]
        
        ZStack {
            postieColors.backGroundColor
                .ignoresSafeArea()
            
            if filteredLetters.isEmpty {
                if searchQuery == "" {
                    VStack {
                        Image("postyReceiving")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                        
                        Text("어렴풋한 기억을 검색해보세요")
                            .foregroundStyle(postieColors.dividerColor)
                    }
                } else {
                    Image("postyReceiving")
                        .opacity(0.03)
                    
                    Text("일치하는 내용의 편지가 없어요")
                        .foregroundStyle(postieColors.dividerColor)
                }
            } else {
                ScrollView {
                    ForEach(filteredLetters) { letter in
                        NavigationLink {
                            LetterDetailView(letter: letter)
                        } label: {
                            LetterItemView(letter: letter, isThemeGroupButton: $isThemeGroupButton)
                        }
                    }
                    
                    // ScrollView margin 임시
                    Rectangle()
                        .frame(height: 70)
                        .foregroundStyle(Color.postieBlack.opacity(0))
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("편지 찾기")
        .searchable(text: $searchQuery, prompt: "찾고 싶은 기억이 있나요?")
        .autocorrectionDisabled()
        .scrollDismissesKeyboard(.immediately)
        .onTapGesture {
            hideKeyboard()
        }
        .customOnChange(searchQuery) { newValue in
            filterLetters(newValue)
        }
    }
    
    //searchQuery가 비어있지 않으면 recipies를 name으로 필터링한다.
    private func filterLetters(_ searchQuery: String) {
        //localizedCaseInsensitiveContains: 검색 내용이 비어있지 않을 때 대소문자를 무시한 결과를 필터함
        filteredLetters = firestoreManager.letters.filter {
            $0.text.localizedCaseInsensitiveContains(searchQuery) ||
            $0.summary.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    //name을 받아 query와 일치하는 부분만 font 색상을 변경한다. 현재 뷰에서는 사용되지 않고 있음
    private func makeAttributedString(name: String, query: String) -> AttributedString {
        var string = AttributedString(name)
        
        string.foregroundColor = .green
        
        if let range = string.range(of: query) { /// here!
            string[range].foregroundColor = .red
        }
        
        return string
    }
}

#Preview {
    SearchView(isThemeGroupButton: .constant(0))
}