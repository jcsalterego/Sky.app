//
//  TranslationsWindowController.swift
//  Sky
//

import AppKit

class TranslationsWindowController : NSWindowController, NSWindowDelegate {

    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.stopModal()
    }

    func openURL(_ url: URL) {
        if let viewController = self.contentViewController as? TranslationsViewController {
            viewController.openURL(url)
        }
    }

}
