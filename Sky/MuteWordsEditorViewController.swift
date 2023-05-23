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
    @IBOutlet weak var addRemoveButtons: NSSegmentedControl!
    @IBOutlet weak var refreshIfNeededCheckbox: NSButton!

    let PLACEHOLDER_TEXT = "long eggs"

    var muteWords: [MuteWord] = []
    var hasChanged = false
    var needsReload = false

    override func viewWillAppear() {
        super.viewWillAppear()
        NSLog("viewWillAppear")
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("viewDidLoad")

        hasChanged = false
        needsReload = false

        // load muteWords
        loadMuteWords()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.doubleAction = #selector(actionMuteWordsEdit)
    }

    func loadMuteWords() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let appMuteWords = appDelegate.getMuteWords()
        muteWords.append(contentsOf: appMuteWords)
    }

    func saveMuteWords() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.saveMuteWords(muteWords)
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        refreshButtons()
    }

    func refreshButtons() {
        let isEnabled = tableView.selectedRow != -1
        setRemoveButtonEnabled(isEnabled)
    }

    func setRemoveButtonEnabled(_ enabled: Bool) {
        addRemoveButtons.setEnabled(enabled, forSegment: 1)
    }

    @IBAction func actionMuteWordsEdit(_ sender: Any?) {
        NSLog("actionMuteWordsEdit")
        let selectedRow = tableView.selectedRow
        let muteWord = muteWords[selectedRow]

        // Set the message as the NSAlert text
        let alert = NSAlert()
        alert.messageText = "Edit mute word"
        alert.informativeText = "Mute words are case-insensitive."

        // Add an input NSTextField for the prompt
        let inputFrame = NSRect(
            x: 0,
            y: 0,
            width: 300,
            height: 24
        )

        let textField = NSTextField(frame: inputFrame)
        textField.placeholderString = PLACEHOLDER_TEXT
        textField.stringValue = muteWord.value
        alert.accessoryView = textField

        // Add a confirmation button “OK”
        // and cancel button “Cancel”
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        alert.window.initialFirstResponder = textField

        // Display the NSAlert
        let action = alert.runModal()

        if action == .alertFirstButtonReturn {
            let stringValue = textField.stringValue
            updateMuteWord(selectedRow, stringValue)
            changeData()
        }
    }

    func updateMuteWord(_ row: Int, _ value : String) {
        muteWords[row] = MuteWord(value: value, isEnabled: true)
    }

    @IBAction func actionMuteWordsAddOrRemove(_ sender: Any?) {
        let selectedSegment = addRemoveButtons.selectedSegment
        if selectedSegment == 0 {
            // add
            actionMuteWordsAdd(sender)
        } else {
            // remove
            actionMuteWordsRemove(sender)
        }

    }

    @IBAction func actionMuteWordsAdd(_ sender: Any?) {
        NSLog("actionMuteWordsAdd")

        // Set the message as the NSAlert text
        let alert = NSAlert()
        alert.messageText = "Add mute word"
        alert.informativeText = "Mute words are case-insensitive."

        // Add an input NSTextField for the prompt
        let inputFrame = NSRect(
            x: 0,
            y: 0,
            width: 300,
            height: 24
        )

        let textField = NSTextField(frame: inputFrame)
        textField.placeholderString = PLACEHOLDER_TEXT
        alert.accessoryView = textField

        // Add a confirmation button “OK”
        // and cancel button “Cancel”
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        alert.window.initialFirstResponder = textField

        // Display the NSAlert
        let action = alert.runModal()

        if action == .alertFirstButtonReturn {
            let stringValue = textField.stringValue
            addMuteWord(stringValue)
        }

        actionMuteWordsSave(nil)
    }

    func addMuteWord(_ muteWord: String) {
        let trimmed = muteWord.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            muteWords.append(MuteWord(value: trimmed, isEnabled: true))
            changeData()
        }
    }

    func changeData() {
        hasChanged = true
        tableView.reloadData()
        refreshButtons()
    }

    @IBAction func actionMuteWordsRemove(_ sender: Any?) {
        NSLog("actionMuteWordsRemove")
        let selectedRow = tableView.selectedRow
        muteWords.remove(at: selectedRow)
        actionMuteWordsSave(nil)
        changeData()
    }

    @IBAction func actionMuteWordsSave(_ sender: Any?) {
        NSLog("actionMuteWordsSave")

        saveMuteWords()
        hasChanged = false
        needsReload = true
        refreshButtons()
    }

    @IBAction func actionMuteWordsClose(_ sender: Any?) {
        NSLog("actionMuteWordsClose")

        if hasChanged {
            // Set the message as the NSAlert text
            let alert = NSAlert()
            alert.messageText = "Save changes before closing?"

            alert.addButton(withTitle: "Save")
            alert.addButton(withTitle: "Don't Save")
            alert.addButton(withTitle: "Cancel")

            // Display the NSAlert
            let action = alert.runModal()

            NSLog("action = \(action)")
            if action == .alertFirstButtonReturn {
                // save
                actionMuteWordsSave(nil)
            } else if action == .alertSecondButtonReturn {
                // don't save
            } else {
                // cancel
                return
            }
        }

        if needsReload && refreshIfNeededCheckbox.state == .on {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.mainViewController?.actionRefresh(nil)
        }
        view.window!.close()
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
