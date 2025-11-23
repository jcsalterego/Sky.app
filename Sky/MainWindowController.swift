//
//  MainWindowController
//  Sky
//

import AppKit

class MainWindowController : NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Ensure the window exists
        guard let window = self.window else {
            return
        }
        let currentMinWidth = AppDelegate.shared.getUserDefaultMinimumWindowWidth()
        var currentMinHeight = window.contentMinSize.height
        if currentMinHeight == 0 {
            currentMinHeight = 667
        }
        let contentMinSize = NSSize(
            width: CGFloat(currentMinWidth),
            height: currentMinHeight
        )
        window.contentMinSize = contentMinSize

        let key = "NSWindow Frame MainWindow"
        if let rectString = UserDefaults.standard.string(forKey: key) {
            var rect = NSRectFromString(rectString)
            if rect.height < contentMinSize.height {
                rect = NSRect(
                    x: rect.origin.x,
                    y: rect.origin.y,
                    width: rect.width,
                    height: contentMinSize.height
                )
            }
            if rect.width < contentMinSize.width {
                rect = NSRect(
                    x: rect.origin.x,
                    y: rect.origin.y,
                    width: contentMinSize.width,
                    height: rect.height
                )
            }
            window.setContentSize(rect.size)
        } else {
            window.setContentSize(contentMinSize)
            window.center()
        }

        let advancedSubmenu = NSApplication.shared.mainMenu?
            .item(withTitle: "Advanced")?.submenu
        let setUserDefaultMinimumWindowWidthSubmenu = advancedSubmenu?.item(withTitle: "Set Minimum Window Width")?.submenu
        for item in setUserDefaultMinimumWindowWidthSubmenu?.items ?? [] {
            if item.title == "\(currentMinWidth)pt" {
                item.state = .on
            } else {
                item.state = .off
            }
        }
    }

}
