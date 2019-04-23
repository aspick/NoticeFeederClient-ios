//
//  NoticeFeederClient.swift
//  NoticeFeederClient
//
//  Created by Yugo TERADA on 2019/04/21.
//

import Foundation


/// client of notice feeder
public class NoticeFeederClient {
    
    /// Feed url
    ///
    /// Repository sample feed json url is set as default
    var url = "https://raw.githubusercontent.com/aspick/notice_feeder/master/docs/sample.json"
    
    
    /// Contains all notice on the feed
    var raw: [Notice] = []
    
    
    /// Contains appropriate notices
    var filtered: [Notice] = []
    
    
    /// Alert handler
    var alertHandler: ((String, String) -> Void)? = nil
    
    
    /// Current app version
    let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    
    
    /// User default
    let userDefault = UserDefaults.standard
    
    
    init() {}
    
    
    /// init
    ///
    /// - Parameters:
    ///   - url: feed url
    ///   - alertHandler: alert display handler
    init(url: String, alertHandler: ((String, String) -> Void)?) {
        self.url = url
        self.alertHandler = alertHandler
    }
    
    
    /// fetch the feed and call alert handler if needed
    public func update() {
        fetch()
    }
    
    
    /// notice count
    ///
    /// - Returns: count
    public func noticeCount() -> Int {
        return filtered.count
    }
    
    
    /// notice object
    ///
    /// - Parameter atIndex: index of array
    /// - Returns: notice object
    public func notice(atIndex: Int) -> Notice? {
        return filtered[atIndex]
    }
    
    
    /// fetch inner, update notices
    func fetch() {
        let url = URL(string: self.url)!
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if error == nil, let data = data {
                do {
                    let feed = try JSONDecoder().decode(Feed.self, from: data)
                    self.raw = feed.data
                    
                    self.updateInner()
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    
    /// update filtered array and show alerts
    func updateInner() {
        filtered = raw.filter { (notice) -> Bool in
            return notice.targetPlatform() && notice.targetVersion(appVersion: appVersion ?? "")
        }
        filtered.forEach { (notice) in
            showAlert(notice: notice)
        }
    }
    
    
    /// show single alert if needed
    ///
    /// - Parameter notice: notice object
    func showAlert(notice: Notice) {
        if let handler = alertHandler, notice.shouldAlert() {
            handler(notice.title.getMessage(), notice.message.getMessage())
            notice.markAsAlerted()
        }
    }
}
