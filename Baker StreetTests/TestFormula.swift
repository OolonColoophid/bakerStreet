//
//  Baker_StreetTests.swift
//  Baker StreetTests
//
//  Created by Ian Hocking on 23/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Baker_Street
import XCTest


/// The type `Formula`
class TestFormula: XCTestCase {

    func test_formulae_withCorrectForm_shouldBeReportedWellFormed() {
        let correctFormulae = ["true",
                               "false",
                               "p",
                               "p and q",
                               "p or q",
                               "p -> q",
                               "~p and q",
                               "~p or q",
                               "~p -> q",
                               "p and ~q",
                               "p or ~q",
                               "p -> ~q",
                               "~(p or q) and ~(p or q)",
                               "~p and ~~p",
                               "p -> (q and r)",
                               "p or p and q"]

        for cF in correctFormulae {
            let f = Formula(cF)
            XCTAssertTrue(f.isWellFormed)
        }
    }

    func test_formulae_withWrongForm_shouldBeReportedAsWrong() {
        let wrongFormulae = ["true true",
                             "false false ",
                             "p p",
                             "p and q and",
                             "or p or q",
                             "p -> q ->",
                             "~p ~and q",
                             "~p or q~",
                             "~p ~ -> q",
                             "and p and ~q",
                             "p ~ or ~q",
                             "-> p -> ~q",
                             "~(p or or q) and ~(p or q)",
                             "~p and ~~p or",
                             "p -> (q and -> r)"]

        for cF in wrongFormulae {
            let f = Formula(cF)
            XCTAssertFalse(f.isWellFormed)
        }
    }

    func test_formula_withUnpaddedElement_shouldParse() {
        let formula = "p->p"
        let f = Formula(formula)
        XCTAssertEqual(f.infixText, "p -> p")
    }

    func test_formula_withUnpaddedElement_shouldParse2() {
        let formula = "p<->p"
        let f = Formula(formula)
        XCTAssertEqual(f.infixText, "p <-> p")
    }

    func test_formula_shouldHaveTruthTable() {
        let formula = "p and q"
        let f = Formula(formula, withTruthTable: true)
        f.debug()

        XCTAssertEqual(f.truthTable, "true, false, false, and false")
    }

// That  formula with withTruthTable = false doesn't produce truth table

    // That formula with withTruthTable = true does produce truth table

    // One or two particular truth tables

}
