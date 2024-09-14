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

    var webView: WKWebView!
    var webKitDelegate: WebKitDelegate!

    var muteWordsWkUserScript: WKUserScript?
    var orderPostsWkUserScript: WKUserScript?
    var hideHomeRepliesWkUserScript: WKUserScript?
    var setZoomFactorWkUserScript: WKUserScript?

    let userScriptsAtDocumentStart = [
        "hook_fetch",
    ]

    let userScriptsAtDocumentEnd = [
        "hook_ctrl_tab",
        "hook_history_state",
        "hook_local_storage",
        "hook_window_color_scheme",
        "hook_window_open",
    ]

    override func loadView() {
        AppDelegate.shared.mainViewController = self

        webKitDelegate = WebKitDelegate()
        let webConfiguration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        let scriptMessageHandler = ScriptMessageHandler()
        scriptMessageHandler.viewController = self
        for name in scriptMessageHandler.nameFns.keys {
            userContentController.add(scriptMessageHandler, name: name)
        }
        for userScript in userScriptsAtDocumentStart {
            userContentController.addUserScript(
                JsLoader.loadWKUserScript(
                    "Scripts/\(userScript)",
                    [:],
                    .atDocumentStart))
        }
        for userScript in userScriptsAtDocumentEnd {
            userContentController.addUserScript(
                JsLoader.loadWKUserScript(
                    "Scripts/\(userScript)",
                    [:],
                    .atDocumentEnd))
        }

        let orderPosts = AppDelegate.shared.getUserDefaultsOrderPosts()
        let orderPostsValue = orderPosts ? "yes" : "no"
        orderPostsWkUserScript = JsLoader.loadWKUserScript(
            "Scripts/local_storage_set_item",
            ["key": LocalStorageKeys.orderPosts, "value": orderPostsValue]
        )
        userContentController.addUserScript(orderPostsWkUserScript!)

        let hideHomeReplies = AppDelegate.shared.getUserDefaultsHideHomeReplies()
        let hideHomeRepliesValue = hideHomeReplies ? "yes" : "no"
        hideHomeRepliesWkUserScript = JsLoader.loadWKUserScript(
            "Scripts/local_storage_set_item",
            ["key": LocalStorageKeys.hideHomeReplies, "value": hideHomeRepliesValue]
        )
        userContentController.addUserScript(hideHomeRepliesWkUserScript!)

        let zoomFactor = AppDelegate.shared.getZoomFactor()
        setZoomFactorWkUserScript = JsLoader.loadWKUserScript(
            "Scripts/set_zoom_factor",
            ["zoom_factor": "\(zoomFactor)"]
        )
        userContentController.addUserScript(setZoomFactorWkUserScript!)

        webConfiguration.userContentController = userContentController
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = webKitDelegate
        webView.uiDelegate = webKitDelegate
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)

        // defaults write jcsalterego.Sky webInspector -bool TRUE
        if let webInspector = UserDefaults.standard.object(forKey: UserDefaultKeys.webInspector) as? Bool {
            webView.configuration.preferences.setValue(webInspector, forKey: "developerExtrasEnabled")
        }

        view = webView
    }

    // Observe value
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: SkyUrls.root)
        let myRequest = URLRequest(url: url!)
        webView.load(myRequest)
    }

    override func keyDown(with event: NSEvent) {
        if (event.keyCode == Keycode.escape) {
            self.webView.evaluateJavaScript(Scripts.escGoesBack())
        } else if (
            event.modifierFlags.contains(.command)
            && event.keyCode == Keycode.k
        ) {
            actionLaunchJumpbar(nil)
        }
    }

    @IBAction func actionViewHome(_ sender: Any?) {
        let checkLoadNew = (webView.url!.absoluteString == SkyUrls.home)
        self.webView.evaluateJavaScript(
            Scripts.navigateNavbar(
                checkLoadNew: checkLoadNew,
                label: "Home",
                index: 0,
                url: SkyUrls.home
            )
        )
    }

    @IBAction func actionViewSearch(_ sender: Any?) {
        self.webView.evaluateJavaScript(
            Scripts.navigateNavbar(
                checkLoadNew: false,
                label: "Search",
                index: 1,
                url: SkyUrls.search
            )
        )
    }

    @IBAction func actionViewFeeds(_ sender: Any?) {
        let checkLoadNew = (webView.url!.absoluteString == SkyUrls.feeds)
        self.webView.evaluateJavaScript(
            Scripts.navigateNavbar(
                checkLoadNew: checkLoadNew,
                label: "Feeds",
                index: 2,
                url: SkyUrls.feeds
            )
        )
    }

    @IBAction func actionViewLists(_ sender: Any?) {
        let checkLoadNew = (webView.url!.absoluteString == SkyUrls.lists)
        self.webView.evaluateJavaScript(
            Scripts.navigateNavbar(
                checkLoadNew: checkLoadNew,
                label: "Lists",
                index: -1,
                url: SkyUrls.lists
            )
        )
    }

    @IBAction func actionViewNotifications(_ sender: Any?) {
        let checkLoadNew = (webView.url!.absoluteString == SkyUrls.notifications)
        self.webView.evaluateJavaScript(
            Scripts.navigateNavbar(
                checkLoadNew: checkLoadNew,
                label: "Notifications",
                index: 3,
                url: SkyUrls.notifications
            )
        )
    }

    @IBAction func actionViewChat(_ sender: Any?) {
        let checkLoadNew = (webView.url!.absoluteString == SkyUrls.messages)
        self.webView.evaluateJavaScript(
            Scripts.navigateNavbar(
                checkLoadNew: checkLoadNew,
                label: "Chat",
                index: -1,
                url: SkyUrls.messages
            )
        )
    }

    @IBAction func actionViewProfile(_ sender: Any?) {
        self.webView.evaluateJavaScript(
            Scripts.navigateNavbar(
                checkLoadNew: false,
                label: "Profile",
                index: 4,
                url: nil
            )
        )
    }

    @IBAction func actionViewModeration(_ sender: Any?) {
        self.webView.evaluateJavaScript(
            Scripts.navigateNavbar(
                checkLoadNew: false,
                label: "Moderation",
                index: -1,
                url: SkyUrls.moderation
            )
        )
    }

    @IBAction func actionViewSettings(_ sender: Any?) {
        self.webView.evaluateJavaScript(
            Scripts.navigateNavbar(
                checkLoadNew: false,
                label: "Settings",
                index: -1,
                url: SkyUrls.settings
            )
        )
    }

    @IBAction func actionRefresh(_ sender: Any?) {
        AppDelegate.shared.clearNotifCounts()

        let scriptsToRefresh = [
            muteWordsWkUserScript,
            setZoomFactorWkUserScript,
        ]
        var newUserScripts: [WKUserScript] = []
        let userContentController = webView.configuration.userContentController
        for userScript in userContentController.userScripts {
            if !scriptsToRefresh.contains(userScript) {
                newUserScripts.append(userScript)
            }
        }

        let orderPosts = AppDelegate.shared.getUserDefaultsOrderPosts()
        let orderPostsValue = orderPosts ? "yes" : "no"
        newUserScripts.append(
            JsLoader.loadWKUserScript(
                "Scripts/local_storage_set_item",
                ["key": LocalStorageKeys.orderPosts, "value": orderPostsValue]
            )
        )

        let hideHomeReplies = AppDelegate.shared.getUserDefaultsHideHomeReplies()
        let hideHomeRepliesValue = hideHomeReplies ? "yes" : "no"
        newUserScripts.append(
            JsLoader.loadWKUserScript(
                "Scripts/local_storage_set_item",
                ["key": LocalStorageKeys.hideHomeReplies, "value": hideHomeRepliesValue]
            )
        )

        let zoomFactor = AppDelegate.shared.getZoomFactor()
        newUserScripts.append(
            JsLoader.loadWKUserScript(
                "Scripts/set_zoom_factor",
                ["zoom_factor": "\(zoomFactor)"]
            )
        )

        userContentController.removeAllUserScripts()
        for userScript in newUserScripts {
            userContentController.addUserScript(userScript)
        }

        webView.reload()
    }

    func goToFeed(_ atURLString: String) {
        NSLog("urlString = \(atURLString)")
        // at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/hot-classic
        let words = atURLString
            .replacingOccurrences(of: "at://", with: "")
            .split(separator: "/")
        if words.count == 3 {
            let actor = words[0]
            let collection = words[1]
            let rkey = words[2]
            if actor.starts(with: "did:")
                && collection == "app.bsky.feed.generator"
            {
                let url = getFeedURL(actor: "\(actor)", rkey: "\(rkey)")
                let myRequest = URLRequest(url: url!)
                webView.load(myRequest)
            }
        }
    }

    func getFeedURL(actor: String, rkey: String) -> URL? {
        let urlString = "https://bsky.app/profile/\(actor)/feed/\(rkey)"
        return URL(string: urlString)
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
        self.webView.evaluateJavaScript(Scripts.clickByAriaLabel("New Post"))
    }

    @IBAction func actionNextTab(_ sender: Any?) {
        self.webView.evaluateJavaScript(Scripts.navigateTab(direction: 1))
    }

    @IBAction func actionPrevTab(_ sender: Any?) {
        self.webView.evaluateJavaScript(Scripts.navigateTab(direction: -1))
    }

    @IBAction func actionOrderPosts(_ sender: Any?) {
        if let menuItem = sender as? NSMenuItem {
            var orderPosts = menuItem.state == .on
            orderPosts = !orderPosts
            menuItem.state = orderPosts ? .on : .off
            setOrderPosts(orderPosts)
            AppDelegate.shared.setUserDefaultsOrderPosts(orderPosts)
        }
    }

    func setOrderPosts(_ orderPosts: Bool) {
        let orderPostsValue = orderPosts ? "yes" : "no"
        self.webView.evaluateJavaScript(
            Scripts.localStorageSetItem(
                key: LocalStorageKeys.orderPosts,
                value: orderPostsValue
            )
        )
    }

    @IBAction func actionHideHomeReplies(_ sender: Any?) {
        if let menuItem = sender as? NSMenuItem {
            var hideHomeReplies = menuItem.state == .on
            hideHomeReplies = !hideHomeReplies
            menuItem.state = hideHomeReplies ? .on : .off
            setHideHomeReplies(hideHomeReplies)
            AppDelegate.shared.setUserDefaultsHideHomeReplies(hideHomeReplies)

            let alert = NSAlert()
            alert.messageText = "Refresh Timeline?"
            if hideHomeReplies {
                alert.informativeText = "Refresh the timeline to hide replies?\nOr you can go to File > Refresh later on."
            } else {
                alert.informativeText = "Refresh the timeline to include replies?\nOr you can go to File > Refresh later on."
            }
            alert.addButton(withTitle: "Yes")
            alert.addButton(withTitle: "No")
            let action = alert.runModal()
            if action == .alertFirstButtonReturn {
                AppDelegate.shared.mainViewController?.actionRefresh(nil)
            }
        }
    }

    @IBAction func actionUseTranslationsWindow(_ sender: Any?) {
        if let menuItem = sender as? NSMenuItem {
            var useTranslationsWindow = menuItem.state == .on
            useTranslationsWindow = !useTranslationsWindow
            menuItem.state = useTranslationsWindow ? .on : .off
            AppDelegate.shared.setUserDefaultsUseTranslationsWindow(useTranslationsWindow)
        }
    }

    func setHideHomeReplies(_ hideHomeReplies: Bool) {
        let hideHomeRepliesValue = hideHomeReplies ? "yes" : "no"
        self.webView.evaluateJavaScript(
            Scripts.localStorageSetItem(
                key: LocalStorageKeys.hideHomeReplies,
                value: hideHomeRepliesValue
            )
        )
    }

    @IBAction func actionLaunchJumpbar(_ sender: Any?) {
        if let jumpbarWindowController = AppDelegate.shared.jumpbarWindowController {
            NSApplication.shared.runModal(for: jumpbarWindowController.window!)
        }
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

    func adjustAndApplyZoomFactor(_ adjustValue: Int) {
        let ZOOM_FACTORS = AppDelegate.ZOOM_FACTORS
        var zoomFactor = AppDelegate.shared.getZoomFactor()

        if adjustValue != 0, var pos = ZOOM_FACTORS.firstIndex(of: zoomFactor) {
            pos += adjustValue
            pos = max(0, pos)
            pos = min(pos, ZOOM_FACTORS.count - 1)
            zoomFactor = ZOOM_FACTORS[pos]
        } else {
            zoomFactor = 1.0
        }
        AppDelegate.shared.setZoomFactor(zoomFactor)
        self.webView.evaluateJavaScript(
            JsLoader.loadScriptContents(
                "Scripts/set_zoom_factor",
                ["zoom_factor": "\(zoomFactor)"]
            )
        )
    }

    @IBAction func actionZoomIn(_ sender: Any?) {
        adjustAndApplyZoomFactor(1)
    }

    @IBAction func actionZoomOut(_ sender: Any?) {
        adjustAndApplyZoomFactor(-1)
    }

    @IBAction func actionActualSize(_ sender: Any?) {
        adjustAndApplyZoomFactor(0)
    }

}
