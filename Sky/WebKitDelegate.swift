//
//  WebKitDelegate.swift
//  Sky
//

import Foundation
import WebKit

class WebKitDelegate: NSObject, WKNavigationDelegate, WKUIDelegate {

    // Handle opening links in a new window
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            decisionHandler(WKNavigationActionPolicy.cancel)
            let requestURL = navigationAction.request.url!
            if requestURL.host!.starts(with: "staging.bsky.app")
                || requestURL.host!.starts(with: "bsky.app"
            ) {
                let url = URL(string: requestURL.absoluteString)
                let urlRequest = URLRequest(url: url!)
                webView.load(urlRequest)
            } else {
                NSWorkspace.shared.open(requestURL)
            }
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }

    func webView(
        _ webView: WKWebView,
        runOpenPanelWith parameters: WKOpenPanelParameters,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping ([URL]?) -> Void
    ) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.begin { (result) in
            if result == NSApplication.ModalResponse.OK {
                if let url = openPanel.url {
                    completionHandler([url])
                }
            } else if result == NSApplication.ModalResponse.cancel {
                completionHandler(nil)
            }
        }
    }

    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let alert = NSAlert()
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        let action = alert.runModal()
        completionHandler(action == .alertFirstButtonReturn)
    }

}
