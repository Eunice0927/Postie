//
//  SlowPostBoxView.swift
//  PJ3T3_Postie
//
//  Created by KHJ on 2024/02/22.
//

import SwiftUI

struct SlowPostBoxView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @StateObject private var slowPostBoxViewModel: SlowPostBoxViewModel
    @ObservedObject var firestoreManager = FirestoreManager.shared
    @ObservedObject var storageManager = StorageManager.shared

    enum Field: Hashable {
        case sender
        case receiver
        case text
        case summary
    }

    var isReceived: Bool

    @FocusState private var focusField: Field?
    @Environment(\.dismiss) var dismiss
    @AppStorage("isThemeGroupButton") private var isThemeGroupButton: Int = 0

    init(isReceived: Bool) {
        self._slowPostBoxViewModel = StateObject(wrappedValue: SlowPostBoxViewModel(isReceived: isReceived))
        self.isReceived = isReceived

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
            ThemeManager.themeColors[isThemeGroupButton].backGroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    letterInfoSection

                    letterImagesSection

                    letterTextSection
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbarBackground(ThemeManager.themeColors[isThemeGroupButton].backGroundColor, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    alertManager.showTwoButtonAlert(
                        title: "작성을 취소하실 건가요?",
                        message: "변경된 내용이 저장되지 않아요!",
                        leftButtonLabel: "아니요",
                        leftButtonRole: .cancel,
                        rightButtonLabel: "네",
                        rightButtonRole: .destructive,
                        rightButtonAction: { dismiss() }
                    )
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .bold()

                        Text("Back")
                    }
                }
            }

            ToolbarItemGroup(placement: .principal) {
                Text("느린우체통")
                    .bold()
                    .foregroundStyle(ThemeManager.themeColors[isThemeGroupButton].tintColor)
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    Task {
                        await slowPostBoxViewModel.uploadLetter()
                    }
                } label : {
                    Text("완료")
                }
                .disabled(slowPostBoxViewModel.isLoading)
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
        .modifier(LoadingModifier(isLoading: $slowPostBoxViewModel.isLoading, text: slowPostBoxViewModel.loadingText))
        .onAppear {
            slowPostBoxViewModel.setAlertManager(alertManager: alertManager)
        }
        .fullScreenCover(isPresented: $slowPostBoxViewModel.showingLetterImageFullScreenView) {
            LetterImageFullScreenView(
                images: slowPostBoxViewModel.images,
                pageIndex: $slowPostBoxViewModel.selectedIndex
            )
        }
        .sheet(isPresented: $slowPostBoxViewModel.showingUIImagePicker) {
            UIImagePicker(
                sourceType: slowPostBoxViewModel.imagePickerSourceType,
                alertManager: alertManager,
                selectedImages: $slowPostBoxViewModel.images,
                text: $slowPostBoxViewModel.text,
                isLoading: $slowPostBoxViewModel.isLoading,
                loadingText: $slowPostBoxViewModel.loadingText
            )
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .confirmationDialog("편지 사진 가져오기", isPresented: $slowPostBoxViewModel.showingImageConfirmationDialog, titleVisibility: .visible) {
            Button {
                slowPostBoxViewModel.showUIImagePicker(sourceType: .photoLibrary)
            } label: {
                Label("사진 보관함", systemImage: "photo.on.rectangle")
            }

            Button {
                slowPostBoxViewModel.showUIImagePicker(sourceType: .camera)
            } label: {
                HStack {
                    Text("사진 찍기")

                    Spacer()

                    Image(systemName: "camera")
                }
            }
        }
        .confirmationDialog("편지 요약하기", isPresented: $slowPostBoxViewModel.showingSummaryConfirmationDialog, titleVisibility: .visible) {
            Button("직접 작성") {
                slowPostBoxViewModel.showSummaryTextField()
                focusField = .summary
            }

            Button("AI 완성") {
                Task {
                    await slowPostBoxViewModel.getSummary()
                }
                focusField = .summary
            }
        }
        .sheet(isPresented: $slowPostBoxViewModel.showingSelectSummaryView) {
            SelectSummaryView
                .presentationDetents([.medium])
                .interactiveDismissDisabled(true)
        }
        .customOnChange(slowPostBoxViewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
}

// MARK: - Computed Views

extension SlowPostBoxView {
    @ViewBuilder
    private var letterInfoSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(isReceived ? "보낸 사람" : "받는 사람")

                TextField("",
                          text: .constant(slowPostBoxViewModel.currentUserName)
                )
                .padding(6)
                .background(ThemeManager.themeColors[isThemeGroupButton].receivedLetterColor)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .focused($focusField, equals: .sender)
                .disabled(true)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text("받을 날짜")

                DatePicker(
                    "",
                    selection: $slowPostBoxViewModel.date,
                    in: Calendar.current.date(byAdding: .day, value: 1, to: Date())!...,
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
                    slowPostBoxViewModel.showConfirmationDialog()
                } label: {
                    Image(systemName: "plus")
                }
            }

            if slowPostBoxViewModel.images.isEmpty {
                Label("사진을 추가해주세요.", systemImage: "photo.on.rectangle")
                    .foregroundStyle(ThemeManager.themeColors[isThemeGroupButton].dividerColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .frame(alignment: .center)
                    .onTapGesture {
                        slowPostBoxViewModel.showConfirmationDialog()
                    }
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(0..<slowPostBoxViewModel.images.count, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Button {
                                    slowPostBoxViewModel.showLetterImageFullScreenView(index: index)
                                } label: {
                                    Image(uiImage: slowPostBoxViewModel.images[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }

                                Button {
                                    withAnimation {
                                        slowPostBoxViewModel.removeImage(at: index)
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, ThemeManager.themeColors[isThemeGroupButton].tintColor)
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
                if slowPostBoxViewModel.text.isEmpty {
                    TextEditor(text: .constant("사진을 등록하면 자동으로 편지 내용이 입력됩니다."))
                        .scrollContentBackground(.hidden)
                        .background(ThemeManager.themeColors[isThemeGroupButton].receivedLetterColor)
                        .lineSpacing(5)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .frame(maxWidth: .infinity)
                        .frame(height: 350)
                        .disabled(true)
                }

                TextEditor(text: $slowPostBoxViewModel.text)
                    .scrollContentBackground(.hidden)
                    .background(ThemeManager.themeColors[isThemeGroupButton].receivedLetterColor)
                    .lineSpacing(5)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(.black, lineWidth: 1 / 4)
                            .opacity(0.2)
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 350)
                    .opacity(slowPostBoxViewModel.text.isEmpty ? 0.25 : 1)
                    .focused($focusField, equals: .text)
            }
        }

        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("한 줄 요약")

                Spacer()

                Button {
                    slowPostBoxViewModel.showSummaryConfirmationDialog()
                } label: {
                    Image(systemName: "plus")
                }
            }

            if slowPostBoxViewModel.showingSummaryTextField || !slowPostBoxViewModel.summary.isEmpty {
                TextField("", text: $slowPostBoxViewModel.summary)
                    .padding(6)
                    .background(ThemeManager.themeColors[isThemeGroupButton].receivedLetterColor)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .focused($focusField, equals: .summary)
            } else {
                Label("편지를 요약해드릴게요.", systemImage: "text.quote.rtl")
                    .foregroundStyle(ThemeManager.themeColors[isThemeGroupButton].dividerColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
                    .frame(alignment: .center)
                    .onTapGesture {
                        slowPostBoxViewModel.showSummaryConfirmationDialog()
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
                        ForEach(slowPostBoxViewModel.summaryList.indices, id: \.self) { index in
                            let summary = slowPostBoxViewModel.summaryList[index]

                            Button(action: {
                                slowPostBoxViewModel.selectedSummary = summary
                            }) {
                                Text(summary)
                                    .padding()
                                    .foregroundColor(slowPostBoxViewModel.selectedSummary == summary ? postieColors.tintColor : postieColors.tabBarTintColor)
                                    .fontWeight(slowPostBoxViewModel.selectedSummary == summary ? .bold : .regular)
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
                        slowPostBoxViewModel.closeSelectSummaryView()
                    }
                    .foregroundStyle(postieColors.tabBarTintColor)
                    .padding()
                    
                    Spacer()
                    
                    Button("확인") {
                        slowPostBoxViewModel.summary = slowPostBoxViewModel.selectedSummary
                        slowPostBoxViewModel.showSummaryTextField()
                        slowPostBoxViewModel.closeSelectSummaryView()
                    }
                    .foregroundStyle(slowPostBoxViewModel.selectedSummary.isEmpty ? postieColors.profileColor : postieColors.tintColor)
                    .fontWeight(slowPostBoxViewModel.selectedSummary.isEmpty ? .regular : .bold)
                    .padding()
                    .disabled(slowPostBoxViewModel.selectedSummary.isEmpty) // 선택해야 확인 버튼 활성화
                    
                    Spacer()
                }
            }
        }
    }
}


#Preview {
    SlowPostBoxView(isReceived: false)
}
