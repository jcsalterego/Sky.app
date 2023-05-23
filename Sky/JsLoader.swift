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
        _ scriptPath: String,
        _ context: [String: String] = [:]
    ) -> String {
        let scriptURL = Bundle.main.url(forResource: scriptPath, withExtension: "js")
        var scriptContents = try! String(contentsOf: scriptURL!, encoding: String.Encoding.utf8)
        for (key, value) in context {
            let jsKey = "$__\(key.uppercased())__"
            scriptContents = scriptContents.replacingOccurrences(of: jsKey, with: value)
        }
        scriptContents = scriptContents.replacingOccurrences(
            of: "export function",
            with: "function"
        )
        if scriptContents.contains("$LOG") {
            scriptContents = scriptContents.replacingOccurrences(
                of: "$LOG",
                with: "window.webkit.messageHandlers.consoleLog.postMessage"
            )
        }
        if scriptContents.contains("$INCLUDE") {
            let regex = try? NSRegularExpression(pattern: "\\$INCLUDE\\(['\"]([^'\"]+)['\"]\\)", options: [])
            var finalLines: [String] = []
            let lines = scriptContents.components(separatedBy: "\n")
            for line in lines {
                var found = false
                let nsRange = NSRange(line.startIndex..., in: line)
                let matches = regex!.matches(in: line, range: nsRange)
                for match in matches {
                    let firstMatchRange = match.range(at: 1)
                    let swiftRange = Range(firstMatchRange, in: line)
                    let includeFile = line[swiftRange!]
                    var includePath = resolveIncludePath(String(includeFile), referencePath: scriptPath)
                    includePath = includePath.replacingOccurrences(of: ".js", with: "")
                    let innerScript = loadScriptContents(includePath)
                    for innerScriptLine in innerScript.components(separatedBy: "\n") {
                        finalLines.append(innerScriptLine)
                    }
                    found = true
                }
                if !found {
                    finalLines.append(line)
                }
            }
            scriptContents = finalLines.joined(separator: "\n")
        }
        return scriptContents
    }

}
