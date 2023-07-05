//
//  TranslationsEditorViewController.swift
//  Sky
//

import Foundation
import AppKit
import SwiftUI
import WebKit

class TranslationsViewController: NSViewController {

    @IBOutlet weak var webView: WKWebView!

    var webKitDelegate: TranslationsWebKitDelegate!
    var nextURL: URL?

    override func viewWillAppear() {
        super.viewWillAppear()
        if let url = nextURL {
            webView!.load(URLRequest(url: url))
            clearNextURL()
        }
    }

    override func loadView() {
        super.loadView()
        webKitDelegate = TranslationsWebKitDelegate()
        webView.navigationDelegate = webKitDelegate
        webView.uiDelegate = webKitDelegate
    }

    func setNextURL(_ url: URL) {
        nextURL = url
    }

    func clearNextURL() {
        nextURL = nil
    }

    func openURL(_ url: URL) {
        setNextURL(url)
    }

}
