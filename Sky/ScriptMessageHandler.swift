//
//  ScriptMessageHandler.swift
//

import WebKit

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {

    var logging = Bool()
    var viewController: ViewController!

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if message.name == "windowOpen" {
            windowOpen(message)
        } else if message.name == "consoleLog" {
            consoleLog(message)
        } else if message.name == "windowColorSchemeChange" {
            windowColorSchemeChange(message)
        } else if message.name == "fetch" {
            fetch(message)
        } else if message.name == "ctrlTab" {
            ctrlTab(message)
        } else {
            NSLog("unknown message: \(message)")
        }
    }

    func windowOpen(_ message: WKScriptMessage) {
        if let messageBody = message.body as? NSDictionary {
            if let url = messageBody["0"] as? String {
                NSLog("windowOpen \(url)")
                NSWorkspace.shared.open(URL.init(string: url)!)
            }
        }
    }

    func windowColorSchemeChange(_ message: WKScriptMessage) {
        if let messageBody = message.body as? NSDictionary {
            if let darkMode = messageBody["darkMode"] as? Int {
                if darkMode == 1 {
                    viewController.updateTitleBar(.dark)
                } else {
                    viewController.updateTitleBar(.light)
                }
            }
        }
    }

    func handleFetchListNotifications(_ doc : NSDictionary) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        if let notificationsList = doc["notifications"] as? [NSDictionary] {
            for notification in notificationsList {
                if let isRead = notification["isRead"] as? Int,
                   let uri = notification["uri"] as? String
                {
                    appDelegate.setNotificationReadStatus(uri: uri, isRead: isRead)
                }
            }
            appDelegate.refreshBadge()
        }
    }

    func fetch(_ message: WKScriptMessage) {
        if let messageBody = message.body as? NSDictionary {
            if let urlString = messageBody["url"] as? String,
               let response = messageBody["response"] as? NSDictionary
            {
                if urlString.contains("listNotifications") {
                    handleFetchListNotifications(response)
                }
            }
        }
    }

    func consoleLog(_ message: WKScriptMessage) {
        if let messageBody = message.body as? NSDictionary {
            NSLog("console.log: \(messageBody)")
        } else if let messageBody = message.body as? String {
            NSLog("console.log: \(messageBody)")
        } else if let messageBody = message.body as? [Any] {
            NSLog("console.log: \(messageBody)")
        } else {
            NSLog("console.log [unknown type \(type(of:message.body))]: \(message.body)")
        }
    }

    func ctrlTab(_ message: WKScriptMessage) {
        if let messageBody = message.body as? NSDictionary {
            if let direction = messageBody["direction"] as? Int {
                if direction == 1 {
                    viewController.actionNextTab(Optional.none)
                } else {
                    viewController.actionPrevTab(Optional.none)
                }
            }
        }
    }

}
