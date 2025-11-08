//
//  AppViewViewController
//  Sky
//

import AppKit

class AppViewViewController: NSViewController {

    @IBAction func actionOKButtonClicked(_ sender: Any) {
        NSLog("OK")
        NSApplication.shared.stopModal()
        AppDelegate.shared.appViewWindowController?.close()
    }

    @IBAction func actionCancelButtonClicked(_ sender: Any) {
        NSLog("Cancel")
        NSApplication.shared.stopModal()
        AppDelegate.shared.appViewWindowController?.close()
    }

}
