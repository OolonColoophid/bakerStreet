//
//  Document.swift
//  Baker Street
//
//  Created by Ian Hocking on 26/05/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Cocoa

class Document: NSDocument {
    
    public var mainText = ""
    
    var myViewController: ViewController?
    
    enum Error: Swift.Error, LocalizedError {

        case UTF8Encoding
        case UTF8Decoding
        
        var failureReason: String? {

            switch self {

                case .UTF8Encoding: return "File cannot be encoded in UTF-8."
                case .UTF8Decoding: return "File is not valid UTF-8."
                
            }

        }

    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains the Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"),
                                      bundle: nil)
        let windowController = storyboard.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier(
                "Document Window Controller")) as! NSWindowController
        
        let viewController = windowController.contentViewController
            as! ViewController
        self.myViewController = viewController
        
        self.addWindowController(windowController)

        viewController.validate(self.mainText)

    }

    // Save
    override func data(ofType typeName: String) throws -> Data {
        
        let windowController = windowControllers[0]
        let viewController = windowController.contentViewController
            as! ViewController

        self.mainText = viewController.mainTextContent

        guard let data = self.mainText.data(using: .utf8) else {
            throw Document.Error.UTF8Encoding
        }

        return data
        
    }
    
    // Load
    override func read(from data: Data, ofType typeName: String) throws {

        guard let mainText = String(data: data, encoding: .utf8) else {
            throw Document.Error.UTF8Decoding
        }

        self.mainText = mainText
        
    }
    
    // MARK: - Printing Support
    @IBAction func print(_ sender: Any?) {
        myViewController?.printDocument()
    }
    
    @IBAction override func runPageLayout(_ sender: Any?) {
        myViewController?.showPageSetup()
    }
    
    // Override the NSDocument printDocument method
    override func printDocument(_ sender: Any?) {
        myViewController?.printDocument()
    }
    
    // Override printOperation to provide custom print content
    override func printOperation(withSettings printSettings: [NSPrintInfo.AttributeKey : Any]) throws -> NSPrintOperation {
        // Let the view controller handle the printing
        if let viewController = myViewController {
            // Call the view controller's print method directly
            let printInfo = NSPrintInfo.shared
            return viewController.createPrintOperation(with: printInfo)
        }
        
        // Fallback to default behavior
        return try super.printOperation(withSettings: printSettings)
    }

}
