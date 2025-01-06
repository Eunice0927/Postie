//
//  SummaryApi.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 2/16/24.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    private init() {}
    private var requestId: String? {
        get { getValueOfPlistFile("SummaryApiKeys", "RequestID")}
    }
    private var apiKey: String? {
        get { getValueOfPlistFile("SummaryApiKeys", "APIKey")}
    }
    private var apiGatewayKey: String? {
        get { getValueOfPlistFile("SummaryApiKeys", "APIGatewayKey")}
    }
    private var apiUrl: String? {
        get { getValueOfPlistFile("SummaryApiKeys", "APIURL")}
    }
    
    func postRequestToAPI(content: String) async throws -> [String] {
        guard let apiGatewayKey = apiGatewayKey else { return [] }
        guard let apiKey = apiKey else { return [] }
        guard let requestId = requestId else { return [] }
        guard let apiEndpoint = apiUrl else { return [] }
        guard let url = URL(string: apiEndpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "X-NCP-CLOVASTUDIO-API-KEY")
        request.addValue(apiGatewayKey, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        request.addValue(requestId, forHTTPHeaderField: "X-NCP-CLOVASTUDIO-REQUEST-ID")
        
        let completionRequest: [String: Any] = [
            "texts": [content],
            "segMinSize": 300,
            "includeAiFilters": true,
            "autoSentenceSplitter": true,
            "segCount": -1
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: completionRequest, options: [])
        } catch {
            throw NSError(domain: "SerializationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize JSON"])
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let status = json["status"] as? [String: Any],
               status["code"] as? String == "20000",
               let result = json["result"] as? [String: Any],
               let text = result["text"] as? String {
                
                // 요약된 문장들에서 '-'만 빼고 배열에 넣음
                let summaryList = text
                    .split(separator: "-")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                return summaryList
            } else {
                throw NSError(domain: "UnexpectedAPIResponse", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unexpected API response format"])
            }
        } catch {
            throw NSError(domain: "JSONParsingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON response"])
        }
    }
}
