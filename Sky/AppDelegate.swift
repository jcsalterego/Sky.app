//
//  AppDelegate.swift
//  Sky
//

//  All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var lastBadgeCount = 0
    var notificationReadStatuses = [String:Int]()
    var firstRun = true

    // TODO cleanup, sigh
    var mainWindow: NSWindow? = nil
    var windowDelegate: WindowDelegate? = nil
    var mainViewController : ViewController?

    var devConsoleWindowController : NSWindowController?
    var devConsoleViewController : DevConsoleViewController?
    var accessJwt : String? = nil

    var muteTermsEditorWindowController : NSWindowController?
    var muteTermsEditorViewController : MuteTermsEditorViewController?

    var localStorageMirror = [String:String]()

    func applicationDidBecomeActive(_ notification: Notification) {
        // TODO don't use firstRun
        if firstRun {
            firstRun = false

            if let mainWindow = NSApplication.shared.mainWindow {
                windowDelegate = WindowDelegate()
                mainWindow.delegate = windowDelegate
                windowDelegate!.updateWindowDesktopMode(mainWindow.frame.width)
                mainWindow.backgroundColor = NSColor.white

                if let storyboard = mainWindow.windowController?.storyboard {
                    devConsoleWindowController = storyboard.instantiateController(
                        withIdentifier: "DevConsoleWindowController") as? NSWindowController
                } else {
                    NSLog("fail to load storyboard")
                }

                if let storyboard = mainWindow.windowController?.storyboard {
                    muteTermsEditorWindowController = storyboard.instantiateController(
                        withIdentifier: "MuteTermsEditorWindowController") as? MuteTermsWindowController
                } else {
                    NSLog("fail to load storyboard")
                }
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let menuItem = NSApplication.shared.mainMenu?
            .item(withTitle: "Advanced")?.submenu?
            .item(withTitle: "Search Posts by Newest First")
        let orderPosts = getUserDefaultsOrderPosts()
        menuItem?.state = orderPosts ? .on : .off
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func clearNotifCounts() {
        notificationReadStatuses.removeAll()
    }

    func setNotificationReadStatus(uri: String, isRead: Int) {
        notificationReadStatuses[uri] = isRead
    }

    func refreshBadge() {
//        NSLog("notificationReadStatuses = \(notificationReadStatuses)")
        var totalBadgeCount = 0
        for (_, isRead) in notificationReadStatuses {
            if isRead == 0 {
                totalBadgeCount += 1
            }
        }
        if totalBadgeCount != lastBadgeCount {
            if totalBadgeCount == 0 {
                NSApp.dockTile.badgeLabel = nil
            } else {
                NSApp.dockTile.badgeLabel = String(totalBadgeCount)
            }
            lastBadgeCount = totalBadgeCount
        }
    }

    func getUserDefaultsOrderPosts() -> Bool {
        let defaults = UserDefaults.standard
        if let orderPosts = defaults.object(forKey: UserDefaultKeys.orderPosts) as? Bool {
            return orderPosts
        } else {
            return false
        }
    }

    func setUserDefaultsOrderPosts(_ orderPosts: Bool) {
        UserDefaults.standard.set(
            orderPosts,
            forKey: UserDefaultKeys.orderPosts
        )
    }

    func setLocalStorage(key: String, jsonValue: String) {
        localStorageMirror[key] = jsonValue
    }

    func getActiveAccessJwt() -> String? {
        var accessToken: String? = nil
        if let rootJsonData = localStorageMirror["root"]?.data(using:.utf8) {
            let rootLocalStorage = try? JSONDecoder().decode(
                RootLocalStorage.self,
                from: rootJsonData
            )
            if let session = rootLocalStorage?.session,
                let me = rootLocalStorage?.me
            {
                for account in session.accounts {
                    if account.did == me.did {
                        accessToken = account.accessJwt
                        break
                    }
                }
            }
        }
        return accessToken
    }

    func getMuteTerms() -> [MuteTerm] {
        var muteTerms: [MuteTerm] = []
        if let json = UserDefaults.standard.object(forKey: UserDefaultKeys.muteTerms) as? String {
            if let rootJsonData = json.data(using:.utf8) {
                if let muteTermsFromJson = try? JSONDecoder().decode(
                    [MuteTerm].self,
                    from: rootJsonData
                ) {
                    NSLog("muteTermsFromJson = \(muteTermsFromJson)")
                    muteTerms = muteTermsFromJson
                }
            }
        }
        return muteTerms
    }

    func saveMuteTerms(_ muteTerms: [MuteTerm]) {
        var json: String? = nil
        let jsonEncoder = JSONEncoder()
        if let jsonResultData = try? jsonEncoder.encode(muteTerms) {
            json = String(data: jsonResultData, encoding: .utf8)!
        }

        if json != nil {
            UserDefaults.standard.set(
                json,
                forKey: UserDefaultKeys.muteTerms
            )

            mainViewController?.webView.evaluateJavaScript(
                JsLoader.loadScriptContents(
                    "Scripts/save_mute_terms",
                    ["mute_terms_json": json!]
                )
            )
        }
    }

}

extension AppDelegate: NSMenuDelegate {

    func menuNeedsUpdate(_ menu: NSMenu) {
        if let lastItem = menu.item(at: menu.numberOfItems - 1) {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            let count = appDelegate.getMuteTerms().count
            var title = ""
            if count == 0 {
                title = "No mute terms enabled"
            } else {
                let label = count == 1 ? "mute term" : "mute terms"
                title = "\(count) \(label) enabled"
            }
            lastItem.title = title
        }
    }

}
