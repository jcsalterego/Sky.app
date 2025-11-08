//
//  AppViewViewController
//  Sky
//

import AppKit

class AppViewViewController: NSViewController {

    @IBAction func actionOKButtonClicked(_ sender: Any) {
        NSLog("OK")
        if let appViewWindowController = AppDelegate.shared.appViewWindowController {
            NSLog("appViewWindowController = \(appViewWindowController)")
        }
    }

    @IBAction func actionCancelButtonClicked(_ sender: Any) {
        NSLog("Cancel")
        if let appViewWindowController = AppDelegate.shared.appViewWindowController {
            NSLog("appViewWindowController = \(appViewWindowController)")
        }
    }

}
