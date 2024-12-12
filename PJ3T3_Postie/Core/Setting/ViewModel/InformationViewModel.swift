//
//  InformationViewModel.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 7/7/24.
//

import SwiftUI

class InformationViewModel: ObservableObject {
    @Published var columns = Array(repeating: GridItem(.flexible(), spacing: 9), count: 2)
    
    struct PersonGridView: View {
        var person: Person
        
        var body: some View {
            VStack {
                ZStack {
                    Rectangle()
                        .frame(height: 190)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .foregroundStyle(person.color)
                        .shadow(color: .black, radius: 0.8)
                    
                    VStack {
                        Text(person.name)
                            .bold()
                        
                        Text(person.subtitle)
                            .font(.footnote)
                        
                        Image(person.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                    }
                    .foregroundStyle(.postieWhite)
                }
            }
        }
    }
}
