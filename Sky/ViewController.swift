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

    var outerScrollbarsEnabled = false

    let userScripts = [
        "hook_ctrl_tab",
        "hook_fetch",
        "hook_manage_hidden_divs",
        "hook_history_state",
        "hook_initial_disable_scrollbars",
        "hook_local_storage",
        "hook_page_up_down",
        "hook_window_color_scheme",
        "hook_window_open",
    ]

    override func loadView() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.mainViewController = self

        webKitDelegate = WebKitDelegate()
        let webConfiguration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        let scriptMessageHandler = ScriptMessageHandler()
        scriptMessageHandler.viewController = self
        for name in scriptMessageHandler.nameFns.keys {
            userContentController.add(scriptMessageHandler, name: name)
        }
        for userScript in userScripts {
            userContentController.addUserScript(
                JsLoader.loadWKUserScript(
                    "Scripts/\(userScript)"))
        }

        let orderPosts = appDelegate.getUserDefaultsOrderPosts()
        userContentController.addUserScript(
            JsLoader.loadWKUserScript(
                "Scripts/set_order_posts",
                ["value": orderPosts ? "yes" : "no" ]))


        if let muteTermsJson = UserDefaults.standard.object(
            forKey: UserDefaultKeys.muteTerms) as? String
        {
            userContentController.addUserScript(
                JsLoader.loadWKUserScript(
                    "Scripts/save_mute_terms",
                    ["mute_terms_json": muteTermsJson]
                )
            )
        }

        webConfiguration.userContentController = userContentController
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = webKitDelegate
        webView.uiDelegate = webKitDelegate
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
                    JsLoader.loadScriptContents(
                        "Scripts/toggle_outer_scrollbars",
                        ["enabled": String(shouldHaveOuterScrollbars)]
                    )
                )
                outerScrollbarsEnabled = shouldHaveOuterScrollbars
            }
        }
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
            actionViewSearch(nil)
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

    @IBAction func actionViewNotifications(_ sender: Any?) {
        let checkLoadNew = (webView.url!.absoluteString == SkyUrls.notifications)
        self.webView.evaluateJavaScript(
            Scripts.navigateNavbar(
                checkLoadNew: checkLoadNew,
                label: "Notifications",
                index: 2,
                url: SkyUrls.notifications
            )
        )
    }

    @IBAction func actionViewProfile(_ sender: Any?) {
        self.webView.evaluateJavaScript(
            Scripts.navigateNavbar(
                checkLoadNew: false,
                label: "Profile",
                index: 3,
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
        self.webView.evaluateJavaScript(Scripts.clickByAriaLabel("Compose Post"))
    }

    @IBAction func actionNextTab(_ sender: Any?) {
        self.webView.evaluateJavaScript(Scripts.navigateTab(direction: 1))
    }

    @IBAction func actionPrevTab(_ sender: Any?) {
        self.webView.evaluateJavaScript(Scripts.navigateTab(direction: -1))
    }

    @IBAction func actionOpenDevConsole(_ sender: Any?) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        if let devConsoleWindowController = appDelegate.devConsoleWindowController {
            devConsoleWindowController.showWindow(self)
        }
    }

    @IBAction func actionOrderPosts(_ sender: Any?) {
        if let menuItem = sender as? NSMenuItem {
            var orderPosts = menuItem.state == .on
            orderPosts = !orderPosts
            menuItem.state = orderPosts ? .on : .off
            self.webView.evaluateJavaScript(Scripts.setOrderPosts(orderPosts))
            (NSApplication.shared.delegate as! AppDelegate)
                .setUserDefaultsOrderPosts(orderPosts)
        }
    }

    @IBAction func actionToggleDarkMode(_ sender: Any?) {
        self.webView.evaluateJavaScript(
            Scripts.toggleDarkMode()
        )
    }

    @IBAction func actionLaunchMuteTermsEditor(_ sender: Any?) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        if let muteTermsEditorWindowController = appDelegate.muteTermsEditorWindowController {
            NSApplication.shared.runModal(for: muteTermsEditorWindowController.window!)
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

}
