//
//  Scripts.swift
//  Sky
//

import Foundation

class Scripts {

    static func clickByAriaLabel(_ ariaLabel: String) -> String {
        return JsLoader.loadScriptContents(
            "Scripts/click_by_aria_label", ["aria_label": ariaLabel]
        )
    }

    static func escGoesBack() -> String {
        return JsLoader.loadScriptContents(
            "Scripts/esc_goes_back", [:]
        )
    }

    static func navigateNavbar(
        checkLoadNew: Bool,
        label: String,
        index: Int,
        url: String?
    ) -> String {
        return JsLoader.loadScriptContents(
            "Scripts/navigate_navbar", [
                "check_load_new": checkLoadNew ? "true" : "false",
                "index": "\(index)",
                "label": label,
                "url": url ?? "",
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

    static func toggleDarkMode() -> String {
        return JsLoader.loadScriptContents(
            "Scripts/toggle_dark_mode", [:]
        )
    }

}
