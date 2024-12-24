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
                AppDelegate.shared.openURL(url)
            }
        }
    }

    func windowReload(_ message: WKScriptMessage) {
        viewController.webView.reload()
    }

    func windowColorSchemeChange(_ message: WKScriptMessage) {
        if let messageBody = message.body as? NSDictionary {
            if let colorScheme = messageBody["colorScheme"] as? String,
               let darkMode = messageBody["darkMode"] as? Int,
               let backgroundColor = messageBody["backgroundColor"] as? String
            {
                // NSLog("colorScheme: \(colorScheme), darkMode: \(darkMode), backgroundColor: \(backgroundColor)")
                if darkMode == 1 {
                    viewController.updateTitleBar(.dark, backgroundColor: backgroundColor)
                } else {
                    viewController.updateTitleBar(.light, backgroundColor: backgroundColor)
                }
            }
        }
    }

    func handleFetchListNotifications(_ doc : NSDictionary) {
        if let notificationsList = doc["notifications"] as? [NSDictionary] {
            var mutedThreadUris: [String] = []
            if notificationsList.count > 0 {
                mutedThreadUris = AppDelegate.shared.getMutedThreadUris()
            }
            for notification in notificationsList {
                if mutedThreadUris.count > 0,
                   let record = notification["record"] as? NSDictionary,
                   let recordReply = record["reply"] as? NSDictionary,
                   let recordReplyRoot = recordReply["root"] as? NSDictionary,
                   let recordReplyRootUri = recordReplyRoot["uri"] as? String,
                   mutedThreadUris.contains(recordReplyRootUri)
                {
                    continue
                }
                if let isRead = notification["isRead"] as? Int,
                   let uri = notification["uri"] as? String
                {
                    AppDelegate.shared.setNotificationReadStatus(uri: uri, isRead: isRead)
                }
            }
            AppDelegate.shared.refreshBadge()
        }
    }

    func handleFetchListConversations(_ doc : NSDictionary) {
        if let convosList = doc["convos"] as? [NSDictionary] {
            var mutedThreadUris: [String] = []
            for convo in convosList {
                if let convoId = convo["id"] as? String,
                   let convoUnreadCount = convo["unreadCount"] as? Int
                {
                    AppDelegate.shared.setConvoUnreadCount(
                        id: convoId, unreadCount: convoUnreadCount
                    )
                }
            }
            AppDelegate.shared.refreshBadge()
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
                if urlString.contains("listConvos") {
                    handleFetchListConversations(response)
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

    func localStorageSetItem(_ message: WKScriptMessage) {
        if let messageBody = message.body as? NSDictionary {
            if let args = messageBody["args"] as? [String] {
                if args.count == 2 {
                    let itemKey = args[0]
                    let jsonValue = args[1]
                    AppDelegate.shared.setLocalStorage(key: itemKey, jsonValue: jsonValue)
                }
            }
        }
    }

}
