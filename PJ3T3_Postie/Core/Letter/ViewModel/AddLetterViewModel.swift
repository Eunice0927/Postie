//
//  AddLetterViewModel.swift
//  PJ3T3_Postie
//
//  Created by KHJ on 2024/01/17.
//

import Foundation
import UIKit

final class AddLetterViewModel: SlowAndAddItemViewModel {
    @Published var date: Date = .now
    
    var isNotEnoughInfo: Bool {
        (isReceived && (sender.isEmpty || text.isEmpty))
            || (!isReceived && (receiver.isEmpty || text.isEmpty))
    }
    
    func uploadLetter() async {
        if isNotEnoughInfo {
            await MainActor.run {
                showNotEnoughInfoAlert()
            }
        } else {
            await MainActor.run {
                isLoading = true
                loadingText = "편지를 저장하고 있어요."
            }

            do {
                let docId = UUID().uuidString

                let (newImageFullPaths, newImageUrls) = try await uploadImages(docId: docId)
                try await addLetter(docId: docId, newImageUrls: newImageUrls, newImageFullPaths: newImageFullPaths, isReceived: isReceived)

                await MainActor.run {
                    dismissView()
                }
            } catch {
                await MainActor.run {
                    isLoading = false

                    showUploadErrorAlert()
                }
            }
        }
    }
    
    func addLetter(docId: String, newImageUrls: [String], newImageFullPaths: [String], isReceived: Bool) async throws {
        let writer = isReceived ? sender : AuthManager.shared.currentUser?.nickname ?? "유저"
        let recipient = isReceived ? AuthManager.shared.currentUser?.nickname ?? "유저" : receiver

        let newLetter = Letter(
            id: docId,
            writer: writer,
            recipient: recipient,
            summary: summary,
            date: date,
            text: text,
            isReceived: isReceived,
            isFavorite: false,
            imageURLs: newImageUrls,
            imageFullPaths: newImageFullPaths
        )

        try await FirestoreManager.shared.addLetter(docId: docId, letter: newLetter)

        await MainActor.run {
            FirestoreManager.shared.letters.append(newLetter)
        }
    }
}

