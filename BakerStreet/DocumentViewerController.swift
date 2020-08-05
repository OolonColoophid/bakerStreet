//
//  BKDocumentViewer.swift
//  Baker Street
//
//  Created by ian.user on 24/07/2020.
//  Copyright © 2020 Ian. All rights reserved.
//

import Cocoa

class DocumentViewController: NSViewController, NSSearchFieldDelegate {

    var documentText = NSMutableAttributedString()

    @IBOutlet var documentTextView: NSTextView!
    @IBOutlet weak var searchField: NSSearchField!

    @IBOutlet weak var searchButton: NSSegmentedControl!

    @IBOutlet weak var zoomButton: NSSegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // We want to become a delegate for our search field
        searchField.delegate = self

        // Only search for text when user has entered it and pressed return
        searchField.sendsWholeSearchString = true

        // Make selection be start of text view
        resetSelection()

    }

    public func set(_ text: NSMutableAttributedString) {

        documentText = text

        updateDocumentContent()

    }

    public func updateDocumentContent() {

        documentTextView.string = ""
        documentTextView.textStorage?.insert(documentText, at: 0)

    }

}

extension DocumentViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> DocumentViewController {
        //1. Get a reference to Main.storyboard.
        let storyboard = NSStoryboard(
            name: NSStoryboard.Name("Main"),
            bundle: nil)
        //2. Create a Scene identifier that matches
        // the one I set in the storyboard.
        let identifier = NSStoryboard.SceneIdentifier("DocumentViewController")
        //3. Instantiate DocumentViewController and return it.
        guard let viewcontroller = storyboard.instantiateController(
            withIdentifier: identifier) as? DocumentViewController else {
                fatalError("DocumentViewController not found")
        }
        return viewcontroller
    }
}

// MARK: NSSearchFieldDelegate
extension DocumentViewController {
    func searchFieldDidEndSearching(_ sender: NSSearchField) {

        searchField.tag = Int(NSFindPanelAction.setFindString.rawValue)

        resetSelection()

        hideButtons()
    }

    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        print("Started searching")
        print(sender.recentSearches)

        guard sender.recentSearches.count > 0 else {
            return
        }

        let mySearch = sender.recentSearches[0]

        print("We are searching for: \(mySearch)")

        let textToSearch  = documentTextView.string
        let rangeToSelect: NSRange

        if let mySearchRange = textToSearch.range(of: mySearch) {
            rangeToSelect = NSRange(mySearchRange, in: textToSearch)
            documentTextView.setSelectedRange(rangeToSelect)
            searchField.tag = Int(NSFindPanelAction.setFindString.rawValue)

            documentTextView.performFindPanelAction(searchField)

            showButtons()
        }

    }
}

// MARK: User Inerface
extension DocumentViewController {

    @IBAction func searchButtonClicked(_ sender: Any) {

        let control = sender as! NSSegmentedControl
        let selectedSegment = control.selectedSegment

        if selectedSegment == 0 {
            searchPrevious()
        } else {
            searchNext()
        }
    }

    func searchPrevious() {
        searchField.tag = Int(NSFindPanelAction.previous.rawValue)

        documentTextView.performFindPanelAction(searchField)

    }
    func searchNext() {
        searchField.tag = Int(NSFindPanelAction.next.rawValue)

        documentTextView.performFindPanelAction(searchField)

    }

    func showButtons() {
        searchButton.isHidden = false
    }

    func hideButtons() {
        searchButton.isHidden = true
    }

    func resetSelection() {

        let noRange = NSRange(location: 0, length: 0)

        documentTextView.setSelectedRange(noRange)

    }

    @IBAction func buttonZoom(_ sender: Any)
    {

        let button = sender as! NSSegmentedControl
        let selectedSegment = button.selectedSegment

        if selectedSegment == 0 {
            BKzoomIn(documentTextView)
            updateDocumentContent()
        } else {
            BKzoomOut(documentTextView)
            updateDocumentContent()
        }

    }

}

extension DocumentViewController: BKZoomable {

}

