//
//  MapApi.swift
//  PJ3T3_Postie
//
//  Created by kwon ji won on 1/17/24.
//

import Foundation
import SwiftUI
import OSLog

import CoreLocation
import NMapsMap
import XMLCoder

func getValueOfPlistFile(_ plistFilename: String, _ key: String) -> String? {
    // 생성한 .plist 파일 경로 불러오기
    guard let filePath = Bundle.main.path(forResource: plistFilename, ofType: "plist") else {
        fatalError("Couldn't find file '\(plistFilename).plist'")
    }
    
    // .plist 파일 내용을 딕셔너리로 받아오기
    let plist = NSDictionary(contentsOfFile: filePath)
    
    // 딕셔너리에서 키 찾기
    guard let value = plist?.object(forKey: key) as? String else {
        fatalError("Couldn't find key '\(key)'")
    }
    
    return value
}

//NaverMap Geocode해주는 API
class NaverGeocodeAPI: ObservableObject {
    
    static let shared = NaverGeocodeAPI()
    private init() { }
    
    @Published var targetLocation: (latitude: String, longitude: String)?
    
    private var clientID: String? {
        get { getValueOfPlistFile("MapApiKeys", "NAVER_GEOCODE_ID") }
    }
    
    private var clinetSecret: String? {
        get { getValueOfPlistFile("MapApiKeys", "NAVER_GEOCODE_SECRET") }
    }
    
    func fetchLocationForPostalCode(_ postalCode: String,  completion: @escaping (Double?, Double?) -> Void) {
        guard let clientID = clientID else { return }
        guard let clinetSecret = clinetSecret else { return }
        
        let urlString = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=\(postalCode)?"

        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession(configuration: .default)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(clientID, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.setValue(clinetSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                Logger.map.error("\(error.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                Logger.map.error("error!!!")
                // 정상적으로 값이 오지 않았을 때 처리
                //여기서 오류가 남
                return
            }
            
            guard let data = data else {
                Logger.map.error("No data received")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                Logger.map.error("API응답: \(jsonString)")
            }
            
            //API응답시 파싱하기
            do {
                //geocodeResult 코더블
                let geocodeResult = try JSONDecoder().decode(GeocodeResponse.self, from: data)
                //바뀌어야 하는 부분, 여기서 x,y를 불러와도 된다
                
                if let firstAddress = geocodeResult.addresses.first {
                    let latitude = Double(firstAddress.y)!
                    let longitude = Double(firstAddress.x)!
                    
                    //메인 스레드에서 UI를 업데이트 한다.
                    DispatchQueue.main.async {
                        completion(latitude,longitude)
                    }
                } else {
                    Logger.map.error("값이 없읍니다")
                    DispatchQueue.main.async {
                        completion(nil,nil)
                    }
                }
                
            }
            catch {
                Logger.map.error("JSON 디코딩 에러: \(error.localizedDescription)")
            }
        }   
        task.resume()
    }
}

class OfficeInfoServiceAPI: ObservableObject {
    static let shared = OfficeInfoServiceAPI()
    
    @StateObject var coordinator: Coordinator = Coordinator.shared
    
    @Published var infos = [PostItem]()
    
    private var apiKey: String? {
        get { getValueOfPlistFile("MapApiKeys", "OFFICE_MAIN_KEY")}
    }
    
    func fetchData(postDivType: Int, postLatitude: Double, postLongitude: Double) {
        guard let apiKey = apiKey else { return }
        
        //postDivType 데이터 대상 null=전체대상, 1=우체국, 2=우체통
        //postGap 반경 코드 1km = 1, 0.5km = 0.5
        let urlString = "https://www.koreapost.go.kr/koreapost/openapi/searchPostScopeList.do?serviceKey=\(apiKey)&postLatitude=\(postLatitude)&postLongitude=\(postLongitude)&postGap=1&postDivType=\(postDivType)&pageCount=20"
        Logger.map.info("\(urlString)")

        //URL주소로 받아와 지면 값을 url로 저장해라
        //url설정 부터 str까진 공통 작업
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                Logger.map.error("\(error.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { return }
            
            guard let data = data else {
                Logger.map.error("No data received")
                return
            }
            
            let str = String(decoding: data, as: UTF8.self)

            do {
                let postListResponse = try XMLDecoder().decode(PostListResponse.self, from: data)
                DispatchQueue.main.async {
                    self.infos = postListResponse.postItems
                }
            } catch {
                Logger.map.error("\(error)")
            }
        }
        task.resume()
    }
    
    private init() {}
}
