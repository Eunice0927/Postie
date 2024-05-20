//
//  SlowPostBoxViewModel.swift
//  PJ3T3_Postie
//
//  Created by KHJ on 2024/02/22.
//

import Foundation

final class SlowPostBoxViewModel: SlowAndAddItemViewModel {
    @Published var date: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    var isNotEnoughInfo: Bool {
        text.isEmpty
    }
    var currentUserName: String { //nickname없을시만 처리할지 고민해보기
        AuthManager.shared.currentUser?.nickname ??
        AuthManager.shared.currentUser?.fullName ??
        AuthManager.shared.currentUser?.id ??
        "유저"
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
                
                setNotification(docId: docId, date: date)
                
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
        let writer = currentUserName
        let recipient = currentUserName
        
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
    
    func setNotification(docId: String, date: Date) {
        let manager = NotificationManager.shared
        //title이나 body 부분의 문구 여러가지로 배열 작성 해 두었다가 알람 뜰 때 랜덤으로 설정되면 좋을 것 같아요~
        manager.addNotification(id: docId, title: "포스티가 편지를 배달했어요", body: summary.count == 0 ? "포스티에서 내용을 확인 해 보세요" : summary)
        manager.setNotification(date: date)
    }
}
