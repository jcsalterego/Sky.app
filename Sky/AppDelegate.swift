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
    var notifCounts = [String:Int]()

    func applicationDidBecomeActive(_ notification: Notification) {
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func clearNotifCounts() {
        notifCounts.removeAll()
    }

    func updateNotifCount(cursor: String, count: Int) {
        notifCounts[cursor] = count

        var totalCount = 0
        for (_, count) in notifCounts {
            totalCount += count
        }

        if totalCount != lastBadgeCount {
            if count == 0 {
                NSApp.dockTile.badgeLabel = nil
            } else {
                NSApp.dockTile.badgeLabel = String(totalCount)
            }
            lastBadgeCount = totalCount
        }
    }

}
