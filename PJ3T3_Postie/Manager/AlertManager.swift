//
//  AlertManager.swift
//  PJ3T3_Postie
//
//  Created by Eunsu JEONG on 1/8/25.
//

import SwiftUI

final class AlertManager: ObservableObject {
    @Published var isOneButtonAlertPresented: Bool = false
    @Published var isTwoButtonAlertPresented: Bool = false
    @Published var alertAction: (() -> Void) = { }
    @Published var title: String = ""
    @Published var message: String = ""
    @Published var singleButton: AlertButton? = nil
    @Published var leftButton: AlertButton? = nil
    @Published var rightButton: AlertButton? = nil
    
    struct AlertButton {
        let title: String?
        let role: ButtonRole?
        let action: (() -> Void)?
    }
    
    func showOneButtonAlert(title: String, message: String, buttonLabel: String? = nil, buttonRole: ButtonRole? = nil, buttonAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.singleButton = AlertButton(title: buttonLabel, role: buttonRole, action: buttonAction)
        DispatchQueue.main.async {
            self.isOneButtonAlertPresented = true
        }
    }
    
    func showTwoButtonAlert(title: String, message: String, leftButtonLabel: String, leftButtonRole: ButtonRole? = nil, leftButtonAction: (() -> Void)? = nil, rightButtonLabel: String, rightButtonRole: ButtonRole? = nil, rightButtonAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.leftButton = AlertButton(title: leftButtonLabel, role: leftButtonRole, action: leftButtonAction)
        self.rightButton = AlertButton(title: rightButtonLabel, role: rightButtonRole, action: rightButtonAction)
        DispatchQueue.main.async {
            self.isTwoButtonAlertPresented = true
        }
    }
    
    func showNotEnoughInfoAlert(isReceived: Bool) {
        showOneButtonAlert(title: "편지 정보 부족", message: "편지를 저장하기 위한 정보가 부족해요. \(isReceived ? "보낸 사람" : "받는 사람")과 내용을 채워주세요.")
    }
    
    func showUploadErrorAlert() {
        showOneButtonAlert(title: "편지 저장 실패", message: "편지 저장에 실패했어요. 다시 시도해주세요.")
    }
    
    func showSummaryErrorAlert() {
        showOneButtonAlert(title: "편지 요약 실패", message: "편지 요약에 실패했어요. 직접 요약해주세요.")
    }
    
    func showLetterDismissAlert(rightButtonAction: (() -> Void)? = nil) {
        showTwoButtonAlert(
            title: "작성을 취소하실 건가요?",
            message: "변경된 내용이 저장되지 않아요!",
            leftButtonLabel: "계속 쓸래요",
            leftButtonRole: .cancel,
            rightButtonLabel: "그만 할래요",
            rightButtonRole: .destructive,
            rightButtonAction: rightButtonAction
        )
    }
    
    func showEditErrorAlert() {
        showOneButtonAlert(title: "편지 수정 실패", message: "편지 수정에 실패했어요. 다시 시도해 주세요")
    }
    
    func showUpdateAlert(isForceUpdate: Bool) {
        let appleID = 6478052812 //테스트용 멜론 앱으로 연결: 415597317
        let appStoreURL = "itms-apps://itunes.apple.com/app/apple-store/\(appleID)"
        let alertTitle = "업데이트 알림"
        let alertMessage = "새로운 버전 업데이트가 있어요! 더 나은 서비스를 위해 포스티를 업데이트 해 주세요."
        let updateButtonLabel = "업데이트"
        let updateAction = {
            if let url = URL(string: appStoreURL) {
                UIApplication.shared.open(url)
            }
        }
        
        if isForceUpdate {
            showOneButtonAlert(
                title: alertTitle,
                message: alertMessage,
                buttonLabel: updateButtonLabel,
                buttonAction: updateAction
            )
        } else {
            showTwoButtonAlert(
                title: alertTitle,
                message: alertMessage,
                leftButtonLabel: "나중에",
                leftButtonRole: .cancel,
                rightButtonLabel: updateButtonLabel,
                rightButtonAction: updateAction
            )
        }
    }
}
