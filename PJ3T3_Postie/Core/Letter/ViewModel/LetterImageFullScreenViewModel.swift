//
//  LetterImageFullScreenViewModel.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 3/16/25.
//

import OSLog
import FirebaseStorage
import Foundation
import UIKit
import Photos

class LetterImageFullScreenViewModel: ObservableObject {
    @Published var showingDownloadAlert: Bool = false
    @Published var isDownloading = false
    
    func showDownloadAlert() {
        showingDownloadAlert = true
    }
    
    func downloadAndSaveImage(fullPath: String) async {
        await MainActor.run {
            self.isDownloading = true // 다운로드 시작 시 표시
        }
        
        do {
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child(fullPath)
            
            let data = try await imageRef.data(maxSize: 10 * 1024 * 1024)
            guard let image = UIImage(data: data) else {
                await MainActor.run {
                    Logger.firebase.info("이미지 변환 실패")
                    self.isDownloading = false
                }
            return
        }
        
        // 사진 저장
        try await saveImageToPhotoLibrary(image: image)
        } catch {
            await MainActor.run {
                Logger.firebase.info("다운로드 URL 가져오기 실패, 에러: \(error.localizedDescription)")
                self.isDownloading = false
            }
        }
        
        await MainActor.run {
            self.isDownloading = false
        }
    }
    
    private func saveImageToPhotoLibrary(image: UIImage) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    DispatchQueue.main.async {
                        Logger.firebase.info("사진이 성공적으로 저장되었습니다!")
                        continuation.resume(returning: ())
                    }
                case .denied, .restricted:
                    DispatchQueue.main.async {
                        Logger.firebase.info("사진 라이브러리 접근 권한이 없습니다.")
                        continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "권한 거부"]))
                    }
                default:
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "알 수 없는 에러"]))
                }
            }
        }
    }
}
