//
//  AdviceViewController.swift
//  Baker Street
//
//  Created by Ian Hocking on 30/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Cocoa

class AdviceViewController: NSViewController {

    // |-------------------------------|
    // |                               |
    // |     longDescriptionView       |
    // |                               |
    // |-------------------------------|
    // |               adviceTypeLabel |
    // |                   line number |
    // |-------------------------------|


    @IBOutlet var longDescriptionView: NSTextView!

    @IBOutlet weak var adviceTypeLabel: NSTextField!
    @IBOutlet weak var lineLabel: NSTextField!

    public var adviceTypeAndLineNumberLabelText: String {
        get {
            return adviceTypeLabel.stringValue
        }
        set (text) {
            adviceTypeLabel.stringValue = text
        }
    }

    public var lineLabelText: String {
        get {
            return lineLabel.stringValue
        }
        set (text) {
            print("Wanting to set line to \(text)")
            lineLabel.stringValue = text
        }
    }

    override func viewDidLoad() {

        super.viewDidLoad()

    }

    public func set(_ advice: Advice) {

        adviceTypeAndLineNumberLabelText = advice.symbol + " "
            + advice.shortDescription

        lineLabelText = "At line: " + advice.lineAsString

        setLongDescriptionView(advice.longDescriptionAsNSMAS)

    }

    public func setLongDescriptionView(_ text: NSMutableAttributedString) {

        longDescriptionView.string = ""
        longDescriptionView.textStorage?.insert(text, at: 0)

    }

}

extension AdviceViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> AdviceViewController {
        //1. Get a reference to Main.storyboard.
        let storyboard = NSStoryboard(
            name: NSStoryboard.Name("Main"),
            bundle: nil)
        //2. Create a Scene identifier that matches
        // the one I set in the storyboard.
        let identifier = NSStoryboard.SceneIdentifier("AdviceViewController")
        //3. Instantiate AdviceViewController and return it.
        guard let viewcontroller = storyboard.instantiateController(
            withIdentifier: identifier) as? AdviceViewController else {
            fatalError("AdviceViewController not found")
        }

        return viewcontroller
    }
}
