//
//  PreviewViewController.swift
//  Baker Street
//
//  Created by ian.user on 29/07/2020.
//  Copyright © 2020 Ian. All rights reserved.
//

import Cocoa

class PreviewViewController: NSViewController {

    var previewText = NSMutableAttributedString()

    var eProof: ExportedProof?

    @IBOutlet var previewTextView: NSTextView!

    @IBOutlet weak var zoomButton: NSSegmentedControl!

    @IBOutlet weak var copyAs: NSPopUpButton!

    @IBOutlet weak var exportAs: NSPopUpButton!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    private func updateDocumentContent() {

        // Add styling
        let style = DocumentStyles.baseStyle

        previewTextView.string = ""

        let newText = (style + (eProof?.htmlVLN ?? "")).htmlToNSMAS()
        previewTextView.textStorage?.insert(newText, at: 0)

    }

}

// MARK: BKProofDelegate

extension PreviewViewController: BKProofDelegate {
    func proofDidCompleteExport(withExportedProoof newEProof: ExportedProof) {

        eProof = newEProof

        updateDocumentContent()

    }
}

// MARK: Copy As

extension PreviewViewController {

    enum copyActions: String {
        case latex
        case html
        case markdown

        var description: String {
            switch self {
                case .latex:
                    return "LaTeX"
                case .html:
                    return "HTML"
                case .markdown:
                    return "Markdown"
            }
        }
    }

    @IBAction func buttonCopyAs(_ sender: NSPopUpButton) {

        let myAction = sender.selectedItem!.title

        switch myAction {
            case copyActions.latex.description:

                copyTextToClipboard(eProof?.latex ?? "")
                break

            case copyActions.html.description:

                copyTextToClipboard(eProof?.htmlVLN ?? "")
                break

            case copyActions.markdown.description:

                copyTextToClipboard(eProof?.markdown ?? "")
                break

            default:

                copyTextToClipboard(eProof?.markdown ?? "")

        }

    }



    private func copyTextToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }



}

// MARK: Export As

extension PreviewViewController {

    enum exportExtensions: String {
        case latex
        case markdown
        case html

        public var description: String {
            switch self {
                case .latex:
                    return "tex"
                case .markdown:
                    return "md"
                case .html:
                    return "html"
            }
        }

    }

    @IBAction func buttonExportAs(_ sender: NSPopUpButton) {

        let myAction = sender.selectedItem!.title

        switch myAction {

            case copyActions.html.description:

                exportFile(withText: eProof?.htmlVLN ?? "",
                           withExtension: exportExtensions.html.description)
                break

            case copyActions.markdown.description:

                exportFile(withText: eProof?.markdown ?? "",
                           withExtension: exportExtensions.markdown.description)
                break

            default: // latex

                exportFile(withText: eProof?.latex ?? "",
                           withExtension: exportExtensions.latex.description)

        }

    }

    private func exportFile(withText text: String,
                            withExtension myExtension: String) {

        // Todo: Set
        // savePanel.allowedFileTypes

        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = "export.\(myExtension)"

        savePanel.begin {

            if $0 == .OK {
                let filename = savePanel.url

                do {
                    try text.write(to: filename!,
                                   atomically: true,
                                   encoding: String.Encoding.utf8)
                } catch {
                    // failed to write file (bad permissions, bad filename etc.)
                }

            }

        }
        
    }

}


// MARK: Storyboard Instantiation

extension PreviewViewController {

    static func freshController() -> PreviewViewController {
        //1. Get a reference to Main.storyboard.
        let storyboard = NSStoryboard(
            name: NSStoryboard.Name("Main"),
            bundle: nil)
        //2. Create a Scene identifier that matches
        // the one I set in the storyboard.
        let identifier = NSStoryboard.SceneIdentifier("PreviewViewController")
        //3. Instantiate PreviewViewController and return it.
        guard let viewcontroller = storyboard.instantiateController(
            withIdentifier: identifier) as? PreviewViewController else {
                fatalError("PreviewViewController not found")
        }
        return viewcontroller
    }
}

// MARK: User Inerface
extension PreviewViewController {

    @IBAction func buttonZoom(_ sender: Any)
    {

        let button = sender as! NSSegmentedControl
        let selectedSegment = button.selectedSegment

        if selectedSegment == 0 {
            BKZoomIn(previewTextView)
            updateDocumentContent()
        } else {
            BKzoomOut(previewTextView)
            updateDocumentContent()
        }

    }

}

extension PreviewViewController: BKZoomable {

}
