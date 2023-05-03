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

}
