//
//  Baker_StreetTests.swift
//  Baker StreetTests
//
//  Created by Ian Hocking on 23/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

@testable import Baker_Street
import XCTest


/// The type `Formula`
class TestFormula: XCTestCase {

    // MARK: Wellformedness

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

    // MARK: Truth tables

    func test_formula_requestingTruthTable_shouldHaveTruthTable() {
        let formula = "p and q"
        let f = Formula(formula, withTruthTable: true)

        f.debug()
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


    func test_formula_requestingTruthTableSize_shouldHaveTruthTableSize() {

        let f1 = Formula("p and q",
                         withTruthTable: true,
                         forNTruthTableVariables: 0)
        let f1TruthTableSize = f1.truthTable.count
        XCTAssertTrue(f1TruthTableSize == 4)

        let f2 = Formula("p and q",
                         withTruthTable: true,
                         forNTruthTableVariables: 3)
        let f2TruthTableSize = f2.truthTable.count
        XCTAssertTrue(f2TruthTableSize == 8)

        let f3 = Formula("p and q",
                         withTruthTable: true,
                         forNTruthTableVariables: 4)
        let f3TruthTableSize = f3.truthTable.count
        XCTAssertTrue(f3TruthTableSize == 16)

        let f4 = Formula("p and q",
                         withTruthTable: true,
                         forNTruthTableVariables: 5)
        let f4TruthTableSize = f4.truthTable.count
        XCTAssertTrue(f4TruthTableSize == 32)

        let f5 = Formula("p and q",
                         withTruthTable: true,
                         forNTruthTableVariables: 6)
        let f5TruthTableSize = f5.truthTable.count
        XCTAssertTrue(f5TruthTableSize == 64)

    }

    func test_1_largeFormula_requestingTruthTableSize_shouldHaveTruthTableSize() {

        let f = Formula("(p OR (q AND r)) AND (p -> s) AND ((q AND r) -> s)",
                         withTruthTable: true,
                         forNTruthTableVariables: 4)
        let fTruthTableSize = f.truthTable.count

        f.debug()

        XCTAssertTrue(fTruthTableSize == 16)

    }

    func test_2_largeFormula_requestingTruthTableSize_shouldHaveTruthTableSize() {

        let f = Formula("p -> (q AND r)",
                        withTruthTable: true,
                        forNTruthTableVariables: 3)
        let fTruthTableSize = f.truthTable.count

        f.debug()

        XCTAssertTrue(fTruthTableSize == 8)

    }



    func test_semanticallyIdenticalFormulas_requestingTruthTable_shouldHaveSameTruthTables() {

        XCTAssertTrue(
            lhsDoesEntailRhs(
                forLhs: "p and q",
                forRhs: "q and p"))

          XCTAssertTrue(
            lhsDoesEntailRhs(
                forLhs: "p AND (q AND r)",
                forRhs: "(p AND q) AND r"))


        XCTAssertTrue(
            lhsDoesEntailRhs(
                forLhs: "p AND q",
                forRhs: "p AND (r OR q)"))


        XCTAssertTrue(
            lhsDoesEntailRhs(
                forLhs: "p AND (q AND r)",
                forRhs: "(p AND q) AND r"))

        XCTAssertTrue(
            lhsDoesEntailRhs(
                forLhs: "p AND q",
                forRhs: "p AND (r OR q)"))


        XCTAssertTrue(
            lhsDoesEntailRhs(
                forLhs: "p OR (q AND r)",
                forRhs: "s OR p"))

        XCTAssertTrue(
            lhsDoesEntailRhs(
                forLhs: "p <-> q",
                forRhs: "q <-> p"))

        XCTAssertTrue(
            lhsDoesEntailRhs(
                forLhs: "p AND q",
                forRhs: "r AND q"))

        XCTAssertTrue(
            lhsDoesEntailRhs(
                forLhs: "p -> (q AND r)",
                forRhs: "p -> q"))

        XCTAssertTrue(
            lhsDoesEntailRhs(
                forLhs: "p -> q",
                forRhs: "(q -> r) -> (p -> r)"))

    }

    func test_semanticallyDifferentFormulas_requestingTruthTable_shouldHaveDifferentTruthTables() {

        XCTAssertFalse(
            lhsDoesEntailRhs(
                forLhs: "p -> r",
                forRhs: "r AND q"))

        XCTAssertFalse(
            lhsDoesEntailRhs(
                forLhs: "(q AND r) -> s",
                forRhs: "s OR p"))

        XCTAssertFalse(
            lhsDoesEntailRhs(
                forLhs: "p -> s",
                forRhs: "s OR p"))

        XCTAssertFalse(
            lhsDoesEntailRhs(
                forLhs: "p -> s",
                forRhs: "s OR (p OR ~p"))


    }

}
