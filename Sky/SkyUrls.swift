//
//  SkyUrls.swift
//  Sky
//

enum SkyUrls {
    static func getHome() -> String {
        let host = AppDelegate.shared.getAppViewHost()
        return "https://\(host)/"
    }
    static func getSearch() -> String {
        let host = AppDelegate.shared.getAppViewHost()
        return "https://\(host)/search"
    }
    static func getFeeds() -> String {
        let host = AppDelegate.shared.getAppViewHost()
        return "https://\(host)/feeds"
    }
    static func getLists() -> String {
        let host = AppDelegate.shared.getAppViewHost()
        return "https://\(host)/lists"
    }
    static func getNotifications() -> String {
        let host = AppDelegate.shared.getAppViewHost()
        return "https://\(host)/notifications"
    }
    static func getModeration() -> String {
        let host = AppDelegate.shared.getAppViewHost()
        return "https://\(host)/moderation"
    }
    static func getSettings() -> String {
        let host = AppDelegate.shared.getAppViewHost()
        return "https://\(host)/settings"
    }
    static func getMessages() -> String {
        let host = AppDelegate.shared.getAppViewHost()
        return "https://\(host)/messages"
    }
}
