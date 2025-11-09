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
            let appViewHost = AppDelegate.shared.getAppViewHost()
            let host = requestURL.host!
            if host == appViewHost {
                webView.load(navigationAction.request)
            } else if host == "staging.bsky.app" && appViewHost == "bsky.app" {
                var urlString = requestURL.absoluteString
                urlString = urlString.replacingOccurrences(
                    of: "//staging.bsky.app/",
                    with: "//bsky.app/")
                let url = URL(string: urlString)
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

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures) -> WKWebView?
    {
        // open link in new window
        // open image in new window
        NSWorkspace.shared.open(navigationAction.request.url!)
        return nil
    }

}
