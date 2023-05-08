//
//  JsLoader.swift
//

import Foundation
import WebKit

class JsLoader {

    class func loadWKUserScript(
        _ name: String,
        _ context: [String: String] = [:]
    ) -> WKUserScript {
        let source = JsLoader.loadScriptContents(name, context)
        return WKUserScript(
            source: source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
    }

    class func loadScriptContents(
        _ name: String,
        _ context: [String: String] = [:]
    ) -> String {
        let myFileURL = Bundle.main.url(forResource: name, withExtension: "js")
        var myText = try! String(contentsOf: myFileURL!, encoding: String.Encoding.utf8)
        for (key, value) in context {
            let jsKey = "$__\(key.uppercased())__"
            myText = myText.replacingOccurrences(of: jsKey, with: value)
        }
        if myText.contains("$LOG") {
            myText = myText.replacingOccurrences(
                of: "$LOG",
                with: "window.webkit.messageHandlers.consoleLog.postMessage"
            )
        }
        return myText
    }

}
