//
//  NoticeViewModel.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 7/4/24.
//

import SwiftUI

class NoticeViewModel: ObservableObject {
    @Published var isExpanded: Bool = false
    @Published var isThemeGroupButton: Int
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        self.isThemeGroupButton = userDefaults.integer(forKey: "isThemeGroupButton")
    }
    
    func parseText(_ text: String) -> Text {
        var resultText = Text("")
        var tempText = text
        
        while let range = tempText.range(of: "bold(") {
            let textBeforeBold = tempText[..<range.lowerBound]
            tempText.removeSubrange(..<range.upperBound)
            
            if let endRange = tempText.range(of: ")") {
                let boldText = tempText[..<endRange.lowerBound]
                tempText.removeSubrange(..<endRange.upperBound)
                
                resultText = resultText + Text(textBeforeBold) + Text(boldText).bold()
            }
        }
        
        resultText = resultText + Text(tempText) // 나머지 텍스트 추가
        
        return resultText
    }
}
