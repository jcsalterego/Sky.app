//
//  DevConsoleScriptMessageHandler.swift
//  Sky
//

import WebKit

class DevConsoleScriptMessageHandler : NSObject, WKScriptMessageHandler {

    var viewController: DevConsoleViewController!

    var nameFns:[String:(WKScriptMessage) -> Void] {
        return [
            "consoleLog": ScriptMessageHandler.consoleLog,
            "triggerLoadAccessJwt": triggerLoadAccessJwt,
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

    func triggerLoadAccessJwt(_ message: WKScriptMessage) {
        if let accessJwt = AppDelegate.shared.getActiveAccessJwt() {
            viewController?.setAccessJwt(accessJwt)
        }
    }

}
