//
//  Extensions.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Cocoa
import Foundation

// MARK: String: Regex
extension String {

    /// Return regular expression match
    ///
    /// If our text is  "Assumption 1, 2, 3" and we want to match any number:
    ///  ```
    /// let antecedentsString = text.regex("\\d+")
    /// // ["1","2","3"]
    /// ```
    ///
    ///  If there are no matches or an error is thrown, returns nil
    ///
    /// - Parameter String: The regular expression
    /// - Returns: An array of strings that match
    func regex (_ re: String) -> [String]? {

        do {

            let regex = try NSRegularExpression(
                pattern: re,
                options: NSRegularExpression.Options(rawValue: 0))
            let nsstr = self as NSString
            let all = NSRange(location: 0, length: nsstr.length)

            var matches : [String] = [String]()
            regex.enumerateMatches(
                in: self,
                options: NSRegularExpression.MatchingOptions(rawValue: 0),
                range: all) {
                    (result : NSTextCheckingResult?, _, _) in
                    if let r = result {
                        let result = nsstr.substring(with: r.range) as String
                        matches.append(result)
                }
            }

            if matches.count == 0 {
                return nil
            } else {
                return matches
            }

        } catch

        {
            return nil
        }
    }

}

// MARK: String: Uppercase
extension String {

    var toUpperFirstLetter: String {

        return self.prefix(1).capitalized + self.dropFirst()

    }
}

// MARK: String: tidying
extension String {

    /// Trim spaces at beginning and end; set any interstitial spaces to 1 char long
    /// If the string is only spaces, return a zero-length string
    var trim: String {

        let s = self

        // Remove spaces from beginning and end of string
        // e.g. "  hello " -> "hello"
        var trimS = s.trimmingCharacters(in: .whitespacesAndNewlines)

        // Deal with the special csae of comments, which begin with
        // the double slash "//". Trim the leading spaces but preserve
        // all others.
        if trimS.prefix(2) == "//" {
            return s.trimLeadingSpaces()
        }

        // Set maximum contiguous spaces to 1
        // e.g.  "hello    world" -> "hello world"
        repeat {
            trimS = trimS.replacingOccurrences(of: "  ",
                                       with: " ") }
            while trimS.contains("  ")

        if trimS == " " { trimS = "" }

        return trimS
    }

    /// Given "  p" return "p"
    func trimLeadingSpaces() -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return self
        }
        return String(self[index...])
    }


    /// Given a formula like "p and (   q or ~ p)" tidy to "p and (q or ~p)"
    var tidyFormula: String {

        // Normalise spacing
        var s = self.trim

        // Tidy close bracket
        repeat {
            s = s.replacingOccurrences(of: " )",
                                       with: ")") }
            while s.contains(" )")

        // Tidy open bracket
        repeat {
            s = s.replacingOccurrences(of: "( ",
                                       with: "(") }
            while s.contains("( ")

        // Tidy NOT
        let notPlainText = OperatorType.lNot.description
        repeat {
            s = s.replacingOccurrences(of: notPlainText + " ",
                                       with: notPlainText) }
            while s.contains(notPlainText + " ")

        return s
    }

}

// MARK: String: to words
// This will return only letter characters, ignoring punctuation
// "You should make, an assumption" -> "You" "should" "make" "an" "assumption"
extension StringProtocol {
    var toWords: [SubSequence] {
        return split{ !$0.isLetter }
    }
}

// MARK: String: to HTML
extension String {
    /// Take a string in HTML, e.g.
    /// var html = """
    ///    <html>
    ///    <body>
    ///    <h2>Proving a Theorem</h2>
    ///    <p>A theorem is proven when all of the <em>assertions</em> in its <em>scope</em> are proven. Right now, one or /more of the assertions in this scope are not proven.</p>
    ///    """
    ///
    /// and return an NSMutatbleAttributedString
    ///
    /// Use it like this:
    /// let n: NSMutableAttributedString = html.htmlToNSMAS()
    func htmlToNSMAS () -> NSMutableAttributedString {

            let string = self

            // Convert to UTF8
            let data = Data(string.utf8)
            var html = NSMutableAttributedString()

            if let attributedString =
                try? NSMutableAttributedString(
                    data: data,
                    options: [
                        .documentType:
                            NSMutableAttributedString.DocumentType.html,
                        .defaultAttributes:
                        OverallStyle.mainText.attributes

                    ],
                    documentAttributes: nil) {
                html = attributedString
            } else {
                html = NSMutableAttributedString(
                    string: "Error retrieving documentation")
            }

        return html

    }

}



// MARK: Stack: Sequence
extension Stack: Sequence {
    public func makeIterator() -> AnyIterator<T> {
        var curr = self
        return AnyIterator { curr.pop() }
    }
}

// MARK: Collection: Safety
extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: NSColor: Hex from color
extension NSColor {

    var hexString: String {
        guard let rgbColor = usingColorSpace(NSColorSpace.genericRGB) else {
            return "FFFFFF"
        }
        let red = Int(round(rgbColor.redComponent * 0xFF))
        let green = Int(round(rgbColor.greenComponent * 0xFF))
        let blue = Int(round(rgbColor.blueComponent * 0xFF))
        let hexString = NSString(format: "#%02X%02X%02X", red, green, blue)
        return hexString as String
    }

}

// MARK: Array: Comma separated lists
extension Array where Array.Element == String {

    // Given ["one", "two"] return "one and two"
    // Given ["one", "two", "three"] return "one, two and three"

    func commaList(onlyCommas: Bool = false) -> String {

        guard self.count > 0 else { return "" }

        guard self.count > 1 else { return self[0] }

        let s = (self.map{$0}).joined(separator: ",")

        var commaCount = 0
        let lastComma = self.count - 1
        var myList = ""

        // Replace last comma with 'and'
        for c in s {

            // Not a comma? Just continue to build string
            guard c == "," else {

                myList = myList + String(c)
                continue
            }

            // It's a comma!
            commaCount += 1

            // We've not yet reached the last comma
            if commaCount < lastComma {
                myList = myList + ", " }
            else { // Last comma reached

                guard onlyCommas == false else {
                    myList = myList + ", "
                    continue
                }

                myList = myList + " and "
            }

        }

        return myList

    }
}

extension Array where Array.Element == Int {

    // Given [1, 1] return "1 and 1"
    // Given [1, 2, 3] return "1, 2 and 3"
    func commaList(onlyCommas: Bool = false) -> String {

        guard self.count > 0 else { return "" }

        guard self.count > 1 else { return String(self[0]) }

        var myIntArrayAsStrings = [String]()

        for i in self {

            myIntArrayAsStrings.append(String(i))

        }

        return myIntArrayAsStrings.commaList()

    }
}

extension Array where Array.Element == Formula {

    // Given ["p and q", "q"] return "p and q and q" (prettified)
    func commaList(onlyCommas: Bool = false) -> String {

        guard self.count > 0 else { return "" }

        guard self.count > 1 else { return self[0].tokenStringHTMLWithGlyphs }

        var myIntArrayAsStrings = [String]()

        for i in self {

            myIntArrayAsStrings.append(i.tokenStringHTMLWithGlyphs)

        }

        return myIntArrayAsStrings.commaList()

    }
}

// MARK: Array: Get unique elements
// https://stackoverflow.com/questions/25738817/removing-duplicate-elements-from-an-array-in-swift
extension Array where Element: Hashable {
    var uniques: Array {
        var uniqueElements = Array()
        var added = Set<Element>()
        for e in self {
            if !added.contains(e) {
                uniqueElements.append(e)
                added.insert(e)
            }
        }
        return uniqueElements
    }
}

// MARK: Int: Words for numbers, and 's'
extension Int {

    // e.g. "the only bean", "the first bean"
    var ordinal: String {

        if self == 0 { return "only" }

        if self == 1 { return "first" }

        if self == 2 { return "second" }

        if self == 3 { return "third" }

        if self == 4 { return "fourth" }

        if self == 5 { return "fifth" }

        if self == 6 { return "sixth" }

        if self == 7 { return "seventh" }

        if self == 8 { return "eighth" }

        if self == 9 { return "nineth" }

        if self == 10 { return "tenth" }

        // Above 10, return the number itself
        // plus "th", e.g. "11th"
        return String(self) + "th"

    }

    // e.g. "the number of beans is zero"
    var noun: String {

        if self == 0 { return "zero" }

        if self == 1 { return "one" }

        if self == 2 { return "two" }

        if self == 3 { return "three" }

        if self == 4 { return "four" }

        if self == 5 { return "five" }

        if self == 6 { return "six" }

        if self == 7 { return "seven" }

        if self == 8 { return "eight" }

        if self == 9 { return "nine" }

        if self == 10 { return "ten" }

        // Above 10, return the number itself
        return String(self)

    }

    // e.g. "there are no beans"
    var adjective: String {

        if self == 0 { return "no" }

        if self == 1 { return "one" }

        if self == 2 { return "two" }

        if self == 3 { return "three" }

        if self == 4 { return "four" }

        if self == 5 { return "five" }

        if self == 6 { return "six" }

        if self == 7 { return "seven" }

        if self == 8 { return "eight" }

        if self == 9 { return "nine" }

        if self == 10 { return "ten" }

        // Above 10, return the number itself
        return String(self)

    }

    // Do we need to pluralise a noun that takes
    // a plural number adjective?
    // 0 beanS
    // 1 bean
    // 2 beanS
    var s: String {
        if self == 0 { return "s" }

        if self == 1 || self == -1 {
            return ""
        }

        return "s"

    }

    // To be
    var isAre: String {
        if self == 0 { return "are" }

        if self == 1 || self == -1 {
            return "is"
        }

        return "are"

    }

}



// MARK: NSTextView: Wrapping
extension NSTextView {
    var wrapsLines: Bool {
        get {
            return self.textContainer?.widthTracksTextView ?? false
        }
        set {
            guard
                newValue != self.wrapsLines,
                let scrollView = enclosingScrollView,
                let textContainer = self.textContainer
                else { return }

            scrollView.hasHorizontalScroller = !newValue
            isHorizontallyResizable = !newValue
            textContainer.widthTracksTextView = newValue

            if newValue {
                self.frame.size[keyPath: \NSSize.width] =
                    scrollView.contentSize.width
                maxSize = NSSize(width: scrollView.contentSize.width,
                                 height: CGFloat.greatestFiniteMagnitude)
                textContainer.size.width = scrollView.contentSize.width
            } else {
                let infiniteSize = CGSize(width: CGFloat.greatestFiniteMagnitude,
                                          height: CGFloat.greatestFiniteMagnitude)
                maxSize = infiniteSize
                textContainer.size = infiniteSize
            }
        }
    }
}

