//
//  Preferences.swift
//  Holds global enumerated types, functions and constants related to appearance.
//
//  Created by Ian Hocking on 29/05/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//
import Cocoa

import Foundation

// Initial constants set on load
enum BKPrefConstants {

    // Debug mode
    static let debugMode: Bool = false

    // Initial size when app loads
    static let globalFontSize: CGFloat = 15

    // Insert point color
    static var insertPColor: NSColor {

        return BKColors.indianYellow.color

    }

    // Zoom increment (i.e. point size of font inc/dec)
    static let zoomIncrement: CGFloat = 2

    // Proportion of main window that is the advice window,
    // when showing; this can be overridden by the user
    static let adviceWindowSize = CGFloat(0.26) // 0 min, 1 max

    // Accessibility preference for non-color mode
    static let accessibilityModeEnabled: Bool = false

}

enum BKColors {
    case auburn
    case deepSpaceSparkle
    case indianYellow
    case mediumChampagne
    case rosewood

    var color: NSColor {
        switch self {

            case .auburn:

                if #available(OSX 10.13, *) {

                    return NSColor(named: "auburn")!

                } else {

                    return getLightOrDark(light: rgbToNSColor(r: 158, g: 42, b: 43),
                                       dark: rgbToNSColor(r: 158, g: 42, b: 43))

                }

            case .deepSpaceSparkle:

                if #available(OSX 10.13, *) {
                    return NSColor(named: "deepSpaceSparkle")!

                } else {

                    return getLightOrDark(light: rgbToNSColor(r: 51, g: 92, b: 103),
                                       dark: rgbToNSColor(r: 117, g: 155, b: 172))

            }

            case .indianYellow:

                if #available(OSX 10.13, *) {
                    return NSColor(named: "indianYellow")!

                } else {

                    return getLightOrDark(light: rgbToNSColor(r: 224, g: 159, b: 62),
                                       dark: rgbToNSColor(r: 224, g: 159, b: 62))

            }

            case .mediumChampagne:

                if #available(OSX 10.13, *) {
                    return NSColor(named: "mediumChampagne")!

                } else {

                    return getLightOrDark(light: rgbToNSColor(r: 255, g: 243, b: 176, alpha: 0.28),
                                       dark: rgbToNSColor(r: 255, g: 243, b: 176, alpha: 0.28))

            }

            case .rosewood:

                if #available(OSX 10.13, *) {
                    return NSColor(named: "rosewood")!

                } else {

                    return getLightOrDark(light: rgbToNSColor(r: 83, g: 10, b: 13),
                                       dark: rgbToNSColor(r: 255, g: 214, b: 205))

            }


        }
    }

    func rgbToNSColor(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat? = 1) -> NSColor {
        return NSColor(red: r/255, green: g/255, blue: b/255, alpha: alpha!)
    }

    func getLightOrDark(light: NSColor,
                    dark: NSColor) -> NSColor {

        let darkmode = isDarkMode()

        if darkmode == true {

            return dark

        } else {

            return light

        }

    }

    // Suggest by: https://stackoverflow.com/questions/51672124/how-can-dark-mode-be-detected-on-macos-10-14
    func isDarkMode() -> Bool {

        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"),
                                      bundle: nil)
        let windowController = storyboard.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier(
                "Document Window Controller")) as! NSWindowController

        let viewController = windowController.contentViewController
            as! ViewController

        let view = viewController.mainTextView!

        if #available(OSX 10.14, *) {
            return view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }
        return false
    }

}

// Values that may be changed (initially
// set to BKPrefConstants)
enum UserPrefVariables {

    static var globalFont: CGFloat = BKPrefConstants.globalFontSize
    
    // Accessibility mode with UserDefaults persistence
    static var accessibilityMode: Bool {
        get {
            UserDefaults.standard.object(forKey: "accessibilityMode") as? Bool ?? BKPrefConstants.accessibilityModeEnabled
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "accessibilityMode")
        }
    }

}

public enum FontStyle {
    case globalFont
    case lineViewFont
    case globalLineHeight

    var value: CGFloat {
        switch self {
            case .globalFont:
                return UserPrefVariables.globalFont
            case .lineViewFont:
                return FontStyle.globalFont.value - 3
            case .globalLineHeight:
                return FontStyle.globalFont.value + 8
        }
    }
}



// How much right justification per scope level
public var ScopeLevelSize: Int {

    return 4

}

//

public struct LinkStyle {

    static func getAttributes(withTarget target: String) -> [NSAttributedString.Key : Any]{

        var lFont = NSFont.systemFont(ofSize: FontStyle.globalFont.value)
        var hyperlinkForeground = BKColors.indianYellow.color
        var hyperlinkUnderline = BKColors.deepSpaceSparkle.color

        // In accessibility mode, use bold font and system colors for better accessibility
        if UserPrefVariables.accessibilityMode {
            lFont = NSFont.boldSystemFont(ofSize: FontStyle.globalFont.value)
            hyperlinkForeground = NSColor.linkColor
            hyperlinkUnderline = NSColor.linkColor
        }

        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: lFont,
            NSAttributedString.Key.link: target,
            NSAttributedString.Key.foregroundColor: hyperlinkForeground,
            NSAttributedString.Key.underlineColor: hyperlinkUnderline,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.toolTip: "Click for further information"
        ]

        return linkAttributes

    }
}



public enum ParagraphStyle {
    case symbolsText
    case lineText
    case standard
    case advicePopover
    case document

    var style: NSMutableParagraphStyle {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = FontStyle.globalLineHeight.value
        paragraphStyle.maximumLineHeight = FontStyle.globalLineHeight.value
        paragraphStyle.lineBreakMode = .byTruncatingTail

        switch self {
            case .symbolsText:

                paragraphStyle.alignment = .left
                return paragraphStyle

            case .lineText:

                paragraphStyle.alignment = .right
                return paragraphStyle

            case .standard:

                paragraphStyle.alignment = .left
                return paragraphStyle

            case .advicePopover:

                paragraphStyle.alignment = .left
                return paragraphStyle

            case .document:

                paragraphStyle.alignment = .left
                return paragraphStyle

        }
    }
}


public enum OverallStyle {
    case symbolsText
    case lineText
    case lineTextInactive
    case mainText
    case adviceText
    case adviceTextInactive
    case adviceTextPopover
    case mainTextComment
    case mainTextInactive
    case mainTextAssertionTurnstile
    case mainTextAssertionScopeBar
    case mainTextAssertionOperand
    case mainTextAssertionOperator
    case mainTextAssertionBracket
    case mainTextAssertionPunctuation
    case mainTextAssertionTheoremText
    case mainTextAssertionJustificationText
    case mainTextAssertionJustificationNumber
    case documentText

    // Called without parameters will return defaults
    private func makeAttributes(

        _ foregroundColor: NSColor =
        BKColors.auburn.color,

        _ backgroundColor: NSColor =
        NSColor.clear,

        _ font: NSFont = NSFont.systemFont(ofSize: FontStyle.globalFont.value),

        _ paragraphStyle: NSMutableParagraphStyle =
        ParagraphStyle.standard.style,

        _ accessibilityFont: NSFont? = nil

    )
        -> Dictionary<NSAttributedString.Key, Any>{

            var myFont = font

            // Use accessibility font if provided and accessibility mode is enabled
            if UserPrefVariables.accessibilityMode && accessibilityFont != nil {
                myFont = accessibilityFont!
            } else {
                // Original font logic
                if #available(OSX 10.15, *) {
                    if myFont == NSFont.systemFont(ofSize: FontStyle.globalFont.value) {
                        myFont = NSFont.monospacedSystemFont(
                            ofSize: FontStyle.globalFont.value,
                            weight: NSFont.Weight.regular)
                    }
                }
            }

            // In accessibility mode, use system colors for better contrast
            let finalForegroundColor = UserPrefVariables.accessibilityMode ? 
                NSColor.labelColor : foregroundColor

            return [
                .font: myFont,
                .foregroundColor: finalForegroundColor,
                .backgroundColor: backgroundColor,
                .paragraphStyle: paragraphStyle,
            ]
    }

    public var attributes: Dictionary<NSAttributedString.Key, Any> {

        let aFont = NSFont.systemFont(
            ofSize: FontStyle.globalFont.value)

        switch self {
            case .symbolsText:
                let stFont = NSFont.monospacedDigitSystemFont(
                    ofSize: FontStyle.lineViewFont.value,
                    weight: NSFont.Weight.regular)

                let fColor = BKColors.indianYellow.color
                let bColor = NSColor.clear

                return makeAttributes(fColor, bColor, stFont,
                                      ParagraphStyle.symbolsText.style)
            case .lineText:

                let ltFont = NSFont.monospacedDigitSystemFont(
                    ofSize: FontStyle.lineViewFont.value,
                    weight: NSFont.Weight.regular)

                let fColor = BKColors.deepSpaceSparkle.color
                let bColor = NSColor.clear

                return makeAttributes(fColor, bColor, ltFont,
                                      ParagraphStyle.lineText.style)

            case .lineTextInactive:

                let ltFont = NSFont.monospacedDigitSystemFont(
                    ofSize: FontStyle.lineViewFont.value,
                    weight: NSFont.Weight.regular)

                let fColor = BKColors.deepSpaceSparkle.color.withAlphaComponent(CGFloat(0.5))
                let bColor = NSColor.clear

                return makeAttributes(fColor, bColor, ltFont,
                                      ParagraphStyle.lineText.style)


            case .mainText:
                return makeAttributes()

            case .adviceText:
                let fColor = BKColors.rosewood.color
                let bColor = NSColor.clear

                return makeAttributes(fColor, bColor, aFont)

            case .adviceTextInactive:
                let fColor = NSColor.textColor.withAlphaComponent(CGFloat(0.5))
                let bColor = NSColor.clear

                return makeAttributes(fColor, bColor, aFont)

            case .adviceTextPopover:
                let fColor = NSColor.labelColor
                let bColor = NSColor.clear

                return makeAttributes(fColor, bColor, aFont,
                                      ParagraphStyle.advicePopover.style)
            case .mainTextComment:
                let color = NSColor.systemGray
                return makeAttributes(color)

            case .mainTextInactive:
                let color = BKColors.deepSpaceSparkle.color
                return makeAttributes(color)

            case .mainTextAssertionTurnstile:
                let color = BKColors.indianYellow.color
                let accessibilityFont = NSFont.boldSystemFont(ofSize: FontStyle.globalFont.value)
                return makeAttributes(color, .clear, aFont, ParagraphStyle.standard.style, accessibilityFont)

            case .mainTextAssertionScopeBar:
                let fColor = NSColor.systemRed
                let bColor = NSColor.systemOrange.withAlphaComponent(CGFloat(0.1))
                return makeAttributes(fColor, bColor)

            case .mainTextAssertionOperand:
                let color = BKColors.rosewood.color
                let accessibilityFont = NSFont.italicSystemFont(ofSize: FontStyle.globalFont.value)
                return makeAttributes(color, .clear, aFont, ParagraphStyle.standard.style, accessibilityFont)

            case .mainTextAssertionOperator:
                let color = BKColors.rosewood.color
                let accessibilityFont = NSFont.boldSystemFont(ofSize: FontStyle.globalFont.value)
                return makeAttributes(color, .clear, aFont, ParagraphStyle.standard.style, accessibilityFont)

            case .mainTextAssertionBracket:
                let color = BKColors.rosewood.color
                let accessibilityFont = NSFont.systemFont(ofSize: FontStyle.globalFont.value, weight: .heavy)
                return makeAttributes(color, .clear, aFont, ParagraphStyle.standard.style, accessibilityFont)

            case .mainTextAssertionPunctuation:
                let color = BKColors.rosewood.color
                let accessibilityFont = NSFont.systemFont(ofSize: FontStyle.globalFont.value, weight: .medium)
                return makeAttributes(color, .clear, aFont, ParagraphStyle.standard.style, accessibilityFont)

            case .mainTextAssertionTheoremText:
                return makeAttributes()

            case .mainTextAssertionJustificationText:
                let color = BKColors.deepSpaceSparkle.color
                return makeAttributes(color)

            case .mainTextAssertionJustificationNumber:
                let color = BKColors.indianYellow.color
                let accessibilityFont = NSFont.boldSystemFont(ofSize: FontStyle.globalFont.value)
                return makeAttributes(color, .clear, aFont, ParagraphStyle.standard.style, accessibilityFont)

            case .documentText:
                let fColor = NSColor.labelColor
                let bColor = NSColor.clear

                return makeAttributes(fColor, bColor, aFont,
                                      ParagraphStyle.lineText.style)

        }
    }


}

// MARK: - Accessibility Utilities
public struct AccessibilityPreferences {
    
    /// Toggle accessibility mode on/off
    public static func toggleAccessibilityMode() {
        UserPrefVariables.accessibilityMode.toggle()
        
        // Post notification to update UI
        NotificationCenter.default.post(name: .accessibilityModeChanged, object: nil)
    }
    
    /// Check if accessibility mode is currently enabled
    public static var isEnabled: Bool {
        return UserPrefVariables.accessibilityMode
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let accessibilityModeChanged = Notification.Name("accessibilityModeChanged")
}
