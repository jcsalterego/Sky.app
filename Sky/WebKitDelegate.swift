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
            let request = navigationAction.request
            NSWorkspace.shared.open(request.url!)
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

}
