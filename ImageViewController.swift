//
//  ImageViewController.swift
//  Baker Street
//
//  Created by Ian Hocking on 07/08/2020.
//  Copyright © 2020 Ian. MIT Licence.
//

import Cocoa

// Displays and controls the floating Rules Overview window.
class ImageViewController: NSViewController {

    @IBOutlet weak var zoomButton: NSSegmentedControl!

    @IBOutlet weak var imageView: NSImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

// MARK: BKZoomable
extension ImageViewController: BKZoomable {

}



extension ImageViewController {
    // MARK: Storyboard instantiation
    /// We can use this convenience method to create a new instance
    /// - Returns: a new ImageViewController object
    static func freshController() -> ImageViewController {
        //1. Get a reference to Main.storyboard.
        let storyboard = NSStoryboard(
            name: NSStoryboard.Name("ImageView"),
            bundle: nil)
        //2. Create a Scene identifier that matches
        // the one I set in the storyboard.
        let identifier = NSStoryboard.SceneIdentifier("ImageViewController")
        //3. Instantiate PreviewViewController and return it.
        guard let viewcontroller = storyboard.instantiateController(
            withIdentifier: identifier) as? ImageViewController else {
                fatalError("ImageViewController not found")
        }
        return viewcontroller
    }
}
