//
//  Notice.swift
//  NoticeFeederClient
//
//  Created by Yugo TERADA on 2019/04/21.
//

import Foundation

fileprivate let DefaultKey = "NoticeFeederClient.alertedNoticeIds"


/// Notice object
public struct Notice: Decodable {
    
    /// Notice id
    let id: String
    
    /// Target platforms
    ///
    /// This contains in
    /// - "ios"
    /// - "android"
    /// - "web"
    let platform: [String]
    
    /// target versions
    let target_version: [String]
    
    /// Notice title
    let title: LocalizedMessage
    
    /// Notice message
    let message: LocalizedMessage
    
    /// Alert flag
    let alert: Bool?
    
    /// Should always notice flag
    ///
    /// This flag is valid with the alert flag
    let always: Bool?
    
    /// Active flag
    let active: Bool?
    
    
    /// Check the notice is alreay alerted
    ///
    /// - Returns: Alerted or not
    func alreadyAlerted() -> Bool {
        let ids = UserDefaults.standard.stringArray(forKey: DefaultKey) ?? []
        return ids.contains(id)
    }
    
    /// Mark the notice as alerted
    func markAsAlerted() {
        let userDefault = UserDefaults.standard
        var ids = userDefault.stringArray(forKey: DefaultKey) ?? []
        if !ids.contains(id) { ids.append(id) }
        
        userDefault.set(ids, forKey: DefaultKey)
        userDefault.synchronize()
    }
    
    
    /// Check the notice should alert or not
    ///
    /// - Returns: Should alert or not
    func shouldAlert() -> Bool {
        return (alert ?? false) && ((always ?? false) || !alreadyAlerted())
    }
    

    /// Check the notice is for the current platform
    ///
    /// - Returns: This is for current platform (ios)
    func targetPlatform() -> Bool {
        return platform.contains("ios")
    }
    
    /// Check the notice is for the current app version
    ///
    /// - Parameter appVersion: Current app version
    /// - Returns: This is for current version
    func targetVersion(appVersion: String) -> Bool {
        return target_version
            .map { version in
                return type(of: self).verifyTarget(target: version, current: appVersion)
            }.reduce(false) { (mono, item) -> Bool in
                return mono || item
        }
    }

    
    /// Verify target version and current version
    ///
    /// - Parameters:
    ///   - target: Specified version
    ///   - current: Current app version
    /// - Returns: Specified version is for current version or not
    ///
    /// # Example:
    /// - "1", "1.x" -> true
    /// - "1.1", "1.1" -> true
    /// - "1.1", "1.2" -> false
    /// - "1.3", "1.2" -> false
    /// - "1.2", "1.2.1" -> true
    /// - "1.2.0", "1.2.1" -> false
    static func verifyTarget(target: String, current: String) -> Bool {
        let targetComponents = target.split(separator: ".")
        let currentComponents = current.split(separator: ".")
        
        return targetComponents.enumerated()
            .map { (index, componentStr) -> Bool in
                let component = Int(componentStr) ?? 0
                let cComponent = Int(currentComponents[index]) ?? 0
                
                return component == cComponent
            }
            .reduce(true, { (mono, item) -> Bool in
                return mono && item
            })
    }
}

/// Feed object
///
/// The root object for parse feed json
struct Feed: Decodable {
    
    /// The feed updated timestamp
    let updated_at: Int
    
    /// Notice objects
    let data: [Notice]
}
