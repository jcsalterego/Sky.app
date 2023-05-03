//
//  ViewController.swift
//  Sky
//  All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {

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
        userContentController.add(scriptMessageHandler, name: "fetch")
        userContentController.add(scriptMessageHandler, name: "windowOpen")
        userContentController.add(scriptMessageHandler, name: "windowColorSchemeChange")
        userContentController.addUserScript(
            newScriptFromSource("Scripts/hook_fetch"))
        userContentController.addUserScript(
            newScriptFromSource("Scripts/hook_initial_disable_scrollbars"))
        userContentController.addUserScript(
            newScriptFromSource("Scripts/hook_window_open"))
        userContentController.addUserScript(
            newScriptFromSource("Scripts/hook_window_color_scheme"))
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
                );
                outerScrollbarsEnabled = shouldHaveOuterScrollbars
            }
        }
    }

    func newScriptFromSource(_ name: String) -> WKUserScript {
        let source = JsLoader.loadJs(name)
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
        if (event.keyCode == 53) {
            self.webView.evaluateJavaScript(clickByLabel(label: "Cancel"))
        }
    }

    @IBAction func actionViewHome(_ sender: Any?) {
        NSLog("view home \(SkyUrls.home)")
        self.webView.evaluateJavaScript(clickNavbarByIndexOrLabel(index: 0, label: "Home"))
    }

    @IBAction func actionViewSearch(_ sender: Any?) {
        NSLog("view search \(SkyUrls.search)")
        self.webView.evaluateJavaScript(clickNavbarByIndexOrLabel(index: 1, label: "Search"))
    }

    @IBAction func actionViewNotifications(_ sender: Any?) {
        NSLog("view notifications \(SkyUrls.notifications)")
        self.webView.evaluateJavaScript(clickNavbarByIndexOrLabel(index: 2, label: "Notifications"))
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
        self.webView.evaluateJavaScript(clickNewPost());
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
