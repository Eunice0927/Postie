//
//  MapView.swift
//  PJ3T3_Postie
//
//  Created by kwon ji won on 1/17/24.
//

import SwiftUI
import Foundation
import OSLog

import MapKit
import CoreLocation
import NMapsMap

struct MapView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    
    private let name = ["우체국", "우체통"]
    
    @StateObject var naverGeocodeAPI = NaverGeocodeAPI.shared
    @StateObject var officeInfoServiceAPI = OfficeInfoServiceAPI.shared
    @StateObject var locationManager = LocationManager() // 지금 위치를 알기 위한 값
    @StateObject var coordinator: Coordinator = Coordinator.shared
    
    @State private var selectedButtonIndex: Int = 0
    @State private var postLatitude: Double = 37.56
    @State private var postLongitude: Double = 126.98
    @State private var isSideMenuOpen = false
    @State private var isKeyboardVisible = false
    @State private var searchText = ""
    @State private var showResearchButton = false
    @State private var checkMyLocation = false
    @State var overlay = true
    @State var coord: MyCoord = MyCoord(37.579081, 126.974375) //Dafult값 (서울역)
    
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                postieColors.backGroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Postie Map")
                            .font(.custom("SourceSerifPro-Black", size: 40))
                            .foregroundStyle(postieColors.tintColor)
                        
                        Spacer()
                    }
                    .padding(.horizontal) // 옆에 리인 맞춤
                    .padding(.top)
                    
                    HStack(spacing: 10) {
                        ForEach(0...1, id: \.self) { index in
                            Button {
                                selectedButtonIndex = index
                                fetchInCurrentLocation()
                            } label: {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 72, height: 30)
                                        .background(selectedButtonIndex == index ? postieColors.tintColor : postieColors.receivedLetterColor)
                                        .cornerRadius(20)
                                        .shadow(color: Color.postieBlack.opacity(0.1), radius: 3, x: 2, y: 2)
                                    
                                    Text(name[index])
                                        .font(.caption)
                                        .fontWeight(selectedButtonIndex == index ? .bold : .regular)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(selectedButtonIndex == index ? postieColors.receivedLetterColor : postieColors.tabBarTintColor)
                                        .frame(width: 60, alignment: .top)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 5, leading: 15, bottom: 10, trailing: 0))
                    
                    makeSearchBar()
                        .onAppear (perform : UIApplication.shared.hideKeyboard)
                    
                    ZStack(alignment: .top) {
                        NaverMap(coord: coord)
                            .ignoresSafeArea(.all, edges: .top)
                        
                        VStack {
                            Button {
                                Logger.map.info("현재 위치에서 \(name[selectedButtonIndex]) 찾기 버튼 눌림")
                                fetchInCurrentLocation()
                                // coordinator.cameraLocation 값이 바뀌면
                            } label: {
                                if showResearchButton {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: 150, height: 35)
                                            .background(Color.white) //색상
                                            .cornerRadius(16)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.gray, lineWidth: 0.3))
                                        
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                                .frame(height: 10)
                                            Text("현 지도에서 검색")
                                                .font(Font.custom("SF Pro Text", size: 15))
                                        }
                                        .padding()
                                        .foregroundColor(.blue)
                                    }
                                }
                            }
                            Spacer()
                            
                            HStack {
                                Button( action: {
                                    let status = CLLocationManager().authorizationStatus
                                    switch status {
                                    case .notDetermined: break
                                        // 위치 접근 권한을 요청
//                                        locationManager.requestWhenInUseAuthorization()
                                    case .restricted, .denied:
                                        // 위치 접근 권한이 거부됨
                                        // 사용자에게 알림 표시
                                        showLocationAuthAlert()
                                    case .authorizedAlways, .authorizedWhenInUse:
                                        // 위치 권한이 허용됨
                                        locationManager.startUpdatingLocation()
                                        if let coordinate = locationManager.location?.coordinate {
                                            // 현재 위치 업데이트
                                            coordinator.cameraLocation?.lat = coordinate.latitude
                                            coordinator.cameraLocation?.lng = coordinate.longitude
                                            // 지도 업데이트
                                            coordinator.updateMapView(coord: MyCoord(coordinate.latitude + 0.000001, coordinate.longitude + 0.000001), overlay: true)
                                            checkMyLocation = false
                                        }
                                    @unknown default:
                                        break
                                    }

                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .frame(width: 46, height: 46)
                                            .foregroundColor(.white)
                                        
                                        Image(systemName: "dot.scope")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 27, height: 20)
                                            .clipShape(Circle())
                                            .foregroundColor(checkMyLocation ? .blue : .gray)
                                    }
                                }
                                .disabled(!checkMyLocation)
                                
                                Spacer()
                            }
                            .padding(.bottom, 25)
                        }
                        .padding()
                    }
                }
                Spacer()
                
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button {
                        isSearchFocused = false
                        hideKeyboard()
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
            isSearchFocused = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
            isSearchFocused = false
        }
        .onAppear() {
            CLLocationManager().requestWhenInUseAuthorization()
            updateLocation()
        }
        .onChange(of: officeInfoServiceAPI.infos) { newInfos in
            for result in newInfos {
                var lunchtime: String = ""
                if result.lunchTime == "null" {
                    lunchtime = "없음"
                } else {
                    lunchtime = result.lunchTime!
                }
                coordinator.addMarkerAndInfoWindow(latitude: Double(result.postLat)!, longitude: Double(result.postLon)!, caption: result.postNm, time: result.postTime, lunchtime: lunchtime)
            }
        }
        .onChange(of: coordinator.cameraLocation) { result in
            self.showResearchButton = true
            self.checkMyLocation = true
        }
        .onChange(of: locationManager.location) { newLocation in
            //초기 화면이 열리 때 위치값을 불러온다.
            if let location = newLocation {
                coord = MyCoord(location.coordinate.latitude, location.coordinate.longitude)
                Logger.map.info("현재위치: \(coord.lat), \(coord.lng)")
                fetchData()
                locationManager.stopUpdatingLocation()
            }
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
        .zIndex(1)
    }
    
    private func makeSearchBar() -> some View {
        HStack {
            Spacer(minLength: 10)
            
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("장소 검색(서초구, 서초동)", text: $searchText)
                .foregroundColor(.primary)
                .disableAutocorrection(true)
                .onSubmit {
                    naverGeocodeAPI.fetchLocationForPostalCode(searchText) { latitude, longitude in
                        locationManager.stopUpdatingLocation()
                        
                        if let latitude = latitude, let longitude = longitude {
                            //위경도 값 저장
                            coordinator.ButtonUpdateMapView(coord: MyCoord(latitude,longitude))
                            self.coord = MyCoord(latitude, longitude)
                            officeInfoServiceAPI.fetchData(postDivType: selectedButtonIndex + 1, postLatitude: coord.lat, postLongitude: coord.lng)
                            Logger.map.info("위경도 변환 성공\(coord.lat) \(coord.lng)")
                        } else {
                            //알럿창 띄우기
                            Logger.map.error("위치 정보를 가져오는데 실패했습니다.\(coord.lat) \(coord.lng)")
                            alertManager.showOneButtonAlert(
                                title: "검색어 안내",
                                message: "동이나 구 단위로 입력해주세요",
                                buttonLabel: "확인",
                                buttonRole: .cancel
                            )
                        }
                    }
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    self.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            Spacer(minLength: 10)
        }
        .frame(height: 35)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 15)
        .padding(.bottom, 15)
    }
    
    
    //MARK: - functions
    private func updateLocation() {
        // 현재 위치 업데이트
        locationManager.startUpdatingLocation()
        // 처음 들어올 때 coord 업데이트
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let currentLatitude =  coordinator.cameraLocation?.lat ?? coord.lat
            let currentLongitude = coordinator.cameraLocation?.lng ?? coord.lng
            
            coord = MyCoord(currentLatitude, currentLongitude)
        }
    }
    
    private func fetchData() {
        // 데이터 로드
        officeInfoServiceAPI.fetchData(postDivType: selectedButtonIndex + 1, postLatitude: coord.lat, postLongitude: coord.lng)
        coordinator.updateMapView(coord: coord, overlay: true)
    }
    
    private func fetchInCurrentLocation() {
        locationManager.stopUpdatingLocation() // 현재 위치 추적 금지
        
        coord = MyCoord(coordinator.cameraLocation?.lat ?? coord.lat, coordinator.cameraLocation?.lng ?? coord.lng)
        
        coordinator.updateMapView(coord: coord, overlay: false)
        
        officeInfoServiceAPI.fetchData(postDivType: selectedButtonIndex + 1, postLatitude: coord.lat, postLongitude: coord.lng)
        
        // 현 위치에서 검색 버튼 비활성화
        showResearchButton = false
    }
    
    func showLocationAuthAlert() {
        alertManager.showTwoButtonAlert(
            title: "위치 접근 권한이 필요합니다",
            message: "우체국, 우체통 위치를 확인하고 싶다면 권한을 허용해 주세요.",
            leftButtonLabel: "취소", //TODO: 추후 label foreground color 설정 기능 추가
            leftButtonRole: .cancel,
            rightButtonLabel: "설정",
            rightButtonRole: .none) {
                if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSetting)
                }
            }
    }
}

extension UIApplication {
    func hideKeyboard() {
        guard let window = windows.first else { return }
        let tapRecognizer = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self
        window.addGestureRecognizer(tapRecognizer)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
