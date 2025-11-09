//
//  AppViewWindowController
//  Sky
//

import AppKit

class AppViewWindowController : NSWindowController {

    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.stopModal()
    }

}
