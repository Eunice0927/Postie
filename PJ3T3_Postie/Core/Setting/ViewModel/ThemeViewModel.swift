//
//  ThemeViewModel.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 10/14/24.
//

import Foundation

class ThemeViewModel: ObservableObject {
    @Published var selectedThemeButton: Int = 0
    
    let names = ["테마 설정", "나열 변경"]
    
    let items = ["포스티 오렌지", "포스티 옐로우", "포스티 그린", "포스티 블루", "포스티 블랙"]
    let listImages = ["postieListOrange", "postieListYellow", "postieListGreen", "postieListBlue", "postieListBlack"]
    let groupImages = ["postieGroupOrange", "postieGroupYellow", "postieGroupGreen", "postieGroupBlue", "postieGroupBlack"]
    let numberOfColumns: Int = 2
    
    func stringFromNumber(_ number: Int) -> String {
        switch number {
        case 1:
            return "Yellow"
        case 2:
            return "Green"
        case 3:
            return "Blue"
        case 4:
            return "Black"
        default:
            return "Orange"
        }
    }
}
