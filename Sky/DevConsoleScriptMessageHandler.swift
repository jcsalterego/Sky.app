//
//  DevConsoleScriptMessageHandler.swift
//  Sky
//

import WebKit

class DevConsoleScriptMessageHandler: NSObject, WKScriptMessageHandler {

    var logging = Bool()
    var viewController: DevConsoleViewController!

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if message.name == "consoleLog" {
            consoleLog(message)
        } else if message.name == "triggerLoadAccessJwt" {
            triggerLoadAccessJwt(message)
        } else {
            NSLog("unknown message: \(message)")
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

    func triggerLoadAccessJwt(_ message: WKScriptMessage) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let viewController = appDelegate.mainWindow?.contentViewController as! ViewController
        viewController.loadAccessJwt() { id, error in
            appDelegate.devConsoleViewController?.populateAccessJwt()
        }
    }

}
