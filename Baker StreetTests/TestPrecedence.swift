//
//  Baker_StreetTests.swift
//  Baker StreetTests
//
//  Created by Ian Hocking on 23/06/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Baker_Street
import XCTest

/// The functions `<` and `<=`
class TestPrecendece: XCTestCase {

    // Test <=
    func test_rightEqualPrecedence_withHigherRightPrecedence_shouldBeTrue() {
        let left  = OperatorToken(operatorType: .lIff) // 0
        let right = OperatorToken(operatorType: .lNot) // 10
        XCTAssertTrue(left <= right)
    }

    func test_rightEqualPrecedence_withEqualPrecedence_shouldBeTrue() {
        let left  = OperatorToken(operatorType: .lIff) // 0
        let right = OperatorToken(operatorType: .lIf)  // 0
        XCTAssertTrue(left <= right)
    }

    func test_rightEqualPrecedence_withLowerRightPrecedence_shouldBeFalse() {
        let left  = OperatorToken(operatorType: .lNot) // 0
        let right = OperatorToken(operatorType: .lIf)  // 0
        XCTAssertFalse(left <= right)
    }

    // Test <
    func test_rightPrecedence_withHigherRightPrecedence_shouldBeTrue() {
        let left  = OperatorToken(operatorType: .lIff) // 0
        let right = OperatorToken(operatorType: .lNot) // 10
        XCTAssertTrue(left < right)
    }

    func test_rightPrecedence_withEqualPrecedence_shouldBeFalse() {
        let left  = OperatorToken(operatorType: .lIff) // 0
        let right = OperatorToken(operatorType: .lIf)  // 0
        XCTAssertFalse(left < right)
    }

    func test_rightPrecedence_withLowerRightPrecedence_shouldBeFalse() {
        let left  = OperatorToken(operatorType: .lNot) // 0
        let right = OperatorToken(operatorType: .lIf)  // 0
        XCTAssertFalse(left < right)
    }

}

