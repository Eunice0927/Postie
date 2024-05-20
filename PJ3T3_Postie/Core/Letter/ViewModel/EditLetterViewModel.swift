//
//  EditLetterViewModel.swift
//  PJ3T3_Postie
//
//  Created by KHJ on 2024/02/14.
//

import Foundation
import OSLog
import UIKit

struct FullPathAndUrl {
    let fullPath: String
    let url: String
}

final class EditLetterViewModel: CommonLetterViewModel {
    @Published var date: Date = .now
    @Published var showingEditErrorAlert: Bool = false
    @Published var fullPathsAndUrls: [FullPathAndUrl] = []
    
    var deleteCandidatesFromFullPathsANdUrls: [FullPathAndUrl] = []
    
    func showEditErrorAlert() {
        showingEditErrorAlert = true
    }

    private func removeImages(docId: String, deleteCandidates: [FullPathAndUrl]) async throws {
        for deleteCandidate in deleteCandidatesFromFullPathsANdUrls {
            try await StorageManager.shared.deleteItemAsync(fullPath: deleteCandidate.fullPath)
        }

        try await FirestoreManager.shared.removeFullPathsAndUrlsAsync(
            docId: docId,
            fullPaths: deleteCandidates.map { $0.fullPath },
            urls: deleteCandidates.map { $0.url }
            )
    }

    private func addImages(docId: String, newImages: [UIImage]) async throws -> ([String], [String]) {
        var newImageFullPaths = [String]()
        var newImageUrls = [String]()

        for image in newImages {
            let fullPath = try await StorageManager.shared.uploadUIImage(image: image, docId: docId)
            let url = try await StorageManager.shared.requestImageURL(fullPath: fullPath)

            newImageFullPaths.append(fullPath)
            newImageUrls.append(url)
        }

        return (newImageFullPaths, newImageUrls)
    }

    private func updateLetterInfo(docId: String, newImageUrls: [String], newImageFullPaths: [String], letter: Letter) async throws {
        try await FirestoreManager.shared.updateLetterAsync(
            docId: docId,
            writer: sender,
            recipient: receiver,
            summary: summary,
            date: date,
            text: text,
            isReceived: letter.isReceived,
            isFavorite: letter.isFavorite,
            imageURLs: newImageUrls,
            imageFullPaths: newImageFullPaths
        )
    }

    private func fetchLetter(docId: String) async throws {
        let updatedLetter = try await FirestoreManager.shared.getLetter(docId: docId)

        await MainActor.run {
            FirestoreManager.shared.letter = updatedLetter
        }
    }

    private func fetchAllLetters() async throws {
        try await FirestoreManager.shared.fetchAllLettersAsync()
    }

    func updateLetter(letter: Letter) async {
        do {
            await MainActor.run {
                isLoading = true
                loadingText = "편지를 수정하고 있어요."
            }

            try await removeImages(docId: letter.id, deleteCandidates: deleteCandidatesFromFullPathsANdUrls)

            let (newImageFullPaths, newImageUrls) = try await addImages(docId: letter.id, newImages: images)

            try await updateLetterInfo(docId: letter.id, newImageUrls: newImageUrls, newImageFullPaths: newImageFullPaths, letter: letter)

            try await fetchLetter(docId: letter.id)

            try await fetchAllLetters()

            await MainActor.run {
                dismissView()
            }
        } catch {
            await MainActor.run {
                isLoading = false

                showEditErrorAlert()
            }
            Logger.firebase.error("Failed to edit letter: \(error)")
        }
    }

    func syncViewModelProperties(letter: Letter) {
        sender = letter.writer
        receiver = letter.recipient
        date = letter.date
        text = letter.text
        summary = letter.summary

        // 요약 텍스트 필드 확인
        showingSummaryTextField = !letter.summary.isEmpty

        guard let urls = letter.imageURLs, let fullPaths = letter.imageFullPaths else { return }
        fullPathsAndUrls = zip(urls, fullPaths).map { FullPathAndUrl(fullPath: $0.1, url: $0.0) }
    }
}
