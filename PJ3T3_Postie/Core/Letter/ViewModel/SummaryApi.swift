//
//  SummaryApi.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 2/16/24.
//

import Foundation

struct RequestBody: Codable {
    let document: DocumentObject
    let option: OptionObject
}

struct DocumentObject: Codable {
    let title: String?
    let content: String
}

struct OptionObject: Codable {
    let texts: String
    let segMinSize: Int
    let includeAiFilters: Bool
    let autoSentenceSplitter: Bool
    let segCount: Int
}

struct ApiResponse: Codable {
    let summary: String
}

struct APIErrorResponse: Codable {
    let status: Int
    let error: ErrorDetail
}

struct ErrorDetail: Codable {
    let errorCode: String
    let message: String
}

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
    
    func postRequestToAPI(title: String, content: String) async throws -> String {
        guard let apiGatewayKey = apiGatewayKey else { return "" }
        guard let apiKey = apiKey else { return "" }
        guard let requestId = requestId else { return "" }
        guard let apiEndpoint = apiUrl else { return "" }
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
                
                // 문단을 랜덤으로 한개만 선택
                let paragraphs = text.split(separator: "-").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                if let randomParagraph = paragraphs.randomElement() {
                    return randomParagraph
                } else {
                    throw NSError(domain: "NoParagraphsError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No paragraphs found in the summary"])
                }
            } else {
                throw NSError(domain: "UnexpectedAPIResponse", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unexpected API response format"])
            }
        } catch {
            throw NSError(domain: "JSONParsingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON response"])
        }
    }
}

func errorMessage(_ statusCode: Int, errorCode: String) -> String {
    switch (statusCode, errorCode) {
    case (400, "E001"):
        return "빈 문자열 or blank 문자"
    case (400, "E002"):
        return "UTF-8 인코딩 에러"
    case (400, "E003"):
        return "문장이 기준치보다 초과했을 경우"
    case (400, "E100"):
        return "유효한 문장이 부족한 경우"
    case (400, "E101"):
        return "ko, ja 가 아닌 경우"
    case (400, "E102"):
        return "general, news 가 아닌 경우"
    case (400, "E103"):
        return "request body의 json format이 유효하지 않거나 필수 파라미터가 누락된 경우"
    case (400, "E415"):
        return "content-type 에러"
    case (400, "E900"):
        return "예외처리가 안된 경우(Bad Request)"
    case (500, "E501"):
        return "엔드포인트 연결 실패"
    case (500, "E900"):
        return "예외처리가 안된 오류(Server Error)"
    default:
        return "알 수 없는 에러"
    }
}
