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
            windowOpen(message);
        } else if message.name == "lightModeChange" {
            lightModeChange(message)
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
    
    func lightModeChange(_ message: WKScriptMessage) {
        if let messageBody = message.body as? NSDictionary {
            if let innerText = messageBody["innerText"] as? String {
                if innerText == "Light mode" {
                    // going to dark mode
                    viewController.updateTitleBar(.dark)
                } else {
                    // going to light mode
                    viewController.updateTitleBar(.light)
                }
            }
        }
    }
    
}
