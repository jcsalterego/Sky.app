//
//  DevConsoleController.swift
//  Sky
//

import AppKit
import SwiftUI
import WebKit

class DevConsoleViewController : NSViewController {
    
    var hostingView: WKWebView!
    
    override func loadView() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.devConsoleViewController = self

        let webConfiguration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        let scriptMessageHandler = DevConsoleScriptMessageHandler()
        scriptMessageHandler.viewController = self
        userContentController.add(scriptMessageHandler, name: "consoleLog")
        userContentController.add(scriptMessageHandler, name: "triggerLoadAccessJwt")
        webConfiguration.userContentController = userContentController
        hostingView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = NSView(frame: CGRectMake(0.0, 0.0, 800, 600))
        view.addSubview(hostingView)
        hostingView.autoresizingMask = [.width, .height]
        hostingView.frame = view.frame
        
        let url = Bundle.main.url(
            forResource: "index",
            withExtension: "html",
            subdirectory: "DevConsole"
        )!
        let myRequest = URLRequest(url: url)
        hostingView.load(myRequest)
    }
    
    func populateAccessJwt() {
        NSLog("populateAccessJwt")
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        self.hostingView.evaluateJavaScript(
            JsLoader.loadScriptContents("Scripts/populate_access_jwt",
                ["access_jwt": appDelegate.accessJwt!])
        )

    }
    
}
