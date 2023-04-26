//
//  JsLoader.swift
//

import Foundation

class JsLoader {

    class func loadJs(_ name: String, _ context: [String: String] = [:]) -> String {
        let myFileURL = Bundle.main.url(forResource: name, withExtension: "js")
        var myText = try! String(contentsOf: myFileURL!, encoding: String.Encoding.utf8)
        for (key, value) in context {
            let jsKey = "$__\(key.uppercased())__"
            myText = myText.replacingOccurrences(of: jsKey, with: value)
        }
        return myText
    }

}
