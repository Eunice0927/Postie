//
//  RemoteConfigManager.swift
//  PJ3T3_Postie
//
//  Created by Eunsu JEONG on 2/14/25.
//

import Foundation
import FirebaseRemoteConfig
import OSLog

enum RemoteConfigKeys: String {
    case is_force_update
    case latest_notice_uuid
}

final class RemoteConfigManager: ObservableObject {
    let remoteConfig = RemoteConfig.remoteConfig()
    let settings = RemoteConfigSettings()
    
    public init() {
        fetchConfig()
    }
    
    private func fetchConfig() {
        settings.minimumFetchInterval = 1
        remoteConfig.configSettings = settings
        
        remoteConfig.fetch() { [weak self] status, error in
            guard error == nil, status == .success else { return }
            
            self?.remoteConfig.activate { isChanged, error in
                guard error == nil else { return }
                Logger.firebase.log("RemoteConfig fetched and activated: \(isChanged)")
            }
        }
    }
    
    func getBool(from key: RemoteConfigKeys) -> Bool {
        return remoteConfig.configValue(forKey: key.rawValue).boolValue
    }
    
    func getString(from key: RemoteConfigKeys) -> String? {
        return remoteConfig.configValue(forKey: key.rawValue).stringValue
    }
    
    func getNumber(from key: RemoteConfigKeys) -> NSNumber {
        return remoteConfig.configValue(forKey: key.rawValue).numberValue
    }
    
    func getJson(from key: RemoteConfigKeys) -> [String: Any]? {
        return remoteConfig.configValue(forKey: key.rawValue).jsonValue as? [String: Any]
    }
}
