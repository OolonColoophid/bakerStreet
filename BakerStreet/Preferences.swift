//
//  Preferences.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 29/05/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//
import Cocoa

import Foundation

// Initial constants set on load
enum BKPrefConstants {

    // Debug mode
    static let debugMode: Bool = true

    // Initial size when app loads
    static let globalFontSize: CGFloat = 15

    // Insert point color
    static let insertPColor = NSColor(named: "indianYellow")!

    // Zoom increment
    static let zoomIncrement = 0.1 // 0 min, 1 max

    // Proportion of main window that is the advice window,
    // when showing; this can be overridden by the user
    static let adviceWindowSize = CGFloat(0.26) // 0 min, 1 max

}

// Values that may be changed (initially
// set to BKPrefConstants
enum UserPrefVariables {

    static var globalFont: CGFloat = BKPrefConstants.globalFontSize

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
                return FontStyle.globalFont.value + 8 // 10
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


        let lFont = NSFont.systemFont(
            ofSize: FontStyle.globalFont.value)

        let hyperlinkForeground = NSColor(named: "indianYellow")
        let hyperlinkUnderline = NSColor(named: "deepSpaceSparkle")

        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: lFont,
            NSAttributedString.Key.link: target,
            NSAttributedString.Key.foregroundColor: hyperlinkForeground!,
            NSAttributedString.Key.underlineColor: hyperlinkUnderline!,
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
        NSColor(named: "auburn")!,

        _ backgroundColor: NSColor =
        NSColor.clear,

        _ font: NSFont =
        NSFont.monospacedSystemFont(
            ofSize: FontStyle.globalFont.value,
            weight: NSFont.Weight.regular),

        _ paragraphStyle: NSMutableParagraphStyle =
        ParagraphStyle.standard.style

    )
        -> Dictionary<NSAttributedString.Key, Any>{

            return [
                .font: font,
                .foregroundColor: foregroundColor,
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

                let fColor = NSColor(named: "indianYellow")
                let bColor = NSColor.clear

                return makeAttributes(fColor!, bColor, stFont,
                                      ParagraphStyle.symbolsText.style)
            case .lineText:

                let ltFont = NSFont.monospacedDigitSystemFont(
                    ofSize: FontStyle.lineViewFont.value,
                    weight: NSFont.Weight.regular)

                let fColor = NSColor(named: "deepSpaceSparkle")
                let bColor = NSColor.clear

                return makeAttributes(fColor!, bColor, ltFont,
                                      ParagraphStyle.lineText.style)

            case .lineTextInactive:

                let ltFont = NSFont.monospacedDigitSystemFont(
                    ofSize: FontStyle.lineViewFont.value,
                    weight: NSFont.Weight.regular)

                let fColor = NSColor(named: "deepSpaceSparkle")!.withAlphaComponent(CGFloat(0.5))
                let bColor = NSColor.clear

                return makeAttributes(fColor, bColor, ltFont,
                                      ParagraphStyle.lineText.style)


            case .mainText:
                return makeAttributes()

            case .adviceText:
                let fColor = NSColor(named: "rosewood")
                let bColor = NSColor.clear

                return makeAttributes(fColor!, bColor, aFont)

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
                let color = NSColor(named: "deepSpaceSparkle")
                return makeAttributes(color!)

            case .mainTextAssertionTurnstile:
                let color = NSColor(named: "indianYellow")
                return makeAttributes(color!)

            case .mainTextAssertionScopeBar:
                let fColor = NSColor.systemRed
                let bColor = NSColor.systemOrange.withAlphaComponent(CGFloat(0.1))
                return makeAttributes(fColor, bColor)

            case .mainTextAssertionOperand:
                let color = NSColor(named: "rosewood")
                return makeAttributes(color!)

            case .mainTextAssertionOperator:
                let color = NSColor(named: "auburn")
                return makeAttributes(color!)

            case .mainTextAssertionBracket:
                let color = NSColor(named: "rosewood")
                return makeAttributes(color!)

            case .mainTextAssertionPunctuation:
                let color = NSColor(named: "rosewood")
                return makeAttributes(color!)

            case .mainTextAssertionTheoremText:
                return makeAttributes()

            case .mainTextAssertionJustificationText:
                let color = NSColor(named: "deepSpaceSparkle")
                return makeAttributes(color!)

            case .mainTextAssertionJustificationNumber:
                let color = NSColor(named: "indianYellow")
                return makeAttributes(color!)

            case .documentText:
                let fColor = NSColor.labelColor
                let bColor = NSColor.clear

                return makeAttributes(fColor, bColor, aFont,
                                      ParagraphStyle.lineText.style)

        }
    }


}
