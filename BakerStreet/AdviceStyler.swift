//
//  AdviceStyler.swift
//  Baker Street
//
//  Created by Ian Hocking on 29/06/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Foundation

// Returns styled text for the advice popover views.
public struct AdviceStyler: Styling {


    public func style(_ text: String,
                      with attributes: [NSAttributedString.Key : Any])
        -> NSMutableAttributedString {

            let s = Styler(text, with: attributes)
            return s.getFormatted()
    }

    public func styleNSAString(_ text: NSMutableAttributedString,
                      with attributes: [NSAttributedString.Key : Any])
        -> NSMutableAttributedString {

            let s = Styler(text, with: attributes)
            return s.getFormatted()
    }

    // foreAdviceUUID is the target
    // linkText could be "more"
    public func addHyperlink(forAdviceUUID uuid: UUID,
                             _ linkText: String) -> NSMutableAttributedString {

        var openBracket = NSMutableAttributedString(string: "(")
        var closeBracket = NSMutableAttributedString(string: ")")

        openBracket = styleNSAString(openBracket, with: OverallStyle.adviceText.attributes)
        closeBracket = styleNSAString(closeBracket, with: OverallStyle.adviceText.attributes)

        var hyperlink = NSMutableAttributedString(string: linkText)

        let hyperlinkAttributes = LinkStyle.getAttributes(withTarget: uuid.uuidString)

        hyperlink = styleNSAString(hyperlink,
                                   with: hyperlinkAttributes)

        hyperlink.append(closeBracket)
        openBracket.append(hyperlink)

        let attributeString = openBracket

        return attributeString

    }


}
