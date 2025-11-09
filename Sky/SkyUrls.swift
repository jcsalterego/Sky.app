//
//  SkyUrls.swift
//  Sky
//

enum SkyUrls {
    static func withPath(_ path: String) -> String {
        let host = AppDelegate.shared.getAppViewHost()
        return "https://\(host)/\(path)"
    }
    static func getHome() -> String {
        return withPath("")
    }
    static func getSearch() -> String {
        return withPath("search")
    }
    static func getFeeds() -> String {
        return withPath("feeds")
    }
    static func getLists() -> String {
        return withPath("lists")
    }
    static func getNotifications() -> String {
        return withPath("notifications")
    }
    static func getModeration() -> String {
        return withPath("moderation")
    }
    static func getSettings() -> String {
        return withPath("settings")
    }
    static func getMessages() -> String {
        return withPath("messages")
    }
}
