//
//  LetterImageFullScreenViewModel.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 3/16/25.
//

import FirebaseStorage
import Foundation

class LetterImageFullScreenViewModel: ObservableObject {
    @Published var showingDownloadAlert: Bool = false
    
    func showDownloadAlert() {
        showingDownloadAlert = true
    }
}
