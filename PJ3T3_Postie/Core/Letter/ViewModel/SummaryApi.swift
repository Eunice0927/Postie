//
//  SummaryApi.swift
//  PJ3T3_Postie
//
//  Created by 권운기 on 2/16/24.
//

import Foundation

struct APIErrorResponse: Decodable {
    let status: StatusDetail
}

struct StatusDetail: Decodable {
    let code: String
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
    
    func postRequestToAPI(content: String) async throws -> [String] {
        guard let apiGatewayKey = apiGatewayKey,
              let apiKey = apiKey,
              let requestId = requestId,
              let apiEndpoint = apiUrl else { return [] }
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
            throw NSError(
                domain: "SerializationError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to serialize JSON"])
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode != 200 {
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw NSError(
                    domain: "SummaryAPIError123",
                    code: httpResponse.statusCode,
                    userInfo: [
                        NSLocalizedDescriptionKey: httpResponse.statusCode,
                        "errorCode": errorResponse.status.message
                    ]
                )
            } else {
                throw NSError(
                    domain: "SummaryAPIError456",
                    code: httpResponse.statusCode,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unknown server error (statusCode: \(httpResponse.statusCode))"
                    ]
                )
            }
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
                
                print("요약 결과 : \(summaryList)")
                guard !summaryList.isEmpty else {
                    throw NSError(
                        domain: "EmpytSummaryList",
                        code: httpResponse.statusCode,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unknown server error (statusCode: \(httpResponse.statusCode))"
                        ]
                    )
                }
                return summaryList
            } else {
                throw NSError(
                    domain: "UnexpectedAPIResponse",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Unexpected API response format"]
                )
            }
        } catch {
            throw NSError(
                domain: "JSONParsingError",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON response"]
            )
        }
    }
}

func errorMessage(_ code: String, message: String) -> String {
    switch (code, message) {
        case ("400", "E0006"):
            return "유효하지 않은 JSON 형식입니다."
        case ("400", "E0007"):
            return "필수 파라미터가 누락되었습니다."
        case ("400", "E0010"):
            return "지원하지 않는 언어 코드를 사용했습니다."
        case ("400", "E0011"):
            return "텍스트가 너무 길거나 잘못된 형식입니다."
        case ("400", "E0020"):
            return "허용되지 않은 요청 옵션이 포함되어 있습니다."
        case ("400", "E0099"):
            return "알 수 없는 클라이언트 에러가 발생했습니다."
        case ("400", "S4001"):
            return "세션이 만료되었거나 유효하지 않습니다."
        case ("400", "S4002"):
            return "잘못된 인증 토큰이 포함되었습니다."
        case ("403", "S4031"):
            return "접근이 거부되었습니다(Forbidden)."
        case ("404", "S4041"):
            return "요청한 리소스를 찾을 수 없습니다(Not Found)."
        case ("429", "S4290"):
            return "요청 횟수 제한(Too Many Requests)을 초과했습니다."
        case ("500", "C5001"):
            return "서버 내부 처리 중 오류가 발생했습니다."
        case ("500", "C5002"):
            return "AI 모델 연동 중 예기치 못한 오류가 발생했습니다."
        case ("500", "C5005"):
            return "유효하지 않은 내부 모듈 호출입니다."
        case ("500", "C5009"):
            return "기타 서버 내부 오류가 발생했습니다."
        case ("500", "S5001"):
            return "시스템 내부에서 알 수 없는 오류가 발생했습니다."
        case ("503", "S5031"):
            return "서버가 일시적으로 과부하 상태입니다. 잠시 후 다시 시도해 주세요."
        case ("504", "S5040"):
            return "요청 처리 시간 초과(Gateway Timeout)로 인해 응답할 수 없습니다."
        case (_, "S5999"):
            return "알 수 없는 시스템 연동 오류가 발생했습니다."
        case ("40000", "E0000"):
            return "테스트 입니다."
        case ("40004", "E0004"):
            return "빈 텍스트 입니다."
        default:
            return "알 수 없는 에러가 발생했습니다. (statusCode: \(code), errorCode: \(message))"
    }
}
