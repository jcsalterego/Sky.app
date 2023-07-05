//
//  WebKitDelegate.swift
//  Sky
//

import Foundation
import WebKit

class TranslationsWebKitDelegate: NSObject, WKNavigationDelegate, WKUIDelegate {

    // Handle opening links in a new window
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            decisionHandler(WKNavigationActionPolicy.cancel)
            let requestURL = navigationAction.request.url!
            let host = requestURL.host!
            if host == "translate.google.com" {
                let urlRequest = URLRequest(url: requestURL)
                webView.load(urlRequest)
            } else {
                NSWorkspace.shared.open(requestURL)
            }
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }

}
