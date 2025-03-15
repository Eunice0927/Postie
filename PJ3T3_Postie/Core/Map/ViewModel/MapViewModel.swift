//
//  MapViewModel.swift
//  PJ3T3_Postie
//
//  Created by Eunsu JEONG on 3/15/25.
//

import Foundation
import OSLog

import XMLCoder

final class MapViewModel: ObservableObject {
    
    @Published var infos = [PostItem]()
    
    private var apiKey: String? {
        get { Utils.getValueOfPlistFile("MapApiKeys", "OFFICE_MAIN_KEY")}
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
}
