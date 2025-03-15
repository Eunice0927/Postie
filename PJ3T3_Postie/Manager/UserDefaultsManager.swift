//
//  UserDefaultsManager.swift
//  PJ3T3_Postie
//
//  Created by Eunsu JEONG on 3/15/25.
//

import Foundation

enum UserDefaultsKey: String {
    case appFirstTimeOpend // Bool: 앱을 설치 후 처음 실행했는지 여부
    
    case profileImageTemp
    case IsThemeGroupButton
    case IsTabGroupButton
    case allAlert
    case slowAlert
    case CurrentThemeIndex
}

struct UserDefaultsManager {
    
    private static let userDefaults = UserDefaults.standard

    // 저장 (Set)
    static func set<T>(_ value: T, forKey key: UserDefaultsKey) {
        userDefaults.set(value, forKey: key.rawValue)
    }

    // 불러오기 (Get)
    static func get<T>(forKey key: UserDefaultsKey) -> T? {
        return userDefaults.object(forKey: key.rawValue) as? T
    }

    // 삭제 (Delete)
    static func delete(forKey key: UserDefaultsKey) {
        userDefaults.removeObject(forKey: key.rawValue)
    }
}
