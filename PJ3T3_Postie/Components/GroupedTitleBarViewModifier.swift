//
//  GroupedTitleBarViewModifier.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 12/11/24.
//

import SwiftUI

struct GroupedTitleBarViewModifier: ViewModifier {
    @Binding var isMenuActive: Bool
    
    let title: String
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                if self.isMenuActive {
                    self.isMenuActive = false
                }
            }
            .toolbarBackground(postieColors.backGroundColor, for: .navigationBar)
            .tint(postieColors.tabBarTintColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .bold()
                        .foregroundStyle(postieColors.tintColor)
                }
            }
    }
}
