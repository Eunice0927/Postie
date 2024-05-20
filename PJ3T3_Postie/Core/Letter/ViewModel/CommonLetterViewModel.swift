//
//  CommonLetterViewModel.swift
//  PJ3T3_Postie
//
//  Created by Eunsu JEONG on 5/20/24.
//

import Foundation
import UIKit

class CommonLetterViewModel: ObservableObject {
    @Published var sender: String = ""
    @Published var receiver: String = ""
    @Published var text: String = ""
    @Published var summary: String = ""
    @Published var showingUIImagePicker = false
    @Published var showingLetterImageFullScreenView: Bool = false
    @Published var showingTextRecognizerErrorAlert: Bool = false
    @Published var showingSummaryTextField: Bool = false
    @Published var showingSummaryAlert: Bool = false
    @Published var showingImageConfirmationDialog: Bool = false
    @Published var showingSummaryConfirmationDialog: Bool = false
    @Published var showingSummaryErrorAlert: Bool = false
    @Published var images: [UIImage] = []
    @Published var selectedIndex: Int = 0
    @Published var shouldDismiss: Bool = false
    @Published var isLoading: Bool = false
    @Published var loadingText: String = ""
    
    private(set) var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    
    func removeImage(at index: Int) {
        images.remove(at: index)
    }
    
    func showUIImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePickerSourceType = sourceType
        showingUIImagePicker = true
    }
    
    func showLetterImageFullScreenView(index: Int) {
        selectedIndex = index
        showingLetterImageFullScreenView = true
    }

    func showSummaryTextField() {
        showingSummaryTextField = true
    }

    func showSummaryAlert() {
        showingSummaryAlert = true
    }

    func showSummaryErrorAlert() {
        showingSummaryErrorAlert = true
    }

    func dismissView() {
        shouldDismiss = true
    }

    func showConfirmationDialog() {
        showingImageConfirmationDialog = true
    }

    func showSummaryConfirmationDialog() {
        showingSummaryConfirmationDialog = true
    }
    
    func getSummary(isReceived: Bool) async {
        do {
            let summaryResponse = try await APIClient.shared.postRequestToAPI(
                title: isReceived ? "\(sender)에게 받은 편지" : "\(receiver)에게 쓴 편지",
                content: text
            )

            await MainActor.run {
                summary = summaryResponse
                showSummaryTextField()
            }
        } catch {
            await MainActor.run {
                showSummaryErrorAlert()
            }
        }
    }
}
