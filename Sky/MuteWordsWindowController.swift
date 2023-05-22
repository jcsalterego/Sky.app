//
//  MuteWordsWindowController.swift
//  Sky
//

import AppKit

class MuteWordsWindowController : NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.delegate = self
    }

    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.stopModal()
    }

}
