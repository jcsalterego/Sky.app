//
//  ViewController.swift
//  Sky
//  All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {

    // https://gist.github.com/swillits/df648e87016772c7f7e5dbed2b345066
    struct Keycode {
        static let escape                    : UInt16 = 0x35
        static let leftBracket               : UInt16 = 0x21
        static let rightBracket              : UInt16 = 0x1E
        static let k                         : UInt16 = 0x28
    }

    enum SkyUrls {
        static let host = "staging.bsky.app"
        static let root = "https://\(host)"
        static let home = "\(root)/"
        static let search = "\(root)/search"
        static let notifications = "\(root)/notifications"
        static let settings = "\(root)/settings"
    }

    var webView: WKWebView!
    var webKitDelegate: WebKitDelegate!

    var outerScrollbarsEnabled = false

    override func loadView() {
        webKitDelegate = WebKitDelegate()
        let webConfiguration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        let scriptMessageHandler = ScriptMessageHandler()
        scriptMessageHandler.viewController = self
        userContentController.add(scriptMessageHandler, name: "consoleLog")
        userContentController.add(scriptMessageHandler, name: "ctrlTab")
        userContentController.add(scriptMessageHandler, name: "fetch")
        userContentController.add(scriptMessageHandler, name: "windowColorSchemeChange")
        userContentController.add(scriptMessageHandler, name: "windowOpen")
        userContentController.addUserScript(
            newScriptFromSource("Scripts/hook_fetch"))
        userContentController.addUserScript(
            newScriptFromSource("Scripts/hook_initial_disable_scrollbars"))
        userContentController.addUserScript(
            newScriptFromSource("Scripts/hook_window_open"))
        userContentController.addUserScript(
            newScriptFromSource("Scripts/hook_window_color_scheme"))
        userContentController.addUserScript(
            newScriptFromSource("Scripts/hook_ctrl_tab"))

        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let orderPosts = appDelegate.getUserDefaultsOrderPosts()
        userContentController.addUserScript(
            newScriptFromSource(
                "Scripts/set_order_posts",
                ["value": orderPosts ? "yes" : "no" ]))

        webConfiguration.userContentController = userContentController
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = webKitDelegate
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        view = webView
    }

    // Observe value
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if let url = change?[NSKeyValueChangeKey.newKey] as? NSURL {
            // Currently the only section that should have
            // outer scrollbars enabled is /search.
            // We compare with outerScrollbarsEnabled to prevent
            // running JS unless we have to.
            let shouldHaveOuterScrollbars = url.path!.contains("/search")
            if shouldHaveOuterScrollbars != outerScrollbarsEnabled {
                // change state
                self.webView.evaluateJavaScript(
                    JsLoader.loadJs(
                        "Scripts/toggle_outer_scrollbars",
                        ["enabled": String(shouldHaveOuterScrollbars)]
                    )
                )
                outerScrollbarsEnabled = shouldHaveOuterScrollbars
            }
        }
    }

    func newScriptFromSource(_ name: String, _ context: [String: String] = [:]) -> WKUserScript {
        let source = JsLoader.loadJs(name, context)
        return WKUserScript(
            source: source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: SkyUrls.root)
        let myRequest = URLRequest(url: url!)
        webView.load(myRequest)
    }

    override func keyDown(with event: NSEvent) {
        if (event.keyCode == Keycode.escape) {
            self.webView.evaluateJavaScript(clickByLabel(label: "Cancel"))
        } else if (
            event.modifierFlags.contains(.command)
            && event.keyCode == Keycode.k
        ) {
            actionViewSearch(nil)
        }
    }

    @IBAction func actionViewHome(_ sender: Any?) {
        NSLog("view home \(SkyUrls.home)")
        if webView.url!.absoluteString == SkyUrls.home {
            NSLog("trying load new button first")
            self.webView.evaluateJavaScript(clickLoadNewButtonNavbarByIndexOrLabel(index: 0, label: "Home"))
        } else {
            self.webView.evaluateJavaScript(clickNavbarByIndexOrLabel(index: 0, label: "Home"))
        }
    }

    @IBAction func actionViewSearch(_ sender: Any?) {
        NSLog("view search \(SkyUrls.search)")
        self.webView.evaluateJavaScript(clickNavbarByIndexOrLabel(index: 1, label: "Search"))
    }

    @IBAction func actionViewNotifications(_ sender: Any?) {
        NSLog("view notifications \(SkyUrls.notifications)")
        if webView.url!.absoluteString == SkyUrls.notifications {
            NSLog("trying load new button first")
            self.webView.evaluateJavaScript(clickLoadNewButtonNavbarByIndexOrLabel(index: 2, label: "Notifications"))
        } else {
            self.webView.evaluateJavaScript(clickNavbarByIndexOrLabel(index: 2, label: "Notifications"))
        }
    }

    @IBAction func actionViewProfile(_ sender: Any?) {
        NSLog("view profile \(SkyUrls.settings)")
        self.webView.evaluateJavaScript(clickNavbarByIndexOrLabel(index: 3, label: "Profile"))
    }

    @IBAction func actionViewSettings(_ sender: Any?) {
        NSLog("view settings \(SkyUrls.settings)")
        self.webView.evaluateJavaScript(clickNavbarByIndexOrLabel(index: -1, label: "Settings"))
    }

    @IBAction func actionRefresh(_ sender: Any?) {
        (NSApplication.shared.delegate as! AppDelegate).clearNotifCounts()
        webView.reload()
    }

    @IBAction func actionOpenInBrowser(_ sender: Any?) {
        let urlString = webView.url!.absoluteString
        switch urlString {
        case SkyUrls.home,
             SkyUrls.notifications:
            break
        default:
            NSWorkspace.shared.open(webView.url!)
        }
    }

    @IBAction func actionCopyLink(_ sender: Any?) {
        let pasteboard = NSPasteboard.general
        let urlString = webView.url!.absoluteString
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(urlString, forType: NSPasteboard.PasteboardType.string)
    }

    @IBAction func actionNewPost(_ sender: Any?) {
        NSLog("new post \(SkyUrls.settings)")
        self.webView.evaluateJavaScript(clickNewPost())
    }

    @IBAction func actionNextTab(_ sender: Any?) {
        self.webView.evaluateJavaScript(navigateTab(direction: 1))
    }

    @IBAction func actionPrevTab(_ sender: Any?) {
        self.webView.evaluateJavaScript(navigateTab(direction: -1))
    }

    @IBAction func actionOrderPosts(_ sender: Any?) {
        if let menuItem = sender as? NSMenuItem {
            var orderPosts = menuItem.state == .on
            orderPosts = !orderPosts
            menuItem.state = orderPosts ? .on : .off
            self.webView.evaluateJavaScript(setOrderPosts(orderPosts))
            (NSApplication.shared.delegate as! AppDelegate)
                .setUserDefaultsOrderPosts(orderPosts)
        }
    }

    func setOrderPosts(_ orderPosts: Bool) -> String {
        return JsLoader.loadJs(
            "Scripts/set_order_posts",
            ["value": orderPosts ? "yes" : "no" ]
        )
    }

    func navigateTab(direction: Int) -> String {
        return JsLoader.loadJs(
            "Scripts/navigate_tab",
            ["direction": "\(direction)"]
        )
    }

    func clickLoadNewButtonNavbarByIndexOrLabel(index: Int, label: String) -> String {
        return JsLoader.loadJs(
            "Scripts/click_load_new_button_navbar_by_index_or_label",
            ["index": "\(index)", "label": label]
        )
    }

    func clickNavbarByIndexOrLabel(index: Int, label: String) -> String {
        return JsLoader.loadJs(
            "Scripts/click_navbar_by_index_or_label",
            ["index": "\(index)", "label": label]
        )
    }

    func clickByLabel(label: String) -> String {
        return JsLoader.loadJs(
            "Scripts/click_by_label",
            ["label": label]
        )
    }

    func clickNewPost() -> String {
        return JsLoader.loadJs(
            "Scripts/click_new_post", [:]
        )
    }

    enum WindowColorScheme {
        case dark
        case light
    }

    func updateTitleBar(_ mode: WindowColorScheme) {
//        NSLog("mode = \(mode)")
        switch (mode) {
        case .dark:
            self.webView.window!.backgroundColor = NSColor.black
            self.webView.window!.appearance = NSAppearance(named: .darkAqua)
        case .light:
            self.webView.window!.backgroundColor = NSColor.white
            self.webView.window!.appearance = NSAppearance(named: .aqua)
        }
    }

}
