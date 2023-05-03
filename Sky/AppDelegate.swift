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

    func applicationDidBecomeActive(_ notification: Notification) {
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func setBadgeCount(_ count: Int) {
        if count != lastBadgeCount {
            if count == 0 {
                NSApp.dockTile.badgeLabel = nil
            } else {
                NSApp.dockTile.badgeLabel = String(count)
            }
            lastBadgeCount = count
        }
    }

}

