//
//  LocalizedMessage.swift
//  NoticeFeederClient
//
//  Created by Yugo TERADA on 2019/04/21.
//

import Foundation

fileprivate let langCode = Bundle.main.preferredLocalizations.first?.split(separator: "-").first

/// Text message with localization
struct LocalizedMessage: Decodable {
    
    /// Message of Japanese
    let ja_JP: String
    
    /// Message of English
    let en_US: String

    
    /// Get appropriate localized mesage
    ///
    /// - Returns: Localized text message
    ///
    /// If the app is prefferd first to display Japanese, return Japanese text.
    /// Other case, return English text.
    func getMessage() -> String {
        if let langCode = langCode, String(langCode) == "ja" {
            return ja_JP
        }
        return en_US
    }
}
