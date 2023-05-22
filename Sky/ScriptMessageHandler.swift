//
//  ScriptMessageHandler.swift
//

import WebKit

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {

    var logging = Bool()
    var viewController: ViewController!

    var nameFns:[String:(WKScriptMessage) -> Void] {
        return [
            "consoleLog": ScriptMessageHandler.consoleLog,
            "ctrlTab": ctrlTab,
            "fetch": fetch,
            "loadAccessJwt": loadAccessJwt,
            "localStorageSetItem": localStorageSetItem,
            "windowColorSchemeChange": windowColorSchemeChange,
            "windowOpen": windowOpen,
            "windowReload": windowReload,
        ]
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if let fn = nameFns[message.name] {
            fn(message)
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

    func windowReload(_ message: WKScriptMessage) {
        viewController.webView.reload()
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

    class func consoleLog(_ message: WKScriptMessage) {
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

    func loadAccessJwt(_ message: WKScriptMessage) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        if let messageBody = message.body as? NSDictionary {
            if let accessJwt = messageBody["accessJwt"] as? String {
                appDelegate.accessJwt = accessJwt
            }
        }
    }

    func localStorageSetItem(_ message: WKScriptMessage) {
        if let messageBody = message.body as? NSDictionary {
            if let args = messageBody["args"] as? [String] {
                if args.count == 2 {
                    let itemKey = args[0]
                    let jsonValue = args[1]
                    let appDelegate = NSApplication.shared.delegate as! AppDelegate
                    appDelegate.setLocalStorage(key: itemKey, jsonValue: jsonValue)
                }
            }
        }
    }

}
