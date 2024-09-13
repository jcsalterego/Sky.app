//
//  WindowDelegate.swift
//  Sky
//

import Foundation
import AppKit

class WindowDelegate: NSObject, NSWindowDelegate {

    let MIN_DESKTOP_WIDTH = 1230.0
    var lastDesktopMode: Bool? = nil

    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        updateWindowDesktopMode(frameSize.width)
        return frameSize
    }

    func updateWindowDesktopMode(_ frameWidth: CGFloat) {
        let desktopMode = frameWidth >= MIN_DESKTOP_WIDTH
        if lastDesktopMode != desktopMode {
            lastDesktopMode = desktopMode

            updateViewNavigation(desktopMode)
        }
    }

    func updateViewNavigation(_ desktopMode: Bool) {
        let mainMenu = NSApplication.shared.mainMenu!
        let viewMenu = mainMenu.item(withTitle: "View")?.submenu

        let homeMenuItem = viewMenu?.item(withTitle: "Home")
        let searchMenuItem = viewMenu?.item(withTitle: "Search")
        let notificationsMenuItem = viewMenu?.item(withTitle: "Notifications")
        let chatMenuItem = viewMenu?.item(withTitle: "Chat")
        let feedsMenuItem = viewMenu?.item(withTitle: "Feeds")
        let listsMenuItem = viewMenu?.item(withTitle: "Lists")
        let profileMenuItem = viewMenu?.item(withTitle: "Profile")
        let settingsMenuItem = viewMenu?.item(withTitle: "Settings")

        showMenuItem(homeMenuItem!, commandNumber: 1)
        showMenuItem(searchMenuItem!, commandNumber: 2)

        if desktopMode {
            showMenuItem(notificationsMenuItem!, commandNumber: 3)
            showMenuItem(chatMenuItem!, commandNumber: 4)
            showMenuItem(feedsMenuItem!, commandNumber: 5)
            showMenuItem(listsMenuItem!, commandNumber: 6)
            showMenuItem(profileMenuItem!, commandNumber: 7)
            showMenuItem(settingsMenuItem!, commandNumber: 8)
        } else {
            hideMenuItem(notificationsMenuItem!)
            showMenuItem(chatMenuItem!, commandNumber: 3)
            showMenuItem(notificationsMenuItem!, commandNumber: 4)
            hideMenuItem(feedsMenuItem!)
            hideMenuItem(listsMenuItem!)
            showMenuItem(profileMenuItem!, commandNumber: 5)
            hideMenuItem(settingsMenuItem!)
        }
    }

    func showMenuItem(_ menuItem: NSMenuItem, commandNumber: Int) {
        menuItem.isHidden = false
        menuItem.keyEquivalent = "\(commandNumber)"
        menuItem.keyEquivalentModifierMask = .command
    }

    func hideMenuItem(_ menuItem: NSMenuItem) {
        menuItem.isHidden = true
        menuItem.keyEquivalent = ""
        menuItem.keyEquivalentModifierMask = NSEvent.ModifierFlags()
    }

}
