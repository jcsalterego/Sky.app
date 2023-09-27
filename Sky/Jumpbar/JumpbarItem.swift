//
//  JumpbarItem.swift
//  Sky
//

enum JumpbarDestination: Decodable, Encodable {
    case home
    case search
    case feeds
    case notifications
    case moderation
    case profile
    case settings

    case feed
}

struct JumpbarItem: Decodable, Encodable {
    var label: String
    var value: String
    var destination: JumpbarDestination
}
