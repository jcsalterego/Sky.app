//
//  RootLocalStorage.swift
//  Sky
//

struct RootLocalStorage: Decodable {
    struct Session: Decodable {
        struct Data: Decodable  {
            var service: String
            var did: String
        }
        var data: Data
        struct Account: Decodable  {
            var service: String
            var did: String
            var refreshJwt: String
            var accessJwt: String
            var handle: String
            var email: String
            var aviUrl: String
        }
        var accounts: [Account]
    }
    var session: Session

    struct Me: Decodable {
        var did: String
        var handle: String
        var displayName: String
        var description: String
        var avatar: String
    }
    var me: Me

    struct Shell: Decodable {
        var colorMode: String
    }
    var shell: Shell

    struct Preferences: Decodable {
        var savedFeeds: [String]?
    }
    var preferences: Preferences
    // invitedUsers
    // mutedThreads
}
