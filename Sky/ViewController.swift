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

    let nsLogKeyDown = false
    let jsonLogging = false

    override func loadView() {
        webKitDelegate = WebKitDelegate()
        let webConfiguration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        let scriptMessageHandler = ScriptMessageHandler()
        scriptMessageHandler.viewController = self
        userContentController.add(scriptMessageHandler, name: "windowOpen")
        userContentController.add(scriptMessageHandler, name: "lightModeChange")
        userContentController.addUserScript(
            newScriptFromSource("Scripts/hook_window_open"))
        userContentController.addUserScript(
            newScriptFromSource("Scripts/hook_light_mode"))
        webConfiguration.userContentController = userContentController
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = webKitDelegate
        view = webView
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
        webView.reload()
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
    
    enum LightMode {
        case dark
        case light
    }

    func updateTitleBar(_ mode: LightMode) {
        var color: NSColor = NSColor.white
        switch (mode) {
        case .dark:
            color = NSColor.black
        case .light:
            color = NSColor.white
        }
        self.webView.window!.backgroundColor = color
    }

}
