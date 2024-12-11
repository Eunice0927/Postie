//
//  NoticeViewModel.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 7/4/24.
//

import Foundation

class NoticeViewModel: ObservableObject {
    @Published var isExpanded: Bool = false
    @Published var isThemeGroupButton: Int
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        self.isThemeGroupButton = userDefaults.integer(forKey: "isThemeGroupButton")
    }
    
    func parseText(_ text: String) -> [(String, Bool)] {
        var result: [(String, Bool)] = []
        var tempText = text

        while let range = tempText.range(of: "bold(") {
            let textBeforeBold = String(tempText[..<range.lowerBound])
            tempText.removeSubrange(..<range.upperBound)

            if let endRange = tempText.range(of: ")") {
                let boldText = String(tempText[..<endRange.lowerBound])
                tempText.removeSubrange(..<endRange.upperBound)

                if !textBeforeBold.isEmpty {
                    result.append((textBeforeBold, false))
                }
                result.append((boldText, true))
            }
        }

        if !tempText.isEmpty {
            result.append((tempText, false))
        }

        return result
    }
}
