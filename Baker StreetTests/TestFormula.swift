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

    func test_formula_requestingTruthTable_shouldHaveTruthTable() {
        let formula = "p and q"
        let f = Formula(formula, withTruthTable: true)

        XCTAssertTrue(!(f.truthTable.isEmpty))

    }

    func test_formula_notRequestingTruthTable_shouldHaveNoTruthTable() {
        let formula = "p and q"
        let f = Formula(formula, withTruthTable: false)

        XCTAssertTrue(f.truthTable.isEmpty)

    }

    func test_poorlyFormedFormula_requestingTruthTable_shouldHaveNoTruthTable() {
        let formula = "p and and q"
        let f = Formula(formula, withTruthTable: true)

        XCTAssertTrue(f.truthTable.isEmpty)

    }

    func test_semanticFormula_requestingANDTruthResult_shouldHaveGivenANDTruthResult() {


        let formulas = ["true and true",
                        "true and false",
                        "false and true",
                        "false and false"]
        let results = ["true",
                       "false",
                       "false",
                       "false"]

        for (index, f) in formulas.enumerated() {
            let myFormula = Formula(f)
            let myResult = results[index]
            print("\(f) : \(myResult), actual is \(myFormula.truthResult)")

            XCTAssertTrue(myFormula.truthResult == myResult)

        }

    }

    func test_semanticFormula_requestingORTruthResult_shouldHaveGivenORTruthResult() {


        let formulas = ["true or true",
                        "true or false",
                        "false or true",
                        "false or false"]
        let results = ["true",
                       "true",
                       "true",
                       "false"]

        for (index, f) in formulas.enumerated() {
            let myFormula = Formula(f)
            let myResult = results[index]
            print("\(f) : \(myResult), actual is \(myFormula.truthResult)")

            XCTAssertTrue(myFormula.truthResult == myResult)

        }

    }

    func test_semanticFormula_requestingIFTruthResult_shouldHaveGivenIFTruthResult() {


        let formulas = ["true -> true",
                        "true -> false",
                        "false -> true",
                        "false -> false"]
        let results = ["true",
                       "false",
                       "true",
                       "true"]

        for (index, f) in formulas.enumerated() {
            let myFormula = Formula(f)
            let myResult = results[index]
            print("\(f) : \(myResult), actual is \(myFormula.truthResult)")

            XCTAssertTrue(myFormula.truthResult == myResult)

        }

    }

    func test_semanticFormula_requestingIFFTruthResult_shouldHaveGivenIFFTruthResult() {


        let formulas = ["true <-> true",
                        "true <-> false",
                        "false <-> true",
                        "false <-> false"]
        let results = ["true",
                       "false",
                       "false",
                       "true"]

        for (index, f) in formulas.enumerated() {
            let myFormula = Formula(f)
            let myResult = results[index]
            print("\(f) : \(myResult), actual is \(myFormula.truthResult)")

            XCTAssertTrue(myFormula.truthResult == myResult)

        }

    }



    func test_1_semanticallyIdenticalFormulas_requestingTruthTable_shouldHaveSameTruthTables() {

        let formula1 = "p and q"
        let formula2 = "q and p"

        let f1 = Formula(formula1, withTruthTable: true)
        let f2 = Formula(formula2, withTruthTable: true)

        XCTAssertTrue(f1.truthTable == f2.truthTable)

    }


    func test_2_semanticallyIdenticalFormulas_requestingTruthTable_shouldHaveSameTruthTables() {

        let formula1 = "p AND (q AND r)"
        let formula2 = "(p AND q) AND r"

        let f1 = Formula(formula1, withTruthTable: true)
        let f2 = Formula(formula2, withTruthTable: true)

        XCTAssertTrue(f1.truthTable == f2.truthTable)

    }

    func test_3_semanticallyIdenticalFormulas_requestingTruthTable_shouldHaveSameTruthTables() {

        let formula1 = "p AND q"
        let formula2 = "p AND (r OR q)"

        let f1 = Formula(formula1, withTruthTable: true, forNTruthTableVariables: 3)
        let f2 = Formula(formula2, withTruthTable: true)

        f1.debug()
        f2.debug()

        XCTAssertTrue(f1.truthTable == f2.truthTable)

    }

    func test_4_semanticallyIdenticalFormulas_requestingTruthTable_shouldHaveSameTruthTables() {

        let formula1 = "p AND (q AND r)"
        let formula2 = "(p AND q) AND r"

        let f1 = Formula(formula1, withTruthTable: true)
        let f2 = Formula(formula2, withTruthTable: true)

        f1.debug()
        f2.debug()

        XCTAssertTrue(f1.truthTable == f2.truthTable)

    }

    func test_5_semanticallyIdenticalFormulas_requestingTruthTable_shouldHaveSameTruthTables() {

        let formula1 = "p AND q"
        let formula2 = "p AND (r OR q)"

        let f1 = Formula(formula1, withTruthTable: true, forNTruthTableVariables: 3)
        let f2 = Formula(formula2, withTruthTable: true)

        f1.debug()
        f2.debug()

        XCTAssertTrue(f1.truthTable == f2.truthTable)

    }

    func test_6_semanticallyIdenticalFormulas_requestingTruthTable_shouldHaveSameTruthTables() {

        let formula1 = "p OR (q AND r)"
        let formula2 = "s OR p"

        let f1 = Formula(formula1, withTruthTable: true)
        let f2 = Formula(formula2, withTruthTable: true, forNTruthTableVariables: 3)

        f1.debug()
        f2.debug()

        XCTAssertTrue(f1.truthTable == f2.truthTable)

    }

    func test_7_semanticallyIdenticalFormulas_requestingTruthTable_shouldHaveSameTruthTables() {

        let formula1 = "p -> s"
        let formula2 = "s OR p"

        let f1 = Formula(formula1, withTruthTable: true, forNTruthTableVariables: 3)
        let f2 = Formula(formula2, withTruthTable: true, forNTruthTableVariables: 3)

        f1.debug()
        f2.debug()

        XCTAssertTrue(f1.truthTable == f2.truthTable)

    }

    func test_8_semanticallyIdenticalFormulas_requestingTruthTable_shouldHaveSameTruthTables() {

        let formula1 = "(q AND r) -> s"
        let formula2 = "s OR p"

        let f1 = Formula(formula1, withTruthTable: true)
        let f2 = Formula(formula2, withTruthTable: true, forNTruthTableVariables: 3)

        f1.debug()
        f2.debug()

        XCTAssertTrue(f1.truthTable == f2.truthTable)

    }

    func test_9_semanticallyIdenticalFormulas_requestingTruthTable_shouldHaveSameTruthTables() {

        let formula1 = "p <-> q"
        let formula2 = "q <-> p"

        let f1 = Formula(formula1, withTruthTable: true)
        let f2 = Formula(formula2, withTruthTable: true)

        f1.debug()
        f2.debug()

        XCTAssertTrue(f1.truthTable == f2.truthTable)

    }

    func test_10_semanticallyIdenticalFormulas_requestingTruthTable_shouldHaveSameTruthTables() {

        let formula1 = "p AND q"
        let formula2 = "r AND q"

        let f1 = Formula(formula1, withTruthTable: true, forNTruthTableVariables: 3)
        let f2 = Formula(formula2, withTruthTable: true, forNTruthTableVariables: 3)

        f1.debug()
        f2.debug()

        XCTAssertTrue(f1.truthTable == f2.truthTable)

    }

    func test_11_semanticallyIdenticalFormulas_requestingTruthTable_shouldHaveSameTruthTables() {

        let formula1 = "p -> r"
        let formula2 = "r AND q"

        let f1 = Formula(formula1, withTruthTable: true, forNTruthTableVariables: 3)
        let f2 = Formula(formula2, withTruthTable: true, forNTruthTableVariables: 3)

        f1.debug()
        f2.debug()

        XCTAssertTrue(f1.truthTable == f2.truthTable)

    }

    func test_1_semanticallyDifferentFormulas_requestingTruthTable_shouldHaveDifferentTruthTables() {

        let formula1 = "p and q"
        let formula2 = "r"

        let f1 = Formula(formula1, withTruthTable: true)
        let f2 = Formula(formula2, withTruthTable: true)

        XCTAssertTrue(f1.truthTable != f2.truthTable)

    }

// That  formula with withTruthTable = false doesn't produce truth table

    // That formula with withTruthTable = true does produce truth table

    // One or two particular truth tables

}
