//
//  ViewController.swift
//
//  Created by Ian Hocking on 26/05/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Cocoa

class ViewController: NSViewController {

    // Our window controller
    // Used to access the toolbar
    //
    // Note there may be no window; keep a cache in case it
    // is nil, then we avoid forced unwrapping
    var mWindow: NSWindow? = nil

    // Set a reference to the app delegate. Here, I'm storing
    // some variables bound to UI elements like menu items
    // whose title I'd like to change
    var appDelegate = NSApplication.shared.delegate as! AppDelegate

    //    | Line Numbers | Main Text              | Advice View |
    //    |--------------+------------------------+-------------|
    //    |            0 | p and q |- q and p     |             |
    //    |            1 | p and q : Assumption 1 | Warning     |
    //    |          ... | ...                    | ...         |
    //    |           10 |                        |             |


    // Line numbers, main text and advice views (as NSText)
    @IBOutlet private var lineText:    NSText!
    @IBOutlet private var mainText:    NSText!
    @IBOutlet private var adviceText:  NSText!
    
    // Line numbers, main text and advice views (as NSTextViews)
    @IBOutlet var lineTextView:   NSTextView!
    @IBOutlet var mainTextView:   NSTextView!
    @IBOutlet var adviceTextView: NSTextView!

    private var lineCount: Int = 0

    // SplitView
    @IBOutlet weak var splitView: NSSplitView!

    // Our status indicator (footer)
    @IBOutlet weak var statusLight: NSImageView!
    @IBOutlet weak var statusSpinner: NSProgressIndicator!
    @IBOutlet weak var statusText: NSTextField!

    // Content views
    // Primarily used to notify us when scrolling occurs
    @IBOutlet weak var linesContentView: NSClipView!
    @IBOutlet weak var statementsContentView: NSClipView!
    @IBOutlet weak var adviceContentView: NSClipView!

    // Scroll view
    // We need this to help disable word wrap for the main view
    @IBOutlet weak var mainScrollView: NSScrollView!


    // When true, edits made to the main view are the result of the
    // user, and are treated as such. When false, edits made are
    // the result of the Baker Street
    private var hasUserEditControl: Bool = false

    // When true, scroll positions are being changed by
    // BakerStreet; we use this to manage scroll syncing
    // so that we don't trigger an infinite recursion
    private var isScrollSyncing: Bool = false

    // Content of main text view (i.e. the proof itself)
    public var mainTextContent: String {
        get {
            return mainText.string
        }
    }

    // Main Menu
    private var mainMenu = NSApplication.shared.mainMenu!

    // Binding
    private var toolbarToggleAdvice: NSButton!

    // Popover for the contextualised help when user clicks
    // on link in advice view
    private let advicePopover = NSPopover()

    // Panels for documentation
    private let markdownPanel = NSPanel()
    private let definitionsPanel = NSPanel()
    private let rulesFullPanel = NSPanel()
    private let rulesOverviewPanel = NSPanel()

    // Panel for preview
    private let previewPanel = NSPanel()

    // Cached content (generated as soon as this view loads)
    // for definitionsPanel and rulesFullPanel. This stops
    // the UI from slowing during generation
    private var cacheDefinitions = NSMutableAttributedString(string: "")
    private var cacheRules = NSMutableAttributedString(string: "")
    private var cacheMarkdown = NSMutableAttributedString(string: "")


    // The proof controller looks after proof operations
    private var proofController = ProofController()

    // Following a validation call, we could have an active proof
    // if the main text has content. Activeness is lost once the
    // user edits anything
    private var isProofActive: Bool = false

    // All completion strings
    private var myCompletionMode = CompletionMode.justification

    // Size of main text view
    private var mainTextViewSizeInChars: Int {

        // Note this is largely accurate but not
        // precise; however, the inaccuracy is conservative
        let myFont = OverallStyle.mainText.attributes[.font] as! NSFont

        let fontWidth = myFont.boundingRectForFont.width
        let viewWidth = mainTextView.bounds.width

        // View width divided by font width gives approx
        // count of characters that can fit
        return Int(( viewWidth / fontWidth))
    }

    // MARK: ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Start the computation of Definitions panel content
        // and Rules in Full panel content
        cacheUpdateDocumentViews()

        // Make this controller a delegate
        // for the main text (where the proof text goes)
        mainTextView.delegate = (self)

        // Set the view controller for the advice popover
        // i.e. the 'help' that appears if a user
        // clicks a hyperlink next to a warning in the
        // advice text view.
        advicePopover.contentViewController =
            AdviceViewController.freshController()

        // View controllers documentation panels
        markdownPanel.contentViewController =
            DocumentViewController.freshController()
        rulesFullPanel.contentViewController =
            DocumentViewController.freshController()
        definitionsPanel.contentViewController =
            DocumentViewController.freshController()
        // An image panel
        rulesOverviewPanel.contentViewController =
            ImageViewController.freshController()
        // And the preview panel
        previewPanel.contentViewController =
            PreviewViewController.freshController()

        // Because we want to know when the above panels
        // close, we should make this object the delegate
        markdownPanel.delegate = self
        definitionsPanel.delegate = self
        rulesFullPanel.delegate = self
        rulesOverviewPanel.delegate = self
        previewPanel.delegate = self


        // Set default attributes
        mainTextView.typingAttributes = OverallStyle.mainTextInactive.attributes
        mainTextView.insertionPointColor = BKPrefConstants.insertPColor
        mainTextView.wrapsLines = false

        // Set default behaviours
        mainTextView.isAutomaticTextCompletionEnabled = false
        mainTextView.isAutomaticDataDetectionEnabled = false
        mainTextView.isAutomaticLinkDetectionEnabled = false
        mainTextView.isAutomaticTextReplacementEnabled = false
        mainTextView.isAutomaticDashSubstitutionEnabled = false
        mainTextView.isAutomaticSpellingCorrectionEnabled = false
        mainTextView.isAutomaticQuoteSubstitutionEnabled = false

        // We want all scroll views to be in sync
        setScrollSync()

    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            validate()
        }
    }

    // Tidy any open windows when the view closes
    override func viewWillDisappear() {
        markdownPanel.close()
        rulesFullPanel.close()
        rulesOverviewPanel.close()
        definitionsPanel.close()
        previewPanel.close()
    }

}

// MARK: Scroll sync
extension ViewController {

    func setScrollSync() {

        // Scroll detection
        // ----------------
        //
        // We want to know when the bounds change (i.e. the user scrolls)
        // for each view
        linesContentView.postsBoundsChangedNotifications = true
        statementsContentView.postsBoundsChangedNotifications = true
        adviceContentView.postsBoundsChangedNotifications = true

        // We'll now ask each content view to notify us when
        // bounds change
        setNotifications()

    }

    func setNotifications() {
        // We'll now add ourself to the notification centre so
        // we can be called when the bounds do change.
        // When it does, (e.g.) lineContentDidScroll(notification:) is called
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(statementContentDidScroll(notification:)),
            name: NSView.boundsDidChangeNotification,
            object: self.statementsContentView)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(lineContentDidScroll(notification:)),
            name: NSView.boundsDidChangeNotification,
            object: self.linesContentView)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adviceContentDidScroll(notification:)),
            name: NSView.boundsDidChangeNotification,
            object: self.adviceContentView)
    }

    // This is an objective C function and needs to be called as such
    @objc func statementContentDidScroll(notification: Notification) {

        // Bounds
        // ------
        // The content view has the .bounds member, which returns
        // a rectangle: (x, y, width, height).
        //
        // x and y are the coordinates for the origin (top left point)
        //
        // When the top left point is in the 'natural' position and
        // and we're looking at the top of the document, these will be
        // x = 0
        // y = 0
        //
        // We're interested in y, and get this with .origin.y

        // Has this function been called while BakerStreet is
        // updating the bounds of other views? We don't want to
        // start again; early abort
        if isScrollSyncing == true {
            return
        }

        if BKPrefConstants.debugMode == true {print("statementContentDidScroll")}

        let myCaretIndex = caretIndex()

        let myXY = getContentViewBounds(forContentView: statementsContentView)

        willBeginScrollSync()

        setScroll(forContentView: linesContentView, to: myXY)

        setScroll(forContentView: adviceContentView, to: myXY)

        mainTextView.selectedRange = myCaretIndex

        willEndScrollSync()
    }

    func getContentViewBounds (forContentView contentView: NSClipView) ->
        (CGFloat, CGFloat) {

        return (contentView.bounds.origin.x, contentView.bounds.origin.y)

    }

    func setScroll(forContentView contentView: NSClipView,
                   to newXY: (CGFloat, CGFloat)) {

        contentView.bounds.origin.y = newXY.0
        contentView.bounds.origin.y = newXY.1

    }

    @objc func lineContentDidScroll(notification: Notification) {

        if isScrollSyncing == true {
            return
        }

        let myXY = getContentViewBounds(forContentView: statementsContentView)

        willBeginScrollSync()

        setScroll(forContentView: statementsContentView, to: myXY)
        setScroll(forContentView: adviceContentView, to: myXY)

        willEndScrollSync()


    }

    @objc func adviceContentDidScroll(notification: Notification) {

        if isScrollSyncing == true {
            return
        }

        let myXY = getContentViewBounds(forContentView: statementsContentView)

        willBeginScrollSync()

        setScroll(forContentView: statementsContentView, to: myXY)
        setScroll(forContentView: linesContentView, to: myXY)

        willEndScrollSync()

    }

    func willBeginScrollSync() {
        isScrollSyncing = true
    }

    func willEndScrollSync() {
        isScrollSyncing = false
    }

}

// MARK: Cache
extension ViewController {

    func cacheUpdateDocumentViews() {

        let rulesQueue = DispatchQueue(
            label: "bakerstreet.rules.queue",
            attributes: .concurrent
        )

        rulesQueue.async {
            self.cacheRules = DocumentContent.rules.body.htmlToNSMAS()
        }


        let definitionsQueue = DispatchQueue(
            label: "bakerstreet.definitions.queue",
            attributes: .concurrent
        )

        definitionsQueue.async {
            self.cacheDefinitions = DocumentContent.definitions.body.htmlToNSMAS()
        }

        let markdownQueue = DispatchQueue(
            label: "bakerstreet.markdown.queue",
            attributes: .concurrent
        )

        markdownQueue.async {
            self.cacheMarkdown = DocumentContent.markdown.body.htmlToNSMAS()
        }

    }


}

// MARK: NSTextViewDelegate
extension ViewController: NSTextViewDelegate {

    // Detect a link being clicked
    // Currently used for the advice view
    func textView(_ textView: NSTextView,
                  clickedOnLink link: Any,
                  at charIndex: Int) -> Bool {

        // The hyperlink will point to resource using a UUID
        let adviceUUID = UUID(uuidString: link as! String)

        guard adviceUUID != nil else {

            print("Internal Error - link didn't seem to be a UUID")
            return false

        }

        toggleAdvicePopover(textView, forAdviceUUID: adviceUUID!)

        return true

    }

    // Detect any text changes
    // Note only the main text view is editable
    func textDidChange(_ obj: Notification)
    {

        if isProofActive == true && hasUserEditControl == true {

            hasUserEditControl = false

            deactivateMainContent()

            deactivateAdviceContent()

            deactivateLineContent()

            isProofActive = false

            statusLightInactive()

            statusTextInactive()

        }

    }
}

// MARK: Deactivate Content

extension ViewController {

    // Indicate main text looks inactive
    func deactivateMainContent() {

        let myScollOrigin = statementsContentView.bounds.origin.y

        let myCaretIndex = caretIndex()

        let currentContent = mainTextView.string

        let myStyler = SyntaxStyler()

        let inactiveText = myStyler.style(currentContent, with: OverallStyle.mainTextInactive.attributes)
        
        mainTextView.string = ""
        
        mainTextView.textStorage?.insert(inactiveText, at: 0)
        
        statementsContentView.bounds.origin.y = myScollOrigin
        
        mainTextView.selectedRange = myCaretIndex

    }


}

// MARK: Caret and Selection

extension ViewController {

    func caretIndex() -> NSRange {
        return mainTextView.selectedRange()
    }

    func caretLine() -> Int {

        let caretLine = beforeCaretText().components(separatedBy:"\n")

        return caretLine.count - 1
    }

    func beforeCaretText() -> String {

        let myCaretIndex = caretIndex().location

        let index = mainTextView.string
            .index(mainTextView.string.startIndex,
                   offsetBy: myCaretIndex)

        return String(mainTextView.string[..<index])

    }

    func afterCaretText() -> String {

        let myCaretIndex = caretIndex().location

        let index = mainTextView.string
            .index(mainTextView.string.startIndex,
                   offsetBy: myCaretIndex)

        return String(mainTextView.string[index...])

    }

    func getLineCount() -> Int {

        var myLineCount = 0

        for c in mainTextView.string {
            if c == "\n" {
                myLineCount = myLineCount + 1
            }
        }

        // The final line won't have a \n
        myLineCount += 1

        return myLineCount

    }

}

// MARK: Menus and Buttons
extension ViewController {

    @IBAction func menuProofCheck(_ sender: Any) {
        validate()
    }

    @IBAction func menuPreview(_ sender: Any) {
        togglePreview()
    }


    @IBAction func menuOperatorCompletion(_ sender: Any) {
        myCompletionMode = CompletionMode.logic
        completion()
    }

    @IBAction func menuJustificationCompletion(_ sender: Any) {
        myCompletionMode = CompletionMode.justification
        completion()
    }

    @IBAction func menuDefinitions(_ sender: Any) {
        toggleDefinitions()
    }

    @IBAction func menuRulesFull(_ sender: Any) {
        toggleRulesFull()
    }

    @IBAction func menuRulesOverview(_ sender: Any) {
        toggleRulesOverview()
    }

    @IBAction func menuMarkdown(_ sender: Any) {
        toggleMarkdown()
    }

    @IBAction func toolbarDefinitions(_ sender: Any) {
        toggleDefinitions()
    }

    @IBAction func toolbarRulesFull(_ sender: Any) {
        toggleRulesFull()
    }

    @IBAction func toolbarRulesOverview(_ sender: Any) {
        toggleRulesOverview()
    }

    @IBAction func toolbarMarkdown(_ sender: Any) {
        toggleMarkdown()
    }

    @IBAction func toolbarZoom(_ toolbarItem: NSSegmentedControl) {

        let selectedSegment = toolbarItem.selectedSegment

        if selectedSegment == 0 {

            BKZoomIn([lineTextView, mainTextView, adviceTextView])
            refreshLines()

        } else {

            BKZoomOut([lineTextView, mainTextView, adviceTextView])
            refreshLines()

        }

    }

    @IBAction func toolbarToggleAdvice(_ toolbarItem: NSButton) {

        toggleAdvice(toolbarItem)

    }

    @IBAction func menuZoomIn(_ sender: Any) {

        BKZoomIn([lineTextView, mainTextView, adviceTextView])
        refreshLines()

    }

    @IBAction func menuZoomOut(_ sender: Any) {

        BKZoomOut([lineTextView, mainTextView, adviceTextView])
        refreshLines()

    }

    @IBAction func menuHelpExample(_ sender: Any) {

        helpExample(sender as! NSMenuItem)

    }

    @IBAction func toolbarValidate(_ sender: Any) {
        validate()

    }

    @IBAction func toolbarOperatorCompletion(_ sender: Any) {
        myCompletionMode = CompletionMode.logic
        completion()
    }

    @IBAction func toolbarJustificationCompletion(_ sender: Any) {
        myCompletionMode = CompletionMode.justification
        completion()
    }

    @IBAction func toolbarPreview(_ sender: Any) {

        togglePreview()

    }


}

// MARK: Completion
extension ViewController {

    // Do completion in main text view
    // (sending self as delegate)
    func completion() {
        mainTextView.complete(self)
    }

    // Returns the actual completions for a partial word
    // Our programme supplies the completions
    // https://developer.apple.com/documentation/appkit/nstextviewdelegate/1449260-textview
    func textView(_ textView: NSTextView,
                  completions words: [String],
                  forPartialWordRange charRange: NSRange,
                  indexOfSelectedItem index: UnsafeMutablePointer<Int>?)
        -> [String] {

            // A list of all possible completions (logic symbol, justification)
            return myCompletionMode.completions
    }
}

// MARK: NSWindowDelegate
// The current object is the delegate for the panels (preview, rules etc.)
extension ViewController: NSWindowDelegate {

    func windowWillClose(_ notification: Notification) {

        let panel = notification.object as! NSPanel

        switch panel.title {
            case DocumentContent.markdown.windowTitle:
                didHideMarkdown()
            case DocumentContent.definitions.windowTitle:
                didHideDefinitions()
            case DocumentContent.rules.windowTitle:
                didHideRulesFull()
            case "Baker Street Rules Overview":
                didHideRulesOverview()
            default: // Preview
                didHidePreview()
        }

    }

}

// MARK: Document Windows
extension ViewController {

    func didHideMarkdown() {

        appDelegate.BKMenuHelpTitleMarkdown = "Show Markdown"

        setToolbarItemAsDeselected(forItemWithPaletteLabel: "Markdown Reference")


    }

    func showMarkdown() {

        let windowTitle = DocumentContent.markdown.windowTitle
        let body = cacheMarkdown

        let appearanceSize = NSSize(width: 750, height: 620)
        let minimumSize = NSSize(width: 380, height: 200)

        setDocumentPanelAttributes(forPanel: markdownPanel,
                                   withTitle: windowTitle,
                                   withAppearanceSize: appearanceSize,
                                   withMinimumSize: minimumSize,
                                   withDocText: body)

        appDelegate.BKMenuHelpTitleMarkdown = "Hide Markdown"

        setToolbarItemAsSelected(forItemWithPaletteLabel: "Markdown Reference")


    }

    func toggleMarkdown() {

        let mPanel = markdownPanel

        // Only set up the panel if isn't visible; otherwise
        // make it the key window and return
        guard mPanel.isVisible == false else {

            markdownPanel.close()

            didHideMarkdown()

            return

        }

        showMarkdown()

    }

    func didHideDefinitions() {

        appDelegate.BKMenuHelpTitleDefinition = "Show Definitions"

        setToolbarItemAsDeselected(forItemWithPaletteLabel: "Definitions Reference")


    }

    func showDefinitions() {

        let windowTitle = DocumentContent.definitions.windowTitle
        let body = cacheDefinitions

        let appearanceSize = NSSize(width: 400, height: 600)
        let minimumSize = NSSize(width: 380, height: 200)

        setDocumentPanelAttributes(forPanel: definitionsPanel,
                                   withTitle: windowTitle,
                                   withAppearanceSize: appearanceSize,
                                   withMinimumSize: minimumSize,
                                   withDocText: body)

        appDelegate.BKMenuHelpTitleDefinition = "Hide Definitions"

        setToolbarItemAsSelected(forItemWithPaletteLabel: "Definitions Reference")


    }

    func toggleDefinitions() {

        let dPanel = definitionsPanel

        // Only set up the panel if isn't visible; otherwise
        // make it the key window and return
        guard dPanel.isVisible == false else {

            definitionsPanel.close()

            didHideDefinitions()

            return

        }

        showDefinitions()

    }

    func didHideRulesFull() {

        appDelegate.BKMenuHelpTitleRulesFull = "Show Rules in Full"

        setToolbarItemAsDeselected(forItemWithPaletteLabel: "Full Rules Reference")


    }

    func showRulesFull() {

        let windowTitle = DocumentContent.rules.windowTitle
        let body = cacheRules

        let appearanceSize = NSSize(width: 400, height: 600)
        let minimumSize = NSSize(width: 380, height: 200)


        setDocumentPanelAttributes(forPanel: rulesFullPanel,
                                   withTitle: windowTitle,
                                   withAppearanceSize: appearanceSize,
                                   withMinimumSize: minimumSize,
                                   withDocText: body)

        appDelegate.BKMenuHelpTitleRulesFull = "Hide Rules in Full"

        setToolbarItemAsSelected(forItemWithPaletteLabel: "Full Rules Reference")


    }

    func toggleRulesFull() {

        let rPanel = rulesFullPanel

        // Only set up the panel if isn't visible; otherwise
        // make it the key window and return
        guard rPanel.isVisible == false else {

            rulesFullPanel.close()

            didHideRulesFull()

            return

        }

        showRulesFull()

    }



    func setDocumentPanelAttributes(forPanel panel: NSPanel,
                            withTitle title: String,
                            withAppearanceSize appearanceSize: NSSize,
                            withMinimumSize minimumSize: NSSize,
                            withDocText text: NSMutableAttributedString) {

        let myViewController = panel.contentViewController as! DocumentViewController

        panel.setContentSize(appearanceSize)
        panel.minSize = minimumSize
        panel.title = title
        panel.isFloatingPanel = true

        // Set position review to the main Baker Street window
        let mainWindow = view.window?.frame
        let myRect = mainWindow?.offsetBy(dx: 40, dy: -20) // 40 right, 20 down
        let myX = myRect?.maxX ?? 0 // x of bottom left
        let myY = myRect?.minY ?? 0 // y of bottom left
        panel.setFrameOrigin(NSPoint(x:myX, y:myY))

        // By default, panels are not resizable
        panel.styleMask.insert(.resizable)

        // Set contents of panel
        myViewController.set(text)

        // Make visible
        panel.makeKeyAndOrderFront(self)


    }
}

// MARK: Rules Overview (Image Panel)
extension ViewController {

    func didHideRulesOverview() {

        appDelegate.BKMenuHelpTitleRulesOverview = "Show Rules Overview"

        setToolbarItemAsDeselected(forItemWithPaletteLabel: "Overview Rules Reference")

    }

    func showRulesOverview() {

        let windowTitle = "Baker Street Rules Overview"
        let appearanceSize = NSSize(width: 723, height: 480)
        let minimumSize = NSSize(width: 380, height: 200)

        setImagePanelAttributes(forPanel: rulesOverviewPanel,
                                withAppearanceSize: appearanceSize,
                                withMinimumSize: minimumSize,
                                withTitle: windowTitle)

        appDelegate.BKMenuHelpTitleRulesOverview = "Hide Rules Overview"

        setToolbarItemAsSelected(forItemWithPaletteLabel: "Overview Rules Reference")


    }

    func toggleRulesOverview() {

        let rPanel = rulesOverviewPanel

        // Only set up the panel if isn't visible; otherwise
        // make it the key window and return
        guard rPanel.isVisible == false else {

            rulesOverviewPanel.close()

            didHideRulesOverview()
            return

        }

        showRulesOverview()


    }

    func setImagePanelAttributes(forPanel panel: NSPanel,
                                 withAppearanceSize appearanceSize: NSSize,
                                 withMinimumSize minimumSize: NSSize,
                                 withTitle title: String) {

        panel.title = title
        panel.setContentSize(appearanceSize)
        panel.minSize = minimumSize
        panel.isFloatingPanel = true

        // Set position review to the main Baker Street window
        let mainWindow = view.window?.frame
        let myRect = mainWindow?.offsetBy(dx: 40, dy: 0)
        let myX = myRect?.maxX ?? 0
        let myY = myRect?.minY ?? 0
        panel.setFrameOrigin(NSPoint(x:myX, y:myY))

        // By default, panels are not resizable
        panel.styleMask.insert(.resizable)

        // Make visible
        panel.makeKeyAndOrderFront(self)


    }

}

// MARK: Preview
extension ViewController {

    func didHidePreview() {

        appDelegate.BKMenuTitlePreview = "Show Preview"

        setToolbarItemAsDeselected(forItemWithPaletteLabel: "Preview")


    }

    func showPreview() {

        var documentTitle = (self.view.window?.title ?? "")
        if documentTitle != "" { documentTitle = ": " + documentTitle}

        let windowTitle = "Baker Street Preview" + documentTitle

        let appearanceSize = NSSize(width: 400, height: 600)
        let minimumSize = NSSize(width: 380, height: 200)


        setPreviewPanelAttributes(forPanel: previewPanel,
                                  withTitle: windowTitle,
                                  withAppearanceSize: appearanceSize,
                                  withMinimumSize: minimumSize,
                                  withDocText: NSMutableAttributedString(string: ""))

        appDelegate.BKMenuTitlePreview = "Hide Preview"

        setToolbarItemAsSelected(forItemWithPaletteLabel: "Preview")


    }

    func togglePreview() {

        let pPanel = previewPanel

        // Only set up the panel if isn't visible; otherwise
        // make it the key window and return
        guard pPanel.isVisible == false else {

            previewPanel.close()

            didHidePreview()

            return

        }

        showPreview()

    }

    func setPreviewPanelAttributes(forPanel panel: NSPanel,
                                   withTitle title: String,
                                   withAppearanceSize appearanceSize: NSSize,
                                   withMinimumSize minimumSize: NSSize,
                                   withDocText text: NSMutableAttributedString) {

        panel.setContentSize(appearanceSize)
        panel.minSize = minimumSize
        panel.title = title
        panel.isFloatingPanel = true

        // Set position review to the main Baker Street window
        let mainWindow = view.window?.frame
        let myRect = mainWindow?.offsetBy(dx: 40, dy: 0)
        let myX = myRect?.maxX ?? 0
        let myY = myRect?.minY ?? 0
        panel.setFrameOrigin(NSPoint(x:myX, y:myY))

        // By default, panels are not resizable
        panel.styleMask.insert(.resizable)

        // Make visible
        panel.makeKeyAndOrderFront(self)


    }
}

// MARK: Advice Popover
extension ViewController {

    func toggleAdvicePopover(_ textViewSender: NSTextView,
                             forAdviceUUID uuid: UUID) {

        let pop = advicePopover

        // The clicked hyperlink points to a resource via a uuid
        // Now ask the proof controller for the advice
        let advice = proofController.proof.getAdviceForAdviceUUID(withAdviceUUID: uuid)!

        // Create the advice view controller
        let avc = pop.contentViewController as! AdviceViewController

        // Only continue is the popover isn't showing
        guard pop.isShown == false else {

            pop.performClose(textViewSender)
            return

        }

        pop.show(relativeTo: textViewSender.bounds,
                 of: textViewSender,
                 preferredEdge: NSRectEdge.minY)

        // If the user clicks in the main view
        // popover disappears
        pop.behavior = .semitransient

        // Set contents of popover
        avc.set(advice)

    }
}

// MARK: Appearance
extension ViewController {

    // Advice to look inactive
    func deactivateAdviceContent() {

        adviceTextView.alphaValue = CGFloat(0.4)

    }

    // Line numbers to look inactive
    func deactivateLineContent() {

        lineTextView.alphaValue = CGFloat(0.6)

    }

    // Advice to look active
    func activateAdviceContent() {

        adviceTextView.alphaValue = CGFloat(1.0)

    }

    // Line numbers to look active
    func activateLineContent() {

        lineTextView.alphaValue = CGFloat(1.0)

    }

    // Status light
    // Inactive (grey) - main view is blank or inactive
    // Green - proof is correct
    // Amber - proof is being checked
    // Red - proof is not correct
    func statusLightInactive() {
        statusLight.image = NSImage(named: "NSStatusNone")
    }

    func statusLightGood() {
        statusLight.image = NSImage(named: "NSStatusAvailable")
    }

    func statusLightChanging() {
        statusLight.image = NSImage(named: "NSStatusPartiallyAvailable")
    }

    func statusLightBad() {
        statusLight.image = NSImage(named: "NSStatusUnavailable")
    }

    func statusTextInactive() {
        statusText.stringValue = " "
    }

    func statusTextCorrect() {
        statusText.stringValue = "Proof Correct"
    }

    func statusTextChecking() {
        statusText.stringValue = " "
    }

    func statusTextIncorrect() {
        statusText.stringValue = "Proof Incorrect"
    }

    func statusSpinnerStart() {
        statusSpinner.startAnimation(self)
    }

    func statusSpinnerStop() {
        statusSpinner.stopAnimation(self)

    }

    func toggleAdvice(_ toolbarItem: NSButton) {

        if toolbarItem.state == .on { // It was off; is now on
            
            showAdviceView()

        } else {

            hideAdviceView()

        }

    }

    func showAdviceView() {

        // Our window
        let windowSize = view.window?.frame.size.width

        // A CGFloat proportion currently held as a constant
        let adviceViewProportion = BKPrefConstants.adviceWindowSize

        // Position is window size minus the proportion, since
        // origin is top left
        let newPosition = windowSize! - (windowSize! * adviceViewProportion)

        splitView.setPosition(newPosition, ofDividerAt: 1)

        setToolbarItemAsSelected(forItemWithPaletteLabel: "Toggle Advice Panel")

    }

    func hideAdviceView() {

        let windowSize = view.window?.frame.size.width
        let newPosition = windowSize!

        splitView.setPosition(newPosition, ofDividerAt: 1)

        setToolbarItemAsDeselected(forItemWithPaletteLabel: "Toggle Advice Panel")

    }

    func setToolbarItemAsSelected(forItemWithPaletteLabel label: String) {

        let button = getToolbarButton(withPaletteLabel: label)
        button.state = .on

    }

    func setToolbarItemAsDeselected(forItemWithPaletteLabel label: String) {

        let button = getToolbarButton(withPaletteLabel: label)
        button.state = .off

    }

    func getToolbarButton(withPaletteLabel pl: String) -> NSButton {
        let myWindow = self.view.window
        var myItem = NSButton()
        for i in myWindow!.toolbar!.items {
            if i.paletteLabel == pl {
                myItem = i.view as! NSButton
                return myItem
            }
        }
        return myItem
    }

}

// MARK: Update Contents

extension ViewController {

    // Reset the proof and then reset all the views (make them look
    // 'active'). User either the contents of the main text view or
    // the supplied text.
    //
    // User-intitiated reset will probably use the main text
    // When a new proof is loaded from a file, NSDocument will
    // probably supply the text
    public func validate(_ textSupplied: String = "") {

        // Proof text if none supplied
        var proofText = ""
        let textSize = self.mainTextViewSizeInChars

        proofText = textSupplied

        // Was no text supplied to function? Then use what is
        // currently in the main textview
        if proofText == "" {

            // Is the main textview empty?
            // There is no proof. Abort, blanking
            // the lines and the advice view
            // (also hide advice view)
            guard mainText.string.trim != "" else {
                lineText.string = ""
                adviceText.string = ""
                hideAdviceView()
                return
            }

            proofText = self.mainText.string

        }

        // Let user know work is happening
        statusSpinnerStart()
        statusLightChanging()
        statusTextChecking()

        let concurrentQueue = DispatchQueue(
            label: "bakerstreet.validation.queue",
            attributes: .concurrent)

        let previewPanel = self.previewPanel.contentViewController
            as! BKProofDelegate

        concurrentQueue.async {

            // Perform proof validation on the background queue
            self.proofController = ProofController(
                proofText: proofText,
                newTextViewSizeInChars: textSize,
                withDelegate: previewPanel)

            self.isProofActive = true

            DispatchQueue.main.async {

                // Set status light/text to indicate success
                self.refreshStatus()

                // Reload the contents of the view
                self.refreshContent()

                // Inform user
                self.statusSpinnerStop()
            }

        }
    }

    func refreshStatus() {

        // Get status of the proof
        if proofController.proof.proven {
            statusLightGood()
            statusTextCorrect()
            hideAdviceView()
        } else {
            statusLightBad()
            statusTextIncorrect()
            showAdviceView()
        }

    }

    func refreshContent() {

        // Store the x and y position
        let myScollOriginY = statementsContentView.bounds.origin.y
        let myScollOriginX = statementsContentView.bounds.origin.x

        activateLineContent()
        activateAdviceContent()

        // Note caret position
        let myCaretIndex = caretIndex()

        // Get styled content
        let mainStyled = proofController.mainViewTextStyled
        let adviceStyled = proofController.adviceViewTextStyled

        // Disable any user-editing detection
        hasUserEditControl = false

        // Set the styled content in the views
        setStyledTextView(mainTextView, mainStyled)
        setStyledTextView(adviceTextView, adviceStyled)

        // Get and set lines view
        // (this is a separate function because it can be called
        // when setting the zoom level)
        refreshLines()

        // Reset line count
        lineCount = getLineCount()

        // Restore caret position
        mainTextView.selectedRange = myCaretIndex

        // Restore scroll origin
        statementsContentView.bounds.origin.y = myScollOriginY
        statementsContentView.bounds.origin.x = myScollOriginX


        // Enable any user-editing detection
        hasUserEditControl = true

    }

    // Used mainly when we want to zoom:
    // Becuase line numbers are right-justified, we need to
    // refresh these to make sure they are aligned properly
    func refreshLines() {
        let lineStyled = proofController.lineViewTextStyled
        setStyledTextView(lineTextView, lineStyled)

    }

    func setStyledTextView (_ textView: NSTextView,
                            _ styledText: NSMutableAttributedString) {


        // Tell the delegate that I'm about to change some text
        // This brings it to the notice of other OS elements, like
        // the undo manager
        if textView.string.count > 0 {
        let allTextLength = NSMakeRange(0, textView.textStorage!.length)
        textView.shouldChangeText(in: allTextLength,
                                  replacementString: styledText.string)
        }
        // Nuke
        textView.string = ""

        // And pave
        textView.textStorage?.insert(styledText, at: 0)

        // Tell the delegate I've finished changing
        textView.didChangeText()

    }

}

// MARK: Extension: BKZoomable
extension ViewController: BKZoomable {

}

// MARK: Help Examples
extension ViewController {

    func helpExample(_ menuItem: NSMenuItem) {

        var proofText = ""

        switch menuItem.tag {
            case -1:
                proofText = Examples.tutorial.text
            case 1:
                proofText = Examples.andElimination.text
            case 2:
                proofText = Examples.orIntroduction.text
            case 3:
                proofText = Examples.orElimination.text
            case 4:
                proofText = Examples.ifIntroduction.text
            case 5:
                proofText = Examples.ifElimination.text
            case 6:
                proofText = Examples.iffIntroduction.text
            case 7:
                proofText = Examples.iffElimination.text
            case 8:
                proofText = Examples.notIntroduction.text
            case 9:
                proofText = Examples.notElimination.text
            case 10:
                proofText = Examples.falseElimination.text
            default: // Actually case 0
                proofText = Examples.andIntroduction.text


        }

        makeNewDocument(proofText)

    }

    func makeNewDocument(_ text: String) {

        // Can we set the document title?

        let newHelpExample = Document()

        newHelpExample.mainText = text

        newHelpExample.makeWindowControllers()

        newHelpExample.showWindows()

    }

}
