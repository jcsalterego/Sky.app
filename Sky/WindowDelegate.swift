//
//  WindowDelegate.swift
//  Sky
//

import Foundation
import AppKit

class WindowDelegate: NSObject, NSWindowDelegate {

    let MIN_DESKTOP_WIDTH = 815.0
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
        let viewMenu = mainMenu.item(withTitle: "View")!.submenu!
        let desktopViewMenu = viewMenu.item(withTitle: "Desktop View")!.submenu!
        let compactViewMenu = viewMenu.item(withTitle: "Compact View")!.submenu!
        clearViewItemsUntilSeparator(viewMenu)
        if desktopMode {
            copySubmenuToBeginning(desktopViewMenu, viewMenu)
        } else {
            copySubmenuToBeginning(compactViewMenu, viewMenu)
        }
    }

    func copySubmenuToBeginning(_ sourceMenu: NSMenu?, _ targetMenu: NSMenu) {
        for index in 0..<sourceMenu!.numberOfItems {
            let srcMenuItem = sourceMenu!.item(at: index)!
            let menuItem = srcMenuItem.copy() as! NSMenuItem
            let modifierNumber = index + 1
            menuItem.keyEquivalent = "\(modifierNumber)"
            menuItem.keyEquivalentModifierMask = .command
            targetMenu.insertItem(menuItem, at: index)
        }
    }

    func clearViewItemsUntilSeparator(_ viewMenu: NSMenu) {
        var index = 0
        while index < viewMenu.numberOfItems {
            let menuItem = viewMenu.item(at: index)
            if menuItem?.isSeparatorItem == true {
                break
            } else if ["Desktop View", "Compact View"].contains(menuItem?.title) {
                index += 1
                continue
            } else {
                viewMenu.removeItem(at: index)
            }
        }
    }

}
