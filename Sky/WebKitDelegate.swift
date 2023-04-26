//
//  WebKitDelegate.swift
//  Sky
//

import Foundation
import WebKit

class WebKitDelegate: NSObject, WKNavigationDelegate {

    // Handle opening links in a new window
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            decisionHandler(WKNavigationActionPolicy.cancel)
            let request = navigationAction.request
            NSWorkspace.shared.open(request.url!)
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }

}
