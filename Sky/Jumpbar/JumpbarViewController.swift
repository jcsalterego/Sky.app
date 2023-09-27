//
//  JumpbarEditorViewController.swift
//  Sky
//

import Foundation
import AppKit
import SwiftUI
import WebKit

class JumpbarViewController:
    NSViewController,
    NSTextFieldDelegate,
    NSTableViewDataSource,
    NSTableViewDelegate
{
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!

    var jumpbarItems: [JumpbarItem] = []

    override func viewWillAppear() {
        super.viewWillAppear()
        loadJumpbarItems()
        textField.stringValue = ""
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }

    func controlTextDidChange(_ obj: Notification) {
        if let _ = obj.object as? NSTextField {
            refreshList()
        }
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.cancelOperation(_:))) {
            closeWindow()
            return true
        } else if (commandSelector == #selector(NSResponder.moveUp(_:))) {
            selectTableView(-1)
            return true
        } else if (commandSelector == #selector(NSResponder.moveDown(_:))) {
            selectTableView(1)
            return true
        } else if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            chooseSelection()
            return true
        }
        return false
    }

    func chooseSelection() {
        let row = tableView.selectedRow
        if row > -1 {
            let item = filteredItems()[row]

            let mainViewController = AppDelegate.shared.mainViewController
            switch item.destination {
            case .home:
                mainViewController?.actionViewHome(nil)
                break
            case .search:
                mainViewController?.actionViewSearch(nil)
                break
            case .feeds:
                mainViewController?.actionViewFeeds(nil)
                break
            case .feed:
                mainViewController?.goToFeed(item.value)
                break
            case .notifications:
                mainViewController?.actionViewNotifications(nil)
                break
            case .moderation:
                mainViewController?.actionViewModeration(nil)
                break
            case .profile:
                mainViewController?.actionViewProfile(nil)
                break
            case .settings:
                mainViewController?.actionViewSettings(nil)
                break
            default:
                break
            }

            closeWindow()
        }
    }

    func closeWindow() {
        AppDelegate.shared.jumpbarWindowController?.close()
    }

    func selectTableView(_ direction: Int) {
        var selected = tableView.selectedRow
        let numRows = tableView.numberOfRows
        if numRows == 0 {
            return
        }

        if selected == -1 {
            if direction == -1 {
                selected = numRows - 1
            } else if direction == 1 {
                selected = 0
            }
        } else {
            selected += direction
        }
        selected = min(selected, numRows - 1)
        selected = max(selected, 0)

        tableView.selectRowIndexes(
            IndexSet(integer: selected),
            byExtendingSelection: false
        )
    }

    func loadJumpbarItems() {
        jumpbarItems.removeAll()

        jumpbarItems.append(JumpbarItem(
            label: "Home", value: "home", destination: .home))
        jumpbarItems.append(JumpbarItem(
            label: "Search", value: "search", destination: .search))
        jumpbarItems.append(JumpbarItem(
            label: "Feeds", value: "feeds", destination: .feeds))

        let localStorageMirror = AppDelegate.shared.localStorageMirror
        if let rootJsonData = localStorageMirror["root"]?.data(using:.utf8) {
            let rootLocalStorage = try? JSONDecoder().decode(
                RootLocalStorage.self,
                from: rootJsonData
            )
            if let preferences = rootLocalStorage?.preferences {
                if let savedFeeds = preferences.savedFeeds {
                    for savedFeed in savedFeeds {
                        let words = savedFeed.split(separator: "/")
                        let shortFeedName = words[words.count - 1]
                        jumpbarItems.append(JumpbarItem(
                            label: "Feed: \(shortFeedName)", value: savedFeed, destination: .feed))
                    }
                }
            }
        }

        jumpbarItems.append(JumpbarItem(
            label: "Notifications", value: "notifications", destination: .notifications))
        jumpbarItems.append(JumpbarItem(
            label: "Moderation", value: "moderation", destination: .moderation))
        jumpbarItems.append(JumpbarItem(
            label: "Profile", value: "profile", destination: .profile))
        jumpbarItems.append(JumpbarItem(
            label: "Settings", value: "settings", destination: .settings))
    }

    func refreshList() {
        tableView.reloadData()
        if tableView.selectedRow == -1 && tableView.numberOfRows > 0 {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredItems().count
    }

    func filteredItems() -> [JumpbarItem] {
        return filteredItems(textField.stringValue, jumpbarItems)
    }

    func filteredItems(
        _ searchText: String,
        _ jumpbarItems: [JumpbarItem]
    ) -> [JumpbarItem] {
        if searchText.count == 0 {
            return jumpbarItems
        } else {
            return jumpbarItems.filter {
                $0.value.contains(searchText)
            }
        }
    }

    func tableView(
        _ tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int
    ) -> NSView? {
        let items = filteredItems()
        let currentJumpbarItem = items[row]
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "jumpItemColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "jumpItemCell")
            if let cellView = tableView.makeView(
                withIdentifier: cellIdentifier,
                owner: self) as? NSTableCellView
            {
                cellView.textField?.stringValue = currentJumpbarItem.label
                return cellView
            }
        }
        return nil
    }

}
