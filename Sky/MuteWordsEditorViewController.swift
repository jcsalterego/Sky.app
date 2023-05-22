//
//  EditMuteWordsViewController.swift
//  Sky
//

import Foundation
import AppKit
import SwiftUI
import WebKit

class MuteWordsEditorViewController : NSViewController {

    override func loadView() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.muteWordsEditorViewController = self
    }

}
