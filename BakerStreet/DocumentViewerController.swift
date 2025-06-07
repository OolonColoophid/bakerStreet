//
//  BKDocumentViewer.swift
//  Baker Street
//
//  Created by Ian Hocking on 24/07/2020.
//  Copyright © 2020 Ian. MIT Licence.
//

import Cocoa

// Displays and controls floating document windows (i.e. for rules, definitions and markdown)
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
            name: NSStoryboard.Name("DocumentView"),
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

        guard sender.recentSearches.count > 0 else {
            return
        }

        let mySearch = sender.recentSearches[0]

        let textToSearch  = documentTextView.string
        let rangeToSelect: NSRange

        if let mySearchRange = textToSearch.range(of: mySearch) {
            rangeToSelect = NSRange(mySearchRange, in: textToSearch)
            documentTextView.setSelectedRange(rangeToSelect)

            // Select the text
            searchField.tag = Int(NSFindPanelAction.setFindString.rawValue)
            documentTextView.performFindPanelAction(searchField)

            // Jump user to the text
            // This feels like a hack but seems to be the best way of
            // achieving a sensible behaviour (i.e. selection is highlighted)
            searchField.tag = Int(NSFindPanelAction.next.rawValue)
            documentTextView.performFindPanelAction(searchField)
            searchField.tag = Int(NSFindPanelAction.previous.rawValue)
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

        // We won't use the BKZoom functions here because we don't have
        // access to the original functions that produced the text (and those
        // functions put the font size in)

        if selectedSegment == 0 {

            let largerSize = NSMakeSize(1.2, 1.2)
            documentTextView.scaleUnitSquare(to: largerSize)

            updateDocumentContent()

        } else {

            let smallerSize = NSMakeSize(0.8, 0.8)
            documentTextView.scaleUnitSquare(to: smallerSize)

            updateDocumentContent()
        }

    }

}

extension DocumentViewController: BKZoomable {

}

// MARK: Printing
extension DocumentViewController {
    
    @IBAction func print(_ sender: Any) {
        printDocument()
    }
    
    @IBAction func runPageLayout(_ sender: Any) {
        showPageSetup()
    }
    
    func printDocument() {
        // Create a text view specifically for printing
        let printTextView = NSTextView()
        
        // Set the content to print
        let contentToPrint = createPrintableContent()
        
        // Configure the print text view
        printTextView.textStorage?.setAttributedString(contentToPrint)
        printTextView.isEditable = false
        printTextView.isSelectable = false
        
        // Set up print info
        let printInfo = NSPrintInfo.shared
        printInfo.topMargin = 50.0
        printInfo.bottomMargin = 50.0
        printInfo.leftMargin = 50.0
        printInfo.rightMargin = 50.0
        printInfo.isHorizontallyCentered = false
        printInfo.isVerticallyCentered = false
        
        // Create print operation
        let printOperation = NSPrintOperation(view: printTextView, printInfo: printInfo)
        printOperation.showsPrintPanel = true
        printOperation.showsProgressPanel = true
        
        // Set job title based on window title
        if let windowTitle = view.window?.title, !windowTitle.isEmpty {
            printOperation.jobTitle = windowTitle
        } else {
            printOperation.jobTitle = "Baker Street Document"
        }
        
        // Run the print operation
        printOperation.run()
    }
    
    func showPageSetup() {
        let printInfo = NSPrintInfo.shared
        let pageLayout = NSPageLayout()
        
        if let window = view.window {
            pageLayout.beginSheet(with: printInfo, modalFor: window) { (result) in
                if result == .OK {
                    // Page setup was accepted, print info is automatically updated
                }
            }
        }
    }
    
    private func createPrintableContent() -> NSAttributedString {
        let printContent = NSMutableAttributedString()
        
        // Add document title if available
        if let windowTitle = view.window?.title, !windowTitle.isEmpty {
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.boldSystemFont(ofSize: 16),
                .paragraphStyle: createCenteredParagraphStyle()
            ]
            let title = NSAttributedString(string: "\(windowTitle)\n\n", attributes: titleAttributes)
            printContent.append(title)
        }
        
        // Get the document content
        let documentContent = documentTextView.attributedString()
        
        // Create a copy with print-friendly formatting
        let printableContent = NSMutableAttributedString(attributedString: documentContent)
        
        printContent.append(printableContent)
        
        return printContent
    }
    
    private func createCenteredParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.spaceAfter = 10
        return paragraphStyle
    }
}

