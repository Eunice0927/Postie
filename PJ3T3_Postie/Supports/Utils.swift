//
//  Utils.swift
//  PJ3T3_Postie
//
//  Created by Eunsu JEONG on 12/8/24.
//

import Foundation
import FirebaseAnalytics

public class Utils {
    
    public static func log(_ msg: Any?, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = file.split(separator: "/").last ?? ""
        let funcName = function.split(separator: "(").first ?? ""
        let date = getDateStr(date: Date(), format: "yyyy-MM-dd hh:mm:ss")
        print("[\(date)] [\(fileName)] \(funcName)(\(line)): \(msg ?? "")")
        #endif
    }
    
    public static func getDateStr(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    public static func logEvent(event: FirebaseEvent, params: [String: Any]) {
        log("logEvent event \(event), params: = \(params)")
        Analytics.logEvent(event.rawValue, parameters: params)
    }
    
    public static func getValueOfPlistFile(_ plistFilename: String, _ key: String) -> String? {
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
}
