//
//  Color.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 1/17/24.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct ThemeData {
    let backGroundColor: Color
    let receivedLetterColor: Color
    let writenLetterColor: Color
    let profileColor: Color
    let tabBarTintColor: Color
    let tintColor: Color
    let dividerColor: Color
}

class ThemeManager {
    static let shared = ThemeManager()
    
    private(set) var currentIndex: Int {
        didSet {
            UserDefaultsManager.set(currentIndex, forKey: .CurrentThemeIndex)
        }
    }
    
    private init() {
        currentIndex = UserDefaultsManager.get(forKey: .CurrentThemeIndex) ?? 0
    }
    
    static let themeColors = [
        ThemeData(backGroundColor: .postieBeige, receivedLetterColor: .postieWhite, writenLetterColor: .postieLightGray, profileColor: .postieGray, tabBarTintColor: .postieBlack, tintColor: .postieOrange, dividerColor: .postieDarkGray),
        ThemeData(backGroundColor: .postieRealWhite, receivedLetterColor: .postieWhite, writenLetterColor: .postieLightGray, profileColor: .postieGray, tabBarTintColor: .postieBlack, tintColor: .postieYellow, dividerColor: .postieDarkGray),
        ThemeData(backGroundColor: .postieWhite, receivedLetterColor: .postieLightBeige, writenLetterColor: .postieRealWhite, profileColor: .postieGray, tabBarTintColor: .postieBlack, tintColor: .postieGreen, dividerColor: .postieDarkGray),
        ThemeData(backGroundColor: .postieRealWhite, receivedLetterColor: .postieLightBlue, writenLetterColor: .postieLightYellow, profileColor: .postieGray, tabBarTintColor: .postieBlack, tintColor: .postieBlue, dividerColor: .postieDarkGray),
        ThemeData(backGroundColor: .postieBlack, receivedLetterColor: .postieLightBlack, writenLetterColor: .postieSpaceGray, profileColor: .postieGray, tabBarTintColor: .postieLightGray, tintColor: .postieLightGray, dividerColor: Color(hex: 0xD5D5D5))
    ]
    
    var currentTheme: ThemeData {
        return ThemeManager.themeColors[currentIndex]
    }
    
    func updateTheme(index: Int) {
        currentIndex = index
    }
}

var postieColors: ThemeData {
    ThemeManager.shared.currentTheme
}
