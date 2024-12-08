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
}
