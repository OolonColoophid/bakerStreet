//
//  ImageViewController.swift
//  Baker Street
//
//  Created by ian.user on 07/08/2020.
//  Copyright © 2020 Ian. All rights reserved.
//

import Cocoa

class ImageViewController: NSViewController {

    @IBOutlet weak var zoomButton: NSSegmentedControl!
    @IBOutlet weak var imageView: NSImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

//        imageView.setValue(NSColor.blue, forKey: "backgroundColor")
        // Do view setup here.

    }




}



// MARK: Storyboard Instantiation

extension ImageViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> ImageViewController {
        //1. Get a reference to Main.storyboard.
        let storyboard = NSStoryboard(
            name: NSStoryboard.Name("Main"),
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