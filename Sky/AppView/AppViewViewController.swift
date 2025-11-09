//
//  AppViewViewController
//  Sky
//

import AppKit

class AppViewViewController: NSViewController {

    @IBOutlet weak var appHostPopUpButton: NSPopUpButton!

    @IBAction func actionOKButtonClicked(_ sender: Any) {
        NSLog("OK")
        NSApplication.shared.stopModal()

        let selectedAppHost = getSelectedAppHost()

        // parse "Name (host)" to get host with regex
        if let selectedAppHost = selectedAppHost {
            let pattern = "\\((.*?)\\)"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: selectedAppHost, options: [], range: NSRange(location: 0, length: selectedAppHost.utf16.count)) {
                if let range = Range(match.range(at: 1), in: selectedAppHost) {
                    let currentAppHost = AppDelegate.shared.getAppViewHost()
                    let selectedHost = String(selectedAppHost[range])
                    if currentAppHost != selectedHost {
                        let alert = NSAlert()
                        alert.messageText = "Switch App View to \(selectedAppHost)?"
                        alert.addButton(withTitle: "Yes")
                        alert.addButton(withTitle: "No")
                        let action = alert.runModal()
                        if action == .alertFirstButtonReturn {
                            AppDelegate.shared.setAppViewHost(selectedHost)
                            AppDelegate.shared.mainViewController?.loadHome()
                        }
                    }
                }
            }
        }

        AppDelegate.shared.appViewWindowController?.close()
    }

    @IBAction func actionCancelButtonClicked(_ sender: Any) {
        NSLog("Cancel")
        NSApplication.shared.stopModal()
        AppDelegate.shared.appViewWindowController?.close()
    }

    func getSelectedAppHost() -> String? {
        return appHostPopUpButton.titleOfSelectedItem
    }

}
