//
//  AddLetterView.swift
//  PJ3T3_Postie
//
//  Created by KHJ on 1/17/24.
//

import SwiftUI

struct AddLetterView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @StateObject private var addLetterViewModel: AddLetterViewModel
    @ObservedObject var firestoreManager = FirestoreManager.shared
    @ObservedObject var storageManager = StorageManager.shared

    enum Field: Hashable {
        case sender
        case receiver
        case text
        case summary
    }

    var isReceived: Bool
    var autoFilledName: String?

    @State var extraBottomPadding: CGFloat = 0 
    @FocusState private var focusField: Field?
    @Environment(\.dismiss) var dismiss
    @AppStorage("isThemeGroupButton") private var isThemeGroupButton: Int = 0

    init(isReceived: Bool, autoFilledName: String? = nil) {
        self.isReceived = isReceived
        self.autoFilledName = autoFilledName
        self._addLetterViewModel = StateObject(wrappedValue: AddLetterViewModel(isReceived: isReceived))

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
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbarBackground(postieColors.backGroundColor, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    alertManager.showLetterDismissAlert(rightButtonAction: { dismiss() })
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .bold()

                        Text("뒤로")
                    }
                }
            }

            ToolbarItemGroup(placement: .principal) {
                Text(isReceived ? "받은 편지 기록" : "보낸 편지 기록")
                    .bold()
                    .foregroundStyle(postieColors.tintColor)
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    Task {
                        await addLetterViewModel.uploadLetter()
                    }
                } label : {
                    Text("완료")
                }
                .disabled(addLetterViewModel.isLoading)
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
        .modifier(LoadingModifier(isLoading: $addLetterViewModel.isLoading, text: addLetterViewModel.loadingText))
        .onAppear {
            addLetterViewModel.setAlertManager(alertManager: alertManager)
        }
        .fullScreenCover(isPresented: $addLetterViewModel.showingLetterImageFullScreenView) {
            LetterImageFullScreenView(
                images: addLetterViewModel.images,
                pageIndex: $addLetterViewModel.selectedIndex
            )
        }
        .sheet(isPresented: $addLetterViewModel.showingUIImagePicker) {
            UIImagePicker(
                sourceType: addLetterViewModel.imagePickerSourceType,
                alertManager: alertManager,
                selectedImages: $addLetterViewModel.images,
                text: $addLetterViewModel.text,
                isLoading: $addLetterViewModel.isLoading,
                loadingText: $addLetterViewModel.loadingText
            )
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .confirmationDialog("편지 사진 가져오기", isPresented: $addLetterViewModel.showingImageConfirmationDialog, titleVisibility: .visible) {
            Button {
                addLetterViewModel.showUIImagePicker(sourceType: .photoLibrary)
            } label: {
                Label("사진 보관함", systemImage: "photo.on.rectangle")
            }

            Button {
                addLetterViewModel.showUIImagePicker(sourceType: .camera)
            } label: {
                HStack {
                    Text("사진 찍기")

                    Spacer()

                    Image(systemName: "camera")
                }
            }
        }
        .confirmationDialog("편지 요약하기", isPresented: $addLetterViewModel.showingSummaryConfirmationDialog, titleVisibility: .visible) {
            Button("직접 작성") {
                addLetterViewModel.showSummaryTextField()
                focusField = .summary
            }

            Button("AI 완성") {
                Task {
                    await addLetterViewModel.getSummary()
                }
                focusField = .summary
            }
        }
        .sheet(isPresented: $addLetterViewModel.showingSelectSummaryView) {
            SelectSummaryView
                .presentationDetents([.medium])
                .interactiveDismissDisabled(true)
        }
        .customOnChange(addLetterViewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
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

extension AddLetterView {
    @ViewBuilder
    private var letterInfoSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(isReceived ? "보낸 사람" : "받는 사람")

                TextField("",
                          text: isReceived ?
                          $addLetterViewModel.sender : $addLetterViewModel.receiver)
                .padding(6)
                .background(postieColors.receivedLetterColor)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .focused($focusField, equals: .sender)
                .onAppear {
                    if let autoFilledName {
                        if isReceived {
                            addLetterViewModel.sender = autoFilledName
                        } else {
                            addLetterViewModel.receiver = autoFilledName
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text(isReceived ? "받은 날짜" : "보낸 날짜")

                DatePicker(
                    "",
                    selection: $addLetterViewModel.date,
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
                    addLetterViewModel.showConfirmationDialog()
                } label: {
                    Image(systemName: "plus")
                }
            }

            if addLetterViewModel.images.isEmpty {
                Label("사진을 추가해주세요.", systemImage: "photo.on.rectangle")
                    .foregroundStyle(postieColors.dividerColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .frame(alignment: .center)
                    .onTapGesture {
                        addLetterViewModel.showConfirmationDialog()
                    }
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(0..<addLetterViewModel.images.count, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Button {
                                    addLetterViewModel.showLetterImageFullScreenView(index: index)
                                } label: {
                                    Image(uiImage: addLetterViewModel.images[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }

                                Button {
                                    withAnimation {
                                        addLetterViewModel.removeImage(at: index)
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(isThemeGroupButton == 4 ? .black : .white , postieColors.tintColor)
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
                if addLetterViewModel.text.isEmpty {
                    TextEditor(text: .constant("사진을 등록하면 자동으로 편지 내용이 입력됩니다."))
                        .scrollContentBackground(.hidden)
                        .background(postieColors.receivedLetterColor)
                        .lineSpacing(5)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .frame(maxWidth: .infinity)
                        .frame(height: 350)
                        .disabled(true)
                }

                TextEditor(text: $addLetterViewModel.text)
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
                    .opacity(addLetterViewModel.text.isEmpty ? 0.25 : 1)
                    .focused($focusField, equals: .text)
            }
        }

        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("한 줄 요약")

                Spacer()

                Button {
                    addLetterViewModel.showSummaryConfirmationDialog()
                } label: {
                    Image(systemName: "plus")
                }
            }

            if addLetterViewModel.showingSummaryTextField || !addLetterViewModel.summary.isEmpty {
                TextField("", text: $addLetterViewModel.summary)
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
                        addLetterViewModel.showSummaryConfirmationDialog()
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
                        ForEach(addLetterViewModel.summaryList.indices, id: \.self) { index in
                            let summary = addLetterViewModel.summaryList[index]

                            Button(action: {
                                addLetterViewModel.selectedSummary = summary
                            }) {
                                Text(summary)
                                    .padding()
                                    .foregroundColor(addLetterViewModel.selectedSummary == summary ? postieColors.tintColor : postieColors.tabBarTintColor)
                                    .fontWeight(addLetterViewModel.selectedSummary == summary ? .bold : .regular)
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
                        addLetterViewModel.closeSelectSummaryView()
                    }
                    .foregroundStyle(postieColors.tabBarTintColor)
                    .padding()
                    
                    Spacer()
                    
                    Button("확인") {
                        addLetterViewModel.summary = addLetterViewModel.selectedSummary
                        addLetterViewModel.showSummaryTextField()
                        addLetterViewModel.closeSelectSummaryView()
                    }
                    .foregroundStyle(addLetterViewModel.selectedSummary.isEmpty ? postieColors.profileColor : postieColors.tintColor)
                    .fontWeight(addLetterViewModel.selectedSummary.isEmpty ? .regular : .bold)
                    .padding()
                    .disabled(addLetterViewModel.selectedSummary.isEmpty) // 선택해야 확인 버튼 활성화
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddLetterView(isReceived: false)
    }
}

struct LoadingModifier: ViewModifier {
    @Binding var isLoading: Bool
    let text: String

    func body(content: Content) -> some View {
        ZStack {
            if isLoading {
                content
                    .disabled(isLoading)

                LoadingView(text: text)
                    .background(ClearBackground())
            } else {
                content
            }
        }
    }
}
