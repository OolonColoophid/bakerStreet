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

// MARK: Storyboard Instantiation

extension PreviewViewController {
    // MARK: Storyboard instantiation
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
            BKzoomIn(previewTextView)
            updateDocumentContent()
        } else {
            BKzoomOut(previewTextView)
            updateDocumentContent()
        }

    }

}

extension PreviewViewController: BKZoomable {

}
