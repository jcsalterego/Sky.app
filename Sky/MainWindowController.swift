//
//  MainWindowController
//  Sky
//

import AppKit

class MainWindowController : NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Ensure the window exists
        if self.window == nil {
            return
        }

        let currentMinWidth = AppDelegate.shared.getMinimumWindowWidth()
        let advancedSubmenu = NSApplication.shared.mainMenu?
            .item(withTitle: "Advanced")?.submenu
        let setMinimumWindowWidthSubmenu = advancedSubmenu?.item(withTitle: "Set Minimum Window Width")?.submenu
        for item in setMinimumWindowWidthSubmenu?.items ?? [] {
            if item.title == "\(currentMinWidth)pt" {
                item.state = .on
            } else {
                item.state = .off
            }
        }
    }

}
