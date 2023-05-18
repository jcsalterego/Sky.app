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

    class func resolveIncludePath(_ includeFile: String, referencePath: String) -> String {
        var resolvedPath = includeFile
        if !includeFile.contains("/") {
            let words = referencePath.split(separator: "/")
            if words.count > 1 {
                var slice = words[..<(words.count-1)].compactMap { substring in
                    String(substring)
                }
                slice.append(includeFile)
                resolvedPath = slice.joined(separator: "/")
            }
        }
        return resolvedPath
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
        if myText.contains("$INCLUDE") {
            var finalLines: [String] = []
            let lines = myText.components(separatedBy: "\n")
            for idx in lines.indices {
                var found = false
                let line = lines[idx]
                if let regex = try? NSRegularExpression(pattern: "\\$INCLUDE\\(['\"](.+)['\"]\\)", options: []) {
                    let nsRange = NSRange(myText.startIndex..., in: line)
                    let matches = regex.matches(in: line, range: nsRange)
                    for match in matches {
                        let firstMatchRange = match.range(at: 1)
                        let swiftRange = Range(firstMatchRange, in: myText)
                        let includeFile = myText[swiftRange!]
                        var includePath = resolveIncludePath(String(includeFile), referencePath: name)
                        includePath = includePath.replacingOccurrences(of: ".js", with: "")
                        let innerScript = loadScriptContents(includePath)
                        for innerScriptLine in innerScript.components(separatedBy: "\n") {
                            finalLines.append(innerScriptLine)
                        }
                        found = true
                    }
                }
                if !found {
                    finalLines.append(line)
                }
            }
            myText = finalLines.joined(separator: "\n")
        }
        return myText
    }

}
