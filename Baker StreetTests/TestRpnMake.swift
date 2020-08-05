//
//  Baker_StreetTests.swift
//  Baker StreetTests
//
//  Created by Ian Hocking on 23/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Baker_Street
import XCTest



/// The type `RpnMake`
/// Includes tests for `RpnEvaluate`
class TestRpnMake: XCTestCase {

    func test_RpnMake_withEmptyTokenArray_shouldThrowArrayLengthError() {

        let tokens = [Token]()
        XCTAssertThrowsError(try RpnMake(infixFormula: tokens)) {
            error in XCTAssertEqual(
                error as! RpnMake.Error,
                RpnMake.Error.invalidTokenArrayLength)}
    }

    func test_RpnMake_WithInfixString_shouldGivePostfixString1() {

        let infix = "p and p"
        let postfix = "p p AND"

        // Start Lexer
        var l = try! Lexer(text: infix) // Initialise
        let t = l.getTokenised()           // Get array of Token

        //           // Convert to RPN
        let rpn = try! RpnMake(infixFormula: t)
        let rpnString = rpn.getRpnString()
        XCTAssertEqual(rpnString, postfix)

    }

    func test_RpnMake_WithInfixString_shouldGivePostfixString2() {

        let infix = "p or p"
        let postfix = "p p OR"

        // Start Lexer
        var l = try! Lexer(text: infix) // Initialise
        let t = l.getTokenised()           // Get array of Token

        //           // Convert to RPN
        let rpn = try! RpnMake(infixFormula: t)
        let rpnString = rpn.getRpnString()
        XCTAssertEqual(rpnString, postfix)

    }

    func test_RpnMake_WithInfixString_shouldGivePostfixString3() {

        let infix = "p -> p"
        let postfix = "p p ->"

        // Start Lexer
        var l = try! Lexer(text: infix) // Initialise
        let t = l.getTokenised()           // Get array of Token

        //           // Convert to RPN
        let rpn = try! RpnMake(infixFormula: t)
        let rpnString = rpn.getRpnString()
        XCTAssertEqual(rpnString, postfix)

    }

    func test_RpnMake_WithInfixString_shouldGivePostfixString4() {

        let infix = "p <-> p"
        let postfix = "p p <->"

        // Start Lexer
        var l = try! Lexer(text: infix) // Initialise
        let t = l.getTokenised()           // Get array of Token

        //           // Convert to RPN
        let rpn = try! RpnMake(infixFormula: t)
        let rpnString = rpn.getRpnString()
        XCTAssertEqual(rpnString, postfix)

    }

    func test_RpnMake_WithInfixString_shouldGivePostfixString5() {

        let infix = "~ p"
        let postfix = "p ~"

        // Start Lexer
        var l = try! Lexer(text: infix) // Initialise
        let t = l.getTokenised()           // Get array of Token

        //           // Convert to RPN
        let rpn = try! RpnMake(infixFormula: t)
        let rpnString = rpn.getRpnString()
        XCTAssertEqual(rpnString, postfix)

    }

    func test_RpnMake_WithInfixString_shouldGivePostfixString6() {

        let infix = " ~p AND p"
        let postfix = "p ~ p AND"

        // Start Lexer
        var l = try! Lexer(text: infix) // Initialise
        let t = l.getTokenised()           // Get array of Token

        //           // Convert to RPN
        let rpn = try! RpnMake(infixFormula: t)
        let rpnString = rpn.getRpnString()

        XCTAssertEqual(rpnString, postfix)

    }

    func test_RpnMake_WithWellFormedInfixString_shouldReportWellFormed() {

        let infix = "p and p"

        // Start Lexer
        var l = try! Lexer(text: infix) // Initialise
        let t = l.getTokenised()           // Get array of Token

        //           // Convert to RPN
        var rpn = try! RpnMake(infixFormula: t)
        try! rpn.rpnEvaluate() // Evaluate RPN

        XCTAssertTrue(rpn.getIsWellFormed())

    }

}
