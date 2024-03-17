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

    var mutedTermsHits = 0

    // TODO cleanup, sigh
    var mainWindow: NSWindow? = nil
    var windowDelegate: WindowDelegate? = nil
    var mainViewController : ViewController?

    var jumpbarWindowController : NSWindowController?
    var jumpbarViewController : JumpbarViewController?

    var translationsWindowController : TranslationsWindowController?
    var translationsViewController : TranslationsViewController?

    var localStorageMirror = [String:String]()

    class var shared: AppDelegate {
        get {
            return NSApplication.shared.delegate as! AppDelegate
        }
    }

    func openURL(_ urlString: String) {
        let url = URL.init(string: urlString)!
        if url.host == "translate.google.com",
            AppDelegate.shared.getUserDefaultsUseTranslationsWindow(),
            let windowController = translationsWindowController
        {
            windowController.openURL(url)
            NSApplication.shared.runModal(for: windowController.window!)
            return
        }
        NSWorkspace.shared.open(url)
    }

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

                    jumpbarWindowController = storyboard.instantiateController(
                        withIdentifier: "JumpbarWindowController") as? JumpbarWindowController

                    translationsWindowController = storyboard.instantiateController(
                        withIdentifier: "TranslationsWindowController") as? TranslationsWindowController

                } else {
                    NSLog("fail to load storyboard")
                }
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let advancedSubmenu = NSApplication.shared.mainMenu?
            .item(withTitle: "Advanced")?.submenu

        let orderPostsMenuItem = advancedSubmenu?
            .item(withTitle: "Search Posts by Newest First")
        let orderPosts = getUserDefaultsOrderPosts()
        orderPostsMenuItem?.state = orderPosts ? .on : .off

        let hideHomePostsMenuItem = advancedSubmenu?
            .item(withTitle: "Hide Replies in Following")
        let hideHomeReplies = getUserDefaultsHideHomeReplies()
        hideHomePostsMenuItem?.state = hideHomeReplies ? .on : .off

        let useTranslationsWindowMenuItem = advancedSubmenu?
            .item(withTitle: "Use Translations Window")
        let useTranslationsWindow = getUserDefaultsUseTranslationsWindow()
        useTranslationsWindowMenuItem?.state = hideHomeReplies ? .on : .off
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

    func getUserDefaultsHideHomeReplies() -> Bool {
        let defaults = UserDefaults.standard
        if let hideHomeReplies = defaults.object(forKey: UserDefaultKeys.hideHomeReplies) as? Bool {
            return hideHomeReplies
        } else {
            return false
        }
    }

    func setUserDefaultsHideHomeReplies(_ hideHomeReplies: Bool) {
        UserDefaults.standard.set(
            hideHomeReplies,
            forKey: UserDefaultKeys.hideHomeReplies
        )
    }

    func getUserDefaultsUseTranslationsWindow() -> Bool {
        let defaults = UserDefaults.standard
        if let showTranslationsInModal = defaults.object(forKey: UserDefaultKeys.useTranslationsWindow) as? Bool {
            return showTranslationsInModal
        } else {
            return false
        }
    }

    func setUserDefaultsUseTranslationsWindow(_ showTranslationsInModal: Bool) {
        UserDefaults.standard.set(
            showTranslationsInModal,
            forKey: UserDefaultKeys.useTranslationsWindow
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

    func getMutedThreadUris() -> [String] {
        var mutedThreadsUris: [String] = []
        if let rootJsonData = localStorageMirror["root"]?.data(using:.utf8) {
            let rootLocalStorage = try? JSONDecoder().decode(
                RootLocalStorage.self,
                from: rootJsonData
            )
            if let mutedThreads = rootLocalStorage?.mutedThreads {
                mutedThreadsUris.append(contentsOf: mutedThreads.uris)
            }
        }
        return mutedThreadsUris
    }

    func getZoomFactor() -> Double {
        var zoomFactor = 1.0
        if let zoomFactorPref = UserDefaults.standard.object(
            forKey: UserDefaultKeys.zoomFactor) as? Double
        {
            zoomFactor = zoomFactorPref
        }
        return zoomFactor
    }

    func setZoomFactor(_ zoomFactor: Double) {
        UserDefaults.standard.set(zoomFactor, forKey: UserDefaultKeys.zoomFactor)
    }

    @IBAction func actionResetStatistics(_ sender: Any?) {
        mutedTermsHits = 0
    }

    func addMutedTermsHits(_ hits: Int) {
        mutedTermsHits += hits
    }


    static let ZOOM_FACTORS = [0.75, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.35]

    enum ZoomFactorPosition {
        case maxZoomedIn
        case maxZoomedOut
        case actualSize
        case other
    }

    func getZoomFactorPosition() -> ZoomFactorPosition {
        let ZOOM_FACTORS = AppDelegate.ZOOM_FACTORS
        let zoomFactor = getZoomFactor()
        if let pos = ZOOM_FACTORS.firstIndex(of: zoomFactor) {
            if pos == 0 {
                return .maxZoomedOut
            } else if pos == ZOOM_FACTORS.count - 1 {
                return .maxZoomedIn
            } else if pos == ZOOM_FACTORS.firstIndex(of: 1.0) {
                return .actualSize
            }
        }
        return .other
    }

}

extension AppDelegate: NSMenuDelegate {

    func menuNeedsUpdate(_ menu: NSMenu) {
        if menu.title == "View" {
            viewNeedsUpdate(menu)
        }
    }

    func viewNeedsUpdate(_ menu: NSMenu) {
        let zoomFactorPosition = getZoomFactorPosition()
        menu.item(withTitle: "Actual Size")?.isEnabled =
            zoomFactorPosition != .actualSize
        menu.item(withTitle: "Zoom In")?.isEnabled =
            zoomFactorPosition != .maxZoomedIn
        menu.item(withTitle: "Zoom Out")?.isEnabled =
            zoomFactorPosition != .maxZoomedOut
    }

}
