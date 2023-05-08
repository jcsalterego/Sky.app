//
//  Scripts.swift
//  Sky
//

import Foundation

class Scripts {

    static func clickNewPost() -> String {
        return JsLoader.loadScriptContents(
            "Scripts/click_new_post", [:]
        )
    }

    static func escOrBack() -> String {
        return JsLoader.loadScriptContents(
            "Scripts/esc_or_back", [:]
        )
    }

    static func navigateNavbar(
        checkLoadNew: Bool,
        label: String,
        index: Int
    ) -> String {
        return JsLoader.loadScriptContents(
            "Scripts/navigate_navbar", [
                "check_load_new": checkLoadNew ? "true" : "false",
                "index": "\(index)",
                "label": label,
            ]
        )
    }

    static func navigateTab(direction: Int) -> String {
        return JsLoader.loadScriptContents(
            "Scripts/navigate_tab",
            ["direction": "\(direction)"]
        )
    }

    static func setOrderPosts(_ orderPosts: Bool) -> String {
        return JsLoader.loadScriptContents(
            "Scripts/set_order_posts",
            ["value": orderPosts ? "yes" : "no" ]
        )
    }

}
