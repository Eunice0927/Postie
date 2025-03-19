//
//  LetterImageFullScreenView.swift
//  PJ3T3_Postie
//
//  Created by KHJ on 2024/01/17.
//

import OSLog
import SwiftUI
import Kingfisher

struct LetterImageFullScreenView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @StateObject private var letterImageFullScreenViewModel = LetterImageFullScreenViewModel()
    @Binding var pageIndex: Int
    @Environment(\.dismiss) var dismiss
    
    let images: [UIImage]?
    let urls: [String]?
    let imageFullPaths: [String]?
    let isFromLetterDetail: Bool

    var urlsCount: Int {
        guard let urls = urls else { return 0 }
        return urls.count
    }
    
    init(images: [UIImage]? = nil, urls: [String]? = nil, imageFullPaths: [String]? = nil, pageIndex: Binding<Int>, isFromLetterDetail: Bool) {
        self.images = images
        self.urls = urls
        self.imageFullPaths = imageFullPaths
        self._pageIndex = pageIndex
        self.isFromLetterDetail = isFromLetterDetail
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                TabView(selection: $pageIndex) {
                    if let urls = urls {
                        ForEach(0..<urls.count, id: \.self) { index in
                            if let url = URL(string: urls[index]) {
                                KFImage(url)
                                    .placeholder {
                                        ProgressView()
                                    }
                                    .resizable()
                                    .scaledToFit()
                                    .tag(index)
                            }
                        }
                    }

                    if let images = images {
                        ForEach(0..<images.count, id: \.self) { index in
                            Image(uiImage: images[index])
                                .resizable()
                                .scaledToFit()
                                .tag(urlsCount + index)
                        }
                    }

                }
                .tabViewStyle(.page)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.postieWhite)
                        }
                    }
                    
                    if isFromLetterDetail {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                letterImageFullScreenViewModel.showDownloadAlert()
                            } label: {
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundStyle(.postieWhite)
                            }
                        }
                    }
                }
                .modifier(SwipeToDismissModifier(onDismiss: {
                    dismiss()
                }))
                
                if letterImageFullScreenViewModel.isDownloading {
                    LoadingView(text: "사진 다운 중").background(ClearBackground())
                }
            }
            .alert("이 사진을 저장 할까요?", isPresented: $letterImageFullScreenViewModel.showingDownloadAlert) {
                Button {
                    dismiss()
                } label: {
                    Text("취소")
                }
                
                Button {
                    Task {
                        guard let fullPaths = imageFullPaths, pageIndex < fullPaths.count else {
                            Logger.firebase.info("사진 경로를 찾을 수 없습니다.")
                            return
                        }
                        await letterImageFullScreenViewModel.downloadAndSaveImage(fullPath: fullPaths[pageIndex])
                    }
                } label: {
                    Text("확인")
                }
            } message: {
                Text("사진 용량에 따라 시간이 오래 걸릴 수 있어요!")
            }
        }
    }
}

struct SwipeToDismissModifier: ViewModifier {
    var onDismiss: () -> Void
    @State private var offset: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .offset(y: offset.height)
            .animation(.interactiveSpring(), value: offset)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 50 {
                            offset = gesture.translation
                        }
                    }
                    .onEnded { _ in
                        if abs(offset.height) > 100 {
                            onDismiss()
                        } else {
                            offset = .zero
                        }
                    }
            )
    }
}

//#Preview {
//    LetterImageFullScreenView(images: [UIImage(systemName: "heart")!], urls: nil, pageIndex: .constant(0))
//}
