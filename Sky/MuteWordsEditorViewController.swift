//
//  EditMuteWordsViewController.swift
//  Sky
//

import Foundation
import AppKit
import SwiftUI
import WebKit

class MuteWordsEditorViewController:
    NSViewController,
    NSTableViewDataSource,
    NSTableViewDelegate
{
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var editButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    @IBOutlet weak var saveAndApplyButton: NSButton!

    struct MuteWord {
        var value: String
        var isEnabled: Bool
    }

    var muteWords: [MuteWord] = []
    var hasChanged = false

    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // load muteWords
        muteWords.append(MuteWord(value: "test", isEnabled: true))
        muteWords.append(MuteWord(value: "foo bar", isEnabled: false))
        muteWords.append(MuteWord(value: "aloha", isEnabled: true))

        tableView.delegate = self
        tableView.dataSource = self

        tableView.doubleAction = #selector(actionMuteWordsEdit)
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let isEnabled = tableView.selectedRow != -1
        editButton.isEnabled = isEnabled
        removeButton.isEnabled = isEnabled
        saveAndApplyButton.isEnabled = hasChanged
    }

    @IBAction func actionMuteWordsEdit(_ sender: Any?) {
        NSLog("actionMuteWordsEdit")
        let clickedRow = tableView.clickedRow
        NSLog("clickedRow = \(clickedRow)")
    }

    @IBAction func actionMuteWordsAdd(_ sender: Any?) {
        NSLog("actionMuteWordsAdd")
    }

    @IBAction func actionMuteWordsRemove(_ sender: Any?) {
        NSLog("actionMuteWordsRemove")
        let clickedRow = tableView.clickedRow
        NSLog("clickedRow = \(clickedRow)")
    }

    @IBAction func actionMuteWordsSaveAndApply(_ sender: Any?) {
        NSLog("actionMuteWordsSaveAndApply")
    }

    @IBAction func actionMuteWordsCancel(_ sender: Any?) {
        NSLog("actionMuteWordsCancel")
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 21.0
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return muteWords.count
    }

    func tableView(
        _ tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int
    ) -> NSView? {
        let currentMuteWord = muteWords[row]
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "muteWordColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "muteWordCell")
            if let cellView = tableView.makeView(
                withIdentifier: cellIdentifier,
                owner: self) as? NSTableCellView
            {
                cellView.textField?.stringValue = currentMuteWord.value
                return cellView
            }
        }
        return nil
    }

}
