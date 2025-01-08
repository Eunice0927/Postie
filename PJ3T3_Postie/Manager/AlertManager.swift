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
        self.isOneButtonAlertPresented = true
    }
    
    func showTwoButtonAlert(title: String, message: String, leftButtonLabel: String, leftButtonRole: ButtonRole? = nil, leftButtonAction: (() -> Void)? = nil, rightButtonLabel: String, rightButtonRole: ButtonRole? = nil, rightButtonAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.leftButton = AlertButton(title: leftButtonLabel, role: leftButtonRole, action: leftButtonAction)
        self.rightButton = AlertButton(title: rightButtonLabel, role: rightButtonRole, action: rightButtonAction)
        self.isTwoButtonAlertPresented = true
    }
}
