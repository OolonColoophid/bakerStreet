//
//  AppDelegate.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 26/05/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // These variables are bound to elements of the UI (e.g. menus)
    @objc dynamic var BKMenuHelpTitleRulesOverview = "Show Rules Overview"
    @objc dynamic var BKMenuHelpTitleMarkdown = "Show Markdown"
    @objc dynamic var BKMenuHelpTitleRulesFull = "Show Rules in Full"
    @objc dynamic var BKMenuHelpTitleDefinition = "Show Definitions"

    @objc dynamic var BKMenuTitlePreview = "Show Preview"


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application


        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

