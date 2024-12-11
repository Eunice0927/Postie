//
//  ThemeView.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 1/30/24.
//

import SwiftUI

struct ThemeView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("selectedLayoutMode") private var selectedLayoutMode: Int = 0
    @AppStorage("isSplitLayout") private var isSplitLayout: Bool = true
    @AppStorage("isThemeGroupButton") private var isThemeGroupButton: Int = 0
    @StateObject private var viewModel = ThemeViewModel()
    
    @Binding var currentColorPage: Int
    @Binding var isTabGroupButton: Bool
    @Binding var currentGroupPage: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                postieColors.backGroundColor
                    .ignoresSafeArea()
                
                let columns = Array(repeating: GridItem(.flexible()), count: viewModel.numberOfColumns)
                
                VStack {
                    HStack(spacing: 10) {
                        ForEach(0...1, id: \.self) { index in
                            Button(action: {
                                viewModel.selectedThemeButton = index
                            }) {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 72, height: 30)
                                        .background(viewModel.selectedThemeButton == index ? postieColors.tintColor : postieColors.receivedLetterColor)
                                        .cornerRadius(20)
                                        .shadow(color: Color.postieBlack.opacity(0.1), radius: 3, x: 2, y: 2)
                                    
                                    Text(viewModel.names[index])
                                        .font(.caption)
                                        .fontWeight(viewModel.selectedThemeButton == index ? .bold : .regular)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(viewModel.selectedThemeButton == index ? postieColors.receivedLetterColor : postieColors.tabBarTintColor)
                                        .frame(width: 60, alignment: .top)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        if viewModel.selectedThemeButton == 0 {
                            Menu {
                                Button(action: {
                                    selectedLayoutMode = 0
                                }) {
                                    HStack {
                                        Text("스플릿")
                                        
                                        Image(systemName: selectedLayoutMode == 0 ? "checkmark" : "")
                                    }
                                }
                                
                                Button(action: {
                                    selectedLayoutMode = 1
                                }) {
                                    HStack {
                                        Text("그리드")
                                        
                                        Image(systemName: selectedLayoutMode == 1 ? "checkmark" : "")
                                    }
                                }
                                
                                Button(action: {
                                    selectedLayoutMode = 2
                                }) {
                                    HStack {
                                        Text("리스트")
                                        
                                        Image(systemName: selectedLayoutMode == 2 ? "checkmark" : "")
                                    }
                                }
                            } label: {
                                Label {
                                    Image(systemName: "chevron.down")
                                } icon: {
                                    switch selectedLayoutMode {
                                        
                                    case 0:
                                        Image(systemName: "square.split.2x1")
                                        
                                    case 1:
                                        Image(systemName: "square.grid.2x2")
                                        
                                    default:
                                        Image(systemName: "list.bullet")
                                    }
                                }
                            }
                        } else {
                            Menu {
                                Button(action: {
                                    isSplitLayout = true
                                }) {
                                    HStack {
                                        Text("스플릿")
                                        
                                        Image(systemName: isSplitLayout ? "checkmark" : "")
                                    }
                                }
                                
                                Button(action: {
                                    isSplitLayout = false
                                }) {
                                    HStack {
                                        Text("리스트")
                                        
                                        Image(systemName: !isSplitLayout ? "checkmark" : "")
                                    }
                                }
                            } label: {
                                Label {
                                    Image(systemName: "chevron.down")
                                } icon: {
                                    Image(systemName: isSplitLayout ? "square.split.2x1" : "list.bullet")
                                }
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    if viewModel.selectedThemeButton == 0 {
                        if selectedLayoutMode == 0 {
                            TabView(selection: $currentColorPage) {
                                ForEach(Array(zip(viewModel.items.indices, viewModel.items)), id: \.0) { index, item in
                                    Button (action: {
                                        isThemeGroupButton = index
                                        currentColorPage = isThemeGroupButton
                                        ThemeManager.shared.updateTheme(index: index)
                                    }) {
                                        VStack {
                                            HStack {
                                                Text(item)
                                                
                                                Image(systemName: isThemeGroupButton == index ? "checkmark.circle.fill" : "circle")
                                                    .foregroundStyle(isThemeGroupButton == index ? postieColors.tintColor : postieColors.tabBarTintColor)
                                            }
                                            
                                            Image(isTabGroupButton ? viewModel.groupImages[index] : viewModel.listImages[index])
                                                .resizable()
                                                .modifier(CustomImageModifier(height: geometry.size.height))
                                                .border(isThemeGroupButton == index ? postieColors.tintColor : postieColors.tintColor.opacity(0))
                                            
                                            Spacer()
                                        }
                                    }
                                    .tag(index)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                            .customOnChange(isThemeGroupButton) { newValue in
                                saveToUserDefaults(value: newValue, key: "IsThemeGroupButton")
                            }
                        } else if selectedLayoutMode == 1 {
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 10) {
                                    ForEach(Array(zip(viewModel.items.indices, viewModel.items)), id: \.0) { index, item in
                                        Button (action: {
                                            isThemeGroupButton = index
                                            ThemeManager.shared.updateTheme(index: index)
                                        }) {
                                            VStack {
                                                Image(isTabGroupButton ? viewModel.groupImages[index] : viewModel.listImages[index])
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 200)
                                                    .border(isThemeGroupButton == index ? postieColors.tintColor : postieColors.tintColor.opacity(0))
                                                    .padding()
                                                
                                                Text(item)
                                                    .padding(.bottom)
                                                
                                                Image(systemName: isThemeGroupButton == index ? "checkmark.circle.fill" : "circle")
                                                    .foregroundStyle(isThemeGroupButton == index ? postieColors.tintColor : postieColors.tabBarTintColor)
                                                    .font(.title2)
                                            }
                                            .frame(height: 300)
                                        }
                                    }
                                }
                                .padding()
                            }
                        } else {
                            ScrollView {
                                ForEach(Array(zip(viewModel.items.indices, viewModel.items)), id: \.0) { index, item in
                                    Button (action: {
                                        isThemeGroupButton = index
                                        ThemeManager.shared.updateTheme(index: index)
                                    }) {
                                        VStack {
                                            HStack {
                                                Image(isTabGroupButton ? viewModel.groupImages[index] : viewModel.listImages[index])
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 70)
                                                
                                                Text(item)
                                                
                                                Spacer()
                                                
                                                Image(systemName: isThemeGroupButton == index ? "checkmark.circle.fill" : "circle")
                                                    .foregroundStyle(isThemeGroupButton == index ? postieColors.tintColor : postieColors.tabBarTintColor)
                                                    .font(.title2)
                                            }
                                            
                                            DividerView()
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    } else {
                        if isSplitLayout {
                            TabView(selection: $currentGroupPage) {
                                Button(action: {
                                    currentGroupPage = 0
                                    isTabGroupButton = true
                                }) {
                                    VStack {
                                        HStack {
                                            Text("편지 그룹")
                                            
                                            Image(systemName: isTabGroupButton ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(isTabGroupButton ? postieColors.tintColor : postieColors.tabBarTintColor)
                                        }
                                        
                                        Image("postieGroup\(viewModel.stringFromNumber(isThemeGroupButton))")
                                            .resizable()
                                            .modifier(CustomImageModifier(height: geometry.size.height))
                                            .border(isTabGroupButton ? postieColors.tintColor : postieColors.tintColor.opacity(0))
                                        
                                        Spacer()
                                    }
                                }
                                .tag(0)
                                
                                Button(action: {
                                    currentGroupPage = 1
                                    isTabGroupButton = false
                                }) {
                                    VStack {
                                        HStack {
                                            Text("편지 리스트")
                                            
                                            Image(systemName: !isTabGroupButton ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(!isTabGroupButton ? postieColors.tintColor : postieColors.tabBarTintColor)
                                        }
                                        
                                        Image("postieList\(viewModel.stringFromNumber(isThemeGroupButton))")
                                            .resizable()
                                            .modifier(CustomImageModifier(height: geometry.size.height))
                                            .border(isTabGroupButton ? postieColors.tintColor.opacity(0) : postieColors.tintColor)
                                        
                                        Spacer()
                                    }
                                }
                                .tag(1)
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                            .customOnChange(isTabGroupButton) { newValue in
                                saveToUserDefaults(value: newValue, key: "IsTabGroupButton")
                            }
                        } else {
                            ScrollView {
                                VStack {
                                    Button (action: {
                                        isTabGroupButton = true
                                    }) {
                                        HStack {
                                            Image("postieGroup\(viewModel.stringFromNumber(isThemeGroupButton))")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 70)
                                            
                                            Text("편지 그룹")
                                            
                                            Spacer()
                                            
                                            Image(systemName: isTabGroupButton ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(isTabGroupButton ? postieColors.tintColor : postieColors.tabBarTintColor)
                                                .font(.title2)
                                        }
                                    }
                                    
                                    DividerView()
                                    
                                    Button (action: {
                                        isTabGroupButton = false
                                    }) {
                                        HStack {
                                            Image("postieList\(viewModel.stringFromNumber(isThemeGroupButton))")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 70)
                                            
                                            Text("편지 리스트")
                                            
                                            Spacer()
                                            
                                            Image(systemName: !isTabGroupButton ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(!isTabGroupButton ? postieColors.tintColor : postieColors.tabBarTintColor)
                                                .font(.title2)
                                        }
                                    }
                                    
                                    DividerView()
                                }
                                .padding()
                            }
                            
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    Text("테마 설정")
                        .bold()
                        .foregroundStyle(postieColors.tintColor)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .tint(postieColors.tabBarTintColor)
        }
    }
}

struct CustomImageModifier: ViewModifier {
    var height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .frame(height: height < 650 ? height * 0.7 : height * 0.75)
            .shadow(color: Color.postieBlack.opacity(0.1), radius: 3)
    }
}

func saveToUserDefaults<T>(value: T, key: String) {
    UserDefaults.standard.set(value, forKey: key)
}

//#Preview {
//    ThemeView()
//}
