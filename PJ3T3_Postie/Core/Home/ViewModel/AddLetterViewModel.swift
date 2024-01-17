//
//  AddLetterViewModel.swift
//  PJ3T3_Postie
//
//  Created by KHJ on 2024/01/17.
//

import Foundation
import UIKit

class AddLetterViewModel: ObservableObject {
    @Published var sender: String = ""
    @Published var receiver: String = ""
    @Published var date: Date = .now
    @Published var text: String = "사진을 등록하면 자동으로 편지 내용이 입력됩니다."
    @Published var showConfirmationDialog: Bool = false
    @Published var showUIImagePicker = false

    var imagePickerSourceType: UIImagePickerController.SourceType = .camera
}
