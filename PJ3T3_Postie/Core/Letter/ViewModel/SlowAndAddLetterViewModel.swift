//
//  SlowAndAddLetterViewModel.swift
//  PJ3T3_Postie
//
//  Created by Eunsu JEONG on 5/20/24.
//

import Foundation

class SlowAndAddItemViewModel: CommonLetterViewModel {
    @Published var showingDismissAlert: Bool = false
    @Published var showingNotEnoughInfoAlert: Bool = false
    @Published var showingUploadErrorAlert: Bool = false
    
    var isReceived: Bool
    
    init(isReceived: Bool) {
        self.isReceived = isReceived
    }
    
    func showNotEnoughInfoAlert() {
        showingNotEnoughInfoAlert = true
    }
    
    func showUploadErrorAlert() {
        showingUploadErrorAlert = true
    }
    
    func showDismissAlert() {
        showingDismissAlert = true
    }
    
    func uploadImages(docId: String) async throws -> ([String], [String]) {
        var newImageFullPaths = [String]()
        var newImageUrls = [String]()

        // 이미지 추가
        for image in images {
            let fullPath = try await StorageManager.shared.uploadUIImage(image: image, docId: docId)
            let url = try await StorageManager.shared.requestImageURL(fullPath: fullPath)
            newImageFullPaths.append(fullPath)
            newImageUrls.append(url)
        }

        return (newImageFullPaths, newImageUrls)
    }
}
