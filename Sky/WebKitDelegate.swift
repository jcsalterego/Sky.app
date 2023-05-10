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

    func buildImageGifBase64(_ url : URL) -> String? {
        do {
            let data = try Data(contentsOf: url)
            let data64 = data.base64EncodedString()
            if let data64enc = data64.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                return "data:image/gif;base64,\(data64enc)"
            }
        } catch {
        }
        return nil
    }

    func addGifData(_ webView: WKWebView, _ svg : String) {
        if let blob = svg.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
            webView.evaluateJavaScript(
                Scripts.addGifData(blob)
            )
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
                    if let gifBase64 = self.buildImageGifBase64(url){
                        self.addGifData(webView, gifBase64)
                    }
                    completionHandler([url])
                }
            } else if result == NSApplication.ModalResponse.cancel {
                completionHandler(nil)
            }
        }
    }

}
