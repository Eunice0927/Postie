//
//  EditLetterView.swift
//  PJ3T3_Postie
//
//  Created by KHJ on 2024/02/14.
//

import SwiftUI

import Kingfisher

struct EditLetterView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @StateObject private var editLetterViewModel = EditLetterViewModel()
    @ObservedObject var firestoreManager = FirestoreManager.shared

    enum Field: Hashable {
        case sender
        case receiver
        case text
        case summary
    }

    let letter: Letter

    @State var extraBottomPadding: CGFloat = 0
    @FocusState private var focusField: Field?
    @Environment(\.dismiss) var dismiss
    @AppStorage("isThemeGroupButton") private var isThemeGroupButton: Int = 0

    init(letter: Letter) {
        self.letter = letter

        // TextEditor 패딩
        UITextView.appearance().textContainerInset = UIEdgeInsets(
            top: 12,
            left: 8,
            bottom: 12,
            right: 8
        )
    }

    var body: some View {
        ZStack {
            postieColors.backGroundColor
                .ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        letterInfoSection
                        
                        letterImagesSection
                        
                        letterTextSection
                    }
                    .padding()
                }
                .customOnChange(focusField) {
                    scrollToBotton(to: $0, proxy: proxy)
                }
            }
        }
        .interactiveDismissDisabled(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(postieColors.backGroundColor, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Text(letter.isReceived ? "받은 편지 기록" : "보낸 편지 기록")
                    .bold()
                    .foregroundStyle(postieColors.tintColor)
            }
            
            ToolbarItemGroup(placement: .topBarLeading) {
                Button {
                    editLetterViewModel.isEdited() ? editLetterViewModel.showDismissAlert() : dismiss()
                } label: {
                    Text("취소")
                }
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    editLetterViewModel.isEdited() ? editLetterViewModel.showSaveAlert() : dismiss()
                } label : {
                    Text("완료")
                }
                .disabled(editLetterViewModel.isLoading)
            }

            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button {
                    focusField = nil
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .scrollDismissesKeyboard(.interactively)
        .modifier(LoadingModifier(isLoading: $editLetterViewModel.isLoading, text: editLetterViewModel.loadingText))
        .fullScreenCover(isPresented: $editLetterViewModel.showingLetterImageFullScreenView) {
            LetterImageFullScreenView(
                images: editLetterViewModel.newImages,
                urls: editLetterViewModel.fullPathsAndUrls.map { $0.url },
                pageIndex: $editLetterViewModel.selectedIndex
            )
        }
        .sheet(isPresented: $editLetterViewModel.showingUIImagePicker) {
            UIImagePicker(
                sourceType: editLetterViewModel.imagePickerSourceType,
                alertManager: alertManager,
                selectedImages: $editLetterViewModel.newImages,
                text: $editLetterViewModel.text,
                isLoading: $editLetterViewModel.isLoading,
                loadingText: $editLetterViewModel.loadingText
            )
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .onAppear {
            editLetterViewModel.syncViewModelProperties(letter: letter)
            editLetterViewModel.setAlertManager(alertManager: alertManager)
        }
        .confirmationDialog("편지 사진 가져오기", isPresented: $editLetterViewModel.showingImageConfirmationDialog, titleVisibility: .visible) {
            Button {
                editLetterViewModel.showUIImagePicker(sourceType: .photoLibrary)
            } label: {
                Label("사진 보관함", systemImage: "photo.on.rectangle")
            }

            Button {
                editLetterViewModel.showUIImagePicker(sourceType: .camera)
            } label: {
                HStack {
                    Text("사진 찍기")

                    Spacer()

                    Image(systemName: "camera")
                }
            }
        }
        .confirmationDialog("편지 요약하기", isPresented: $editLetterViewModel.showingSummaryConfirmationDialog, titleVisibility: .visible) {
            Button("직접 작성") {
                editLetterViewModel.showSummaryTextField()
                focusField = .summary
            }

            Button("AI 완성") {
                Task {
                    await editLetterViewModel.getSummary(isReceived: letter.isReceived)
                }
                focusField = .summary
            }
        }
        .sheet(isPresented: $editLetterViewModel.showingSelectSummaryView) {
            SelectSummaryView
                .presentationDetents([.medium])
                .interactiveDismissDisabled(true)
        }
        .customOnChange(editLetterViewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
        .alert("편지 수정을 그만할까요?", isPresented: $editLetterViewModel.showingDismissAlert) {
            Button {
                
            } label: {
                Text("취소")
            }
            
            Button {
                dismiss()
            } label: {
                Text("확인")
            }
        } message: {
            Text("변경된 내용이 저장되지 않아요!")
        }
        .alert("변경 사항을 저장 할까요?", isPresented: $editLetterViewModel.showingSaveAlert) {
            Button {

            } label: {
                Text("취소")
            }
            
            Button {
                Task {
                    await editLetterViewModel.updateLetter(letter: letter)
                }
            } label: {
                Text("확인")
            }
        } message: {
            Text("편지의 내용이 수정 되었어요!")
        }
    }
    
    private func scrollToBotton(to focusedField: Field?, proxy: ScrollViewProxy) {
        guard focusedField == .summary else {
            extraBottomPadding = 0
            return
        }
        
        extraBottomPadding = 10
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                proxy.scrollTo("summaryField", anchor: .bottom) // 자동 스크롤
            }
        }
    }
}

// MARK: - Computed Views

extension EditLetterView {
    @ViewBuilder
    private var letterInfoSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(letter.isReceived ? "보낸 사람" : "받는 사람")

                TextField("",
                          text: letter.isReceived ?
                          $editLetterViewModel.sender : $editLetterViewModel.receiver)
                .padding(6)
                .background(postieColors.receivedLetterColor)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .focused($focusField, equals: .sender)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text(letter.isReceived ? "받은 날짜" : "보낸 날짜")

                DatePicker(
                    "",
                    selection: $editLetterViewModel.date,
                    displayedComponents: .date
                )
                .labelsHidden()
                .environment(\.locale, Locale.init(identifier: "ko"))
            }
        }
    }

    @ViewBuilder
    private var letterImagesSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("편지 사진")

                Spacer()

                Button {
                    editLetterViewModel.showConfirmationDialog()
                } label: {
                    Image(systemName: "plus")
                }
            }
            if editLetterViewModel.fullPathsAndUrls.isEmpty && editLetterViewModel.newImages.isEmpty {
                Label("사진을 추가해주세요.", systemImage: "photo.on.rectangle")
                    .foregroundStyle(postieColors.dividerColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .frame(alignment: .center)
                    .onTapGesture {
                        editLetterViewModel.showConfirmationDialog()
                    }
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(0..<editLetterViewModel.fullPathsAndUrls.count, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Button {
                                    editLetterViewModel.showLetterImageFullScreenView(index: index)
                                } label: {
                                    if let url = URL(string: editLetterViewModel.fullPathsAndUrls[index].url) {
                                        KFImage(url)
                                            .placeholder {
                                                ProgressView().frame(width: 100, height: 100)
                                            }
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                    }
                                }

                                Button {
                                    let deletedFullPathAndUrl = editLetterViewModel.fullPathsAndUrls[index]
                                    editLetterViewModel.fullPathsAndUrls.remove(at: index)

                                    editLetterViewModel.deleteCandidatesFromFullPathsANdUrls.append(deletedFullPathAndUrl)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(isThemeGroupButton == 4 ? .black : .white, postieColors.tintColor)
                                }
                                .offset(x: 8, y: -8)
                            }
                        }

                        ForEach(0..<editLetterViewModel.newImages.count, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Button {
                                    editLetterViewModel.showLetterImageFullScreenView(index: index + editLetterViewModel.fullPathsAndUrls.count)
                                } label: {
                                    Image(uiImage: editLetterViewModel.newImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }

                                Button {
                                    withAnimation {
                                        editLetterViewModel.removeImage(at: index)
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(isThemeGroupButton == 4 ? .black : .white, postieColors.tintColor)
                                }
                                .offset(x: 8, y: -8)
                            }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 8)
                }
                .scrollIndicators(.never)
            }
        }
    }

    @ViewBuilder
    private var letterTextSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("내용")

            ZStack {
                if editLetterViewModel.text.isEmpty {
                    TextEditor(text: .constant("사진을 등록하면 자동으로 편지 내용이 입력됩니다."))
                        .scrollContentBackground(.hidden)
                        .background(postieColors.receivedLetterColor)
                        .lineSpacing(5)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .frame(maxWidth: .infinity)
                        .frame(height: 350)
                        .disabled(true)
                }

                TextEditor(text: $editLetterViewModel.text)
                    .scrollContentBackground(.hidden)
                    .background(postieColors.receivedLetterColor)
                    .lineSpacing(5)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(.black, lineWidth: 1 / 4)
                            .opacity(0.2)
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 350)
                    .opacity(editLetterViewModel.text.isEmpty ? 0.25 : 1)
                    .focused($focusField, equals: .text)
            }
        }

        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("한 줄 요약")

                Spacer()

                Button {
                    editLetterViewModel.showSummaryConfirmationDialog()
                } label: {
                    Image(systemName: "plus")
                }
            }

            if editLetterViewModel.showingSummaryTextField || !editLetterViewModel.summary.isEmpty {
                TextField("", text: $editLetterViewModel.summary)
                    .padding(6)
                    .background(postieColors.receivedLetterColor)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .focused($focusField, equals: .summary)
                    .padding(.bottom, extraBottomPadding)
                    .id("summaryField")
            } else {
                Label("편지를 요약해드릴게요.", systemImage: "text.quote.rtl")
                    .foregroundStyle(postieColors.dividerColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
                    .frame(alignment: .center)
                    .onTapGesture {
                        editLetterViewModel.showSummaryConfirmationDialog()
                    }
            }
        }
    }
    
    @ViewBuilder
    private var SelectSummaryView: some View {
        ZStack {
            postieColors.backGroundColor
                .ignoresSafeArea()
            
            VStack(spacing : 0) {
                Text("요약 선택")
                    .font(.title)
                    .bold()
                    .foregroundStyle(postieColors.tintColor)
                    .padding()
                    .padding(.top, 5)
                
                ScrollView (showsIndicators: false) {
                    VStack(spacing: 0) {
                        // summaryList에서 하나를 선택할 수 있는 기능
                        ForEach(editLetterViewModel.summaryList.indices, id: \.self) { index in
                            let summary = editLetterViewModel.summaryList[index]

                            Button(action: {
                                editLetterViewModel.selectedSummary = summary
                            }) {
                                Text(summary)
                                    .padding()
                                    .foregroundColor(editLetterViewModel.selectedSummary == summary ? postieColors.tintColor : postieColors.tabBarTintColor)
                                    .fontWeight(editLetterViewModel.selectedSummary == summary ? .bold : .regular)
                                    .frame(maxWidth: .infinity)
                                    .background(postieColors.receivedLetterColor)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button("취소") {
                        editLetterViewModel.closeSelectSummaryView()
                    }
                    .foregroundStyle(postieColors.tabBarTintColor)
                    .padding()
                    
                    Spacer()
                    
                    Button("확인") {
                        editLetterViewModel.summary = editLetterViewModel.selectedSummary
                        editLetterViewModel.showSummaryTextField()
                        editLetterViewModel.closeSelectSummaryView()
                    }
                    .foregroundStyle(editLetterViewModel.selectedSummary.isEmpty ? postieColors.profileColor : postieColors.tintColor)
                    .fontWeight(editLetterViewModel.selectedSummary.isEmpty ? .regular : .bold)
                    .padding()
                    .disabled(editLetterViewModel.selectedSummary.isEmpty) // 선택해야 확인 버튼 활성화
                    
                    Spacer()
                }
            }
        }
    }
}


#Preview {
    EditLetterView(letter: Letter.preview)
}
