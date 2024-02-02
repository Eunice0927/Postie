//
//  Coordinator.swift
//  PJ3T3_Postie
//
//  Created by kwon ji won on 1/23/24.
//

import SwiftUI
import UIKit
import CoreLocation

import NMapsMap

// - NMFMapViewCameraDelegate 카메라 이동에 필요한 델리게이트,
// - NMFMapViewTouchDelegate 맵 터치할 때 필요한 델리게이트,
// - CLLocationManagerDelegate 위치 관련해서 필요한 델리게이트

class Coordinator: NSObject, ObservableObject, NMFMapViewCameraDelegate {
    
    static let shared = Coordinator()
    
    //    let startInfoWindow = NMFInfoWindow()
    let view = NMFNaverMapView(frame: .zero) // 지도 객체 생성
//    let locationManager = CLLocationManager()
    
    var markers: [NMFMarker] = []
    var coord: MyCoord = MyCoord(0.0,0.0) // 내 위치값 초기 설정

    @Published var currentLocation: CLLocation?
    @Published var isUpdatingLocation: Bool = false
    
    override init() {
        super.init()
        
        view.mapView.positionMode = .disabled
        
        view.mapView.zoomLevel = 15 // 기본 맵이 표시될때 줌 레벨
        view.mapView.minZoomLevel = 10 // 최소 줌 레벨
        view.mapView.maxZoomLevel = 17 // 최대 줌 레벨
        
        view.showLocationButton = true // 현위치 버튼: 위치 추적 모드를 표현합니다. 탭하면 모드가 변경됩니다.
        view.showZoomControls = true // 줌 버튼: 탭하면 지도의 줌 레벨을 1씩 증가 또는 감소합니다.
        view.showCompass = true //  나침반 : 카메라의 회전 및 틸트 상태를 표현합니다. 탭하면 카메라의 헤딩과 틸트가 0으로 초기화됩니다. 헤딩과 틸트가 0이 되면 자동으로 사라집니다
        view.showScaleBar = true // 스케일 바 : 지도의 축척을 표현합니다. 지도를 조작하는 기능은 없습니다.
        
        view.mapView.addCameraDelegate(delegate: self)
//        view.mapView.touchDelegate = self
        
//         내 위치 확인
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        
//        getCurrentLocation()
        
       
    }
    
    func getNaverMapView() -> NMFNaverMapView {
        view
    }
    
    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
        // 카메라 이동이 시작되기 전 호출되는 함수
    }
    
    func mapView(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
        // 현재 지도 중심 좌표 가져오기
        let center = mapView.cameraPosition.target
        
        print("change position")
        // 카메라의 위치가 변경되면 호출되는 함수
    }
    
    
    
    // 맵을 업데이트 -> 해당 위치에서 우체국 찾기 때 사용 예정
    func updateMapView(coord: MyCoord) {
//        self.coord = coord

        // NMGLatLng: 하나의 위경도 좌표를 나타내는 클래스
        // https://navermaps.github.io/ios-map-sdk/guide-ko/2-2.html
        let coord = NMGLatLng(lat: coord.lat, lng: coord.lng)
        
        print(currentLocation ?? "못찾음")
        moveCamera(coord: coord) //카메라 바로 이동
        
        // 마커와 정보 창을 새롭게 추가하기 위해 기존 내용을 삭제
        removeAllMakers()
        
        // 위치 오버레이
        setLocationOverlay(coord: coord)

        // 정보창과 연결된 마커를 추가
//        addMarkerAndInfoWindow(coord: coord,
//                               caption: self.coord.name,
//                               infoTitle: "정보 창 내용/마커를 탭하면 닫힘")
    }
    
    func setLocationOverlay(coord: NMGLatLng) {
        let locationOverlay = view.mapView.locationOverlay
        locationOverlay.hidden = false
        locationOverlay.location = coord
    }
    
    // 카메라를 옮기는 기능
    func moveCamera(coord: NMGLatLng, animation: NMFCameraUpdateAnimation = .none, duration: TimeInterval = 1) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
        cameraUpdate.animation = animation
        cameraUpdate.animationDuration = duration
        view.mapView.moveCamera(cameraUpdate)
    }
    
    // 카메라 위치 이동
    func moveCameraLocation(latitude: Double, longitude: Double) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude), zoomTo: 15)
        view.mapView.moveCamera(cameraUpdate)
    }
    
    // 현재 위치 전달
//    func getCurrentLocation() {
//        // https://developer.apple.com/documentation/corelocation/cllocationmanager/1620548-requestlocation
//        locationManager.requestLocation()
//        currentLocation = locationManager.location
////        print(currentLocation)
//    }

    
    // 마커 찍는 행위
    func addMarkerAndInfoWindow(latitude: Double, longitude: Double, caption: String) {
        let marker = NMFMarker()
        
        marker.captionText = caption
        marker.position = NMGLatLng(lat: latitude, lng: longitude)
        marker.mapView = view.mapView
        markers.append(marker)
        
        //        let infoWindow = NMFInfoWindow()
        //        let dataSource = NMFInfoWindowDefaultTextSource.data()
        //        //시간 설정, 나중에 구현 예정
        //        dataSource.title = time
        //        infoWindow.dataSource = dataSource
    }
    
    // 기존 마커 삭제
    func removeAllMakers() {
        markers.forEach { marker in
            marker.mapView = nil
        }
        markers.removeAll()
    }
}

