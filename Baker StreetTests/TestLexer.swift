//
//  Baker_StreetTests.swift
//  Baker StreetTests
//
//  Created by Ian Hocking on 23/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Baker_Street
import XCTest

/// The type `Lexer`
class TestLexer: XCTestCase {

    func test_lexer_withEmptyString_shouldThrowStringLengthError() {
        XCTAssertThrowsError(try Lexer(text: "")) {
            error in XCTAssertEqual(
                error as! Lexer.Error,
                Lexer.Error.invalidStringLength)}
    }

    func test_lexer_withUntidyInfixString_shouldTidyInfixString() {
        let untidy = "  p   q  ()~"
        let l = try? Lexer(text: untidy)

        let tidy = "p q ( ) ~"
        let tidySplit = tidy.split(separator: " ")
        let tidySplitString = String(tidySplit.description)
        XCTAssertEqual(l!.getSplitText(), tidySplitString)
    }

    func test_lexer_withOverpaddedTokenString_shouldRemovePadding() {
        let formula = "~(p and q)"
        var l = try? Lexer(text: formula)
        _ = l!.getTokenised()

        let tokenString = l!.getTokenString()
        let correctlyPadded = "~(p AND q)"
        XCTAssertEqual(tokenString, correctlyPadded)
    }
}
