//
//  MuteTermsEditorViewController.swift
//  Sky
//

import Foundation
import AppKit
import SwiftUI
import WebKit

class MuteTermsEditorViewController:
    NSViewController,
    NSTableViewDataSource,
    NSTableViewDelegate
{
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var addRemoveButtons: NSSegmentedControl!
    @IBOutlet weak var refreshIfNeededCheckbox: NSButton!

    let PLACEHOLDER_TEXT = "long eggs"

    var muteTerms: [MuteTerm] = []
    var needsReload = false

    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        needsReload = false

        // load muteTerms
        loadMuteTerms()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.doubleAction = #selector(actionMuteTermsEdit)
    }

    func loadMuteTerms() {
        let appMuteTerms = AppDelegate.shared.getMuteTerms()
        muteTerms.append(contentsOf: appMuteTerms)
    }

    func saveMuteTerms() {
        AppDelegate.shared.saveMuteTerms(muteTerms)
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

    @IBAction func actionMuteTermsEdit(_ sender: Any?) {
        let selectedRow = tableView.selectedRow
        let muteTerm = muteTerms[selectedRow]
        let alert = NSAlert()
        alert.messageText = "Edit mute term"
        alert.informativeText = "Mute terms are case-insensitive."
        let inputFrame = NSRect(
            x: 0,
            y: 0,
            width: 300,
            height: 24
        )
        let textField = NSTextField(frame: inputFrame)
        textField.placeholderString = PLACEHOLDER_TEXT
        textField.stringValue = muteTerm.value
        alert.accessoryView = textField
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = textField
        let action = alert.runModal()
        if action == .alertFirstButtonReturn {
            let stringValue = textField.stringValue
            updateMuteTerm(selectedRow, stringValue)
            changeData()
        }
    }

    func updateMuteTerm(_ row: Int, _ value : String) {
        muteTerms[row] = MuteTerm(value: value, isEnabled: true)
    }

    @IBAction func actionMuteTermsAddOrRemove(_ sender: Any?) {
        let selectedSegment = addRemoveButtons.selectedSegment
        if selectedSegment == 0 {
            actionMuteTermsAdd(sender)
        } else {
            actionMuteTermsRemove(sender)
        }

    }

    @IBAction func actionMuteTermsAdd(_ sender: Any?) {
        let alert = NSAlert()
        alert.messageText = "Add mute term"
        alert.informativeText = "Mute terms are case-insensitive."
        let inputFrame = NSRect(
            x: 0,
            y: 0,
            width: 300,
            height: 24
        )
        let textField = NSTextField(frame: inputFrame)
        textField.placeholderString = PLACEHOLDER_TEXT
        alert.accessoryView = textField
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = textField
        let action = alert.runModal()
        if action == .alertFirstButtonReturn {
            let stringValue = textField.stringValue
            addMuteTerm(stringValue)
            actionMuteTermsSave(nil)
        }
    }

    func addMuteTerm(_ muteTerm: String) {
        let trimmed = muteTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            muteTerms.append(MuteTerm(value: trimmed, isEnabled: true))
            changeData()
        }
    }

    func changeData() {
        tableView.reloadData()
        refreshButtons()
    }

    @IBAction func actionMuteTermsRemove(_ sender: Any?) {
        for rowIndex in tableView.selectedRowIndexes.sorted().reversed() {
            muteTerms.remove(at: rowIndex)
        }
        actionMuteTermsSave(nil)
        changeData()
    }

    @IBAction func actionMuteTermsSave(_ sender: Any?) {
        saveMuteTerms()
        needsReload = true
        refreshButtons()
    }

    @IBAction func actionMuteTermsClose(_ sender: Any?) {
        if needsReload && refreshIfNeededCheckbox.state == .on {
            AppDelegate.shared.mainViewController?.actionRefresh(nil)
        }
        view.window!.close()
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 21.0
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return muteTerms.count
    }

    func tableView(
        _ tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int
    ) -> NSView? {
        let currentMuteTerm = muteTerms[row]
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "muteTermColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "muteTermCell")
            if let cellView = tableView.makeView(
                withIdentifier: cellIdentifier,
                owner: self) as? NSTableCellView
            {
                cellView.textField?.stringValue = currentMuteTerm.value
                return cellView
            }
        }
        return nil
    }

}
