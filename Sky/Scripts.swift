//
//  Scripts.swift
//  Sky
//

import Foundation

class Scripts {

    static func clickByLabel(label: String) -> String {
        return JsLoader.loadJs(
            "Scripts/click_by_label",
            ["label": label]
        )
    }

    static func clickLoadNewButtonNavbarByIndexOrLabel(index: Int, label: String) -> String {
        return JsLoader.loadJs(
            "Scripts/click_load_new_button_navbar_by_index_or_label",
            ["index": "\(index)", "label": label]
        )
    }

    static func clickNavbarByIndexOrLabel(index: Int, label: String) -> String {
        return JsLoader.loadJs(
            "Scripts/click_navbar_by_index_or_label",
            ["index": "\(index)", "label": label]
        )
    }

    static func clickNewPost() -> String {
        return JsLoader.loadJs(
            "Scripts/click_new_post", [:]
        )
    }

    static func navigateTab(direction: Int) -> String {
        return JsLoader.loadJs(
            "Scripts/navigate_tab",
            ["direction": "\(direction)"]
        )
    }

    static func setOrderPosts(_ orderPosts: Bool) -> String {
        return JsLoader.loadJs(
            "Scripts/set_order_posts",
            ["value": orderPosts ? "yes" : "no" ]
        )
    }

}
