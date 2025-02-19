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

class EditLetterViewModel: ObservableObject {
    @Published var sender: String = ""
    @Published var receiver: String = ""
    @Published var date: Date = .now
    @Published var text: String = ""
    @Published var summary: String = ""
    @Published var showingUIImagePicker = false
    @Published var showingLetterImageFullScreenView: Bool = false
    @Published var showingSummaryTextField: Bool = false
    @Published var showingImageConfirmationDialog: Bool = false
    @Published var showingSummaryConfirmationDialog: Bool = false
    @Published var selectedIndex: Int = 0
    @Published var shouldDismiss: Bool = false
    @Published var isLoading: Bool = false
    @Published var loadingText: String = "편지를 저장하고 있어요."
    @Published var showingSelectSummaryView: Bool = false
    @Published var summaryList: [String] = []
    @Published var selectedSummary: String = ""
    @Published var showingDismissAlert: Bool = false
    @Published var showingSaveAlert: Bool = false
    
    private var alertManager: AlertManager?
    private(set) var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    
    func setAlertManager(alertManager: AlertManager) {
        self.alertManager = alertManager
    }
    
    func showDismissAlert() {
        showingDismissAlert = true
    }

    func showSaveAlert() {
        showingSaveAlert = true
    }

    func removeImage(at index: Int) {
        newImages.remove(at: index)
    }

    func showUIImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePickerSourceType = sourceType
        showingUIImagePicker = true
    }

    func showLetterImageFullScreenView(index: Int) {
        selectedIndex = index
        showingLetterImageFullScreenView = true
    }
    
    func showSelectSummaryView() {
        showingSelectSummaryView = true
    }
    
    func closeSelectSummaryView() {
        showingSelectSummaryView = false
    }

    func showSummaryTextField() {
        showingSummaryTextField = true
    }

    private func dismissView() {
        shouldDismiss = true
    }

    func showConfirmationDialog() {
        showingImageConfirmationDialog = true
    }

    func showSummaryConfirmationDialog() {
        showingSummaryConfirmationDialog = true
    }
    
    // MARK: - checkIsEdited
    
    private var originalLetter: Letter? = nil
    private var originalImagesCount: Int = 0

    // 변경 여부 확인 함수
    func isEdited() -> Bool {
        return sender != originalLetter?.writer ||
        receiver != originalLetter?.recipient ||
        date != originalLetter?.date ||
        text != originalLetter?.text ||
        summary != originalLetter?.summary ||
        originalImagesCount != fullPathsAndUrls.count || // 그 외의 이미지 변경점 확인
        !newImages.isEmpty // 이미지 x -> 이미지 추가. 변경점 확인
    }

    // MARK: - Images

    @Published var newImages: [UIImage] = []

    @Published var fullPathsAndUrls: [FullPathAndUrl] = []
    var deleteCandidatesFromFullPathsANdUrls: [FullPathAndUrl] = []

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

            let (newImageFullPaths, newImageUrls) = try await addImages(docId: letter.id, newImages: newImages)

            try await updateLetterInfo(docId: letter.id, newImageUrls: newImageUrls, newImageFullPaths: newImageFullPaths, letter: letter)

            try await fetchLetter(docId: letter.id)

            try await fetchAllLetters()

            await MainActor.run {
                dismissView()
            }
        } catch {
            await MainActor.run {
                isLoading = false
                alertManager?.showEditErrorAlert()
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
        
        // 편지 수정 완료 시 비교할 원본 값
        originalLetter = letter
        originalImagesCount = fullPathsAndUrls.count
    }

    func getSummary(isReceived: Bool) async {
        do {
            let summaries = try await APIClient.shared.postRequestToAPI(
                content: text
            )

            await MainActor.run {
                summaryList = summaries
                showSelectSummaryView()
            }
        } catch {
            alertManager?.showSummaryErrorAlert()
        }
    }
}
