//
//  JumpbarWindowController.swift
//  Sky
//

import AppKit

class JumpbarWindowController : NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.stopModal()
    }

}
