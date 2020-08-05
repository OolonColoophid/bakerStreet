//
//  Styler.swift
//  Baker Street
//
//  Created by Ian Hocking on 24/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Foundation

public struct Styler {

    private var nText: NSMutableAttributedString = NSMutableAttributedString()

    public init(_ text: String, with attributes: [NSAttributedString.Key : Any]) {

        self.nText = NSMutableAttributedString(string: text)
        setAttributesGlobally(attributes: attributes)

    }

    public init(_ text: NSMutableAttributedString, with attributes: [NSAttributedString.Key : Any]) {

        self.nText = text
        setAttributesGlobally(attributes: attributes)

    }

    // Convert part of string
    public func setAttributesForSubstring(
        for substring: String,
        attributes: [NSAttributedString.Key : Any]){

        let range = getNSRange(for: substring, in: self.nText)
        self.nText.setAttributes(attributes, range: range)
    }

    // Convert entire string
    public func setAttributesGlobally(
        attributes: [NSAttributedString.Key : Any]){

        let range = NSRange(location: 0, length: self.nText.length)
        self.nText.setAttributes(attributes, range: range)

    }

    // Return what has been styled
    public func getFormatted() -> NSMutableAttributedString {
        return self.nText
    }

    // Get an NSRange for a substring
    private func getNSRange(
        for Text: String,
        in NSMutableAttributedString: NSMutableAttributedString)
        -> NSRange {

            let simpleString = NSMutableAttributedString.string
            let NSSimpleString = NSString(string: simpleString)

            return NSSimpleString.range (of: Text)

    }

}
