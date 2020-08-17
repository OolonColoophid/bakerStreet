//
//  Baker_StreetTests.swift
//  Baker StreetTests
//
//  Created by Ian Hocking on 23/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

@testable import Baker_Street
import XCTest

// The type `Proof`
class ProofTests: XCTestCase {


    func test_proof_with_simpleProof_shouldBeProven() {

        let p = Proof(
            """
                p and q |- q and p
                p and q : Assumption 0
                p : AND Elimination 1
                q : AND Elimination 1
                q and p : AND Introduction 2 3
                """
        )

        XCTAssertTrue(p.getProven())

    }

    func test_emptyProof_isShouldBeNotProven() {
        let p = Proof("")
        XCTAssertFalse(p.getProven())
    }

    func test_incompleteProof_withProvenElements_shouldNotBeProven() {
        let p = Proof(
            """
                p and q |- q and p
                p and q : Assumption 0
                """
        )
        XCTAssertFalse(p.getProven())
    }

    func test_line_with_selfReferringAssumption_shouldNotBeProven() {
        let p = Proof(
            """
                p and q |- q and p
                p and q : Assumption 1
                """
        )
        XCTAssertFalse(p.getProven())
    }

    // Helper func for advice types
    public func getAdviceTypes(_ proof: Proof, forLine: Int) -> [AdviceInstance] {

        let advice = proof.advice
        let l = forLine
        var adviceTypes = [AdviceInstance]()

        for a in advice {
            if a.lineAsInt == l {
                adviceTypes.append(a.instance)
            }
        }

        return adviceTypes

    }

    func test_proof_with_improperThereom_shouldGiveAdvice() {

        let p = Proof(
            """
            p and q
            """)

        XCTAssertTrue(
            getAdviceTypes(p,
                           forLine:0)
                .contains(AdviceInstance
                    .justifiedNeedsParentTheorem))

    }


    func test_proof_with_incompleteTheorem_shouldGiveAdvice() {

        let p = Proof(
            """
            p AND q |- q
            """)

        XCTAssertTrue(
            getAdviceTypes(p,
                           forLine:0)
                .contains(AdviceInstance
                    .theoremNotProven))

    }



    func test_proof_with_improperThereomAndPoorlyFormedFormula_shouldGiveAdvice() {

        let p = Proof(
            """
            p q
            """)

        XCTAssertTrue(
            getAdviceTypes(p,
                           forLine:0)
                .contains(AdviceInstance
                    .justifiedFormulaPoorlyFormed))

    }

    func test_proof_with_poorlyFormedFormulaAndTooFewAntecedents_shoudGiveAdviceOnlyForFormula() {

        let p = Proof(
            """
                |- ~(p OR q) -> ~p AND ~q
                    ~(p OR q) |- ~p AND ~q
                        ~(p OR q) : Assumption (1)
                        p |- (p OR q) AND ~(p OR q)
                            p : Assumption (3)
                            p OR q : OR Introduction (4)
                            (p OR q) AND ~(p OR q) : AND Introduction (5, 2)
                        ~p : ~ Introduction (3)
                        q |- (p OR q) AND ~(p OR q)
                            q : Assumption (8)
                            p OR q : OR Introduction (9)
                            (p OR q) AND ~(p OR q) : AND Introduction (10, 2)
                        ~q : ~ Introduction (8)
                        ~p AND ~q : AND Introduction (7, 12)
                        ~(p OR q) -> ~p ~q : -> Introduction ()
            """)

        XCTAssertTrue(
            getAdviceTypes(p,
                           forLine:14)
                .contains(AdviceInstance
                    .justifiedFormulaPoorlyFormed))

    }

    func test_proof_with_poorlyFormedFormulaAndUnknownJustification_shoudGiveAdviceOnlyForFormula() {

        let p = Proof(
            """
                |- ~(p OR q) -> ~p AND ~q
                    ~(p OR q) |- ~p AND ~q
                        ~(p OR q) : Assumption (1)
                        p |- (p OR q) AND ~(p OR q)
                            p : Assumption (3)
                            p  q : OR Introdduction (4)
                            (p OR q) AND ~(p OR q) : AND Introduction (5, 2)
                        ~p : ~ Introduction (3)
                        q |- (p OR q) AND ~(p OR q)
                            q : Assumption (8)
                            p OR q : OR Introduction (9)
                            (p OR q) AND ~(p OR q) : AND Introduction (10, 2)
                        ~q : ~ Introduction (8)
                        ~p AND ~q : AND Introduction (7, 12)
                        ~(p OR q) -> ~p ~q : -> Introduction ()
            """)

        XCTAssertTrue(
            getAdviceTypes(p,
                           forLine:5)
                .contains(AdviceInstance
                    .justifiedFormulaPoorlyFormed))

    }

    func test_proof_with_poorlyFormedThereom_shouldGiveAdvice() {

        let p = Proof(
            """
                p AND q |- q q
                """)

        XCTAssertTrue(
            getAdviceTypes(p,
                           forLine:0)
                .contains(AdviceInstance
                    .theoremFormulaPoorlyFormed))

    }

    func test_proof_with_justifiedThereom_shouldGiveAdvice() {

        let p = Proof(
            """
                p and q |- q : Assumption 0
                """)

        XCTAssertTrue(
            getAdviceTypes(p,
                           forLine:0)
                .contains(AdviceInstance
                    .thereomNeedsNoJustification))

    }

    func test_proof_with_tooManyParametersForJustification_shouldGiveAdvice() {

        let p = Proof(
            """
                p and q |- q and p
                p and q : Assumption 0 0
                """)

        XCTAssertTrue(
            getAdviceTypes(p,
                           forLine:1)
                .contains(AdviceInstance
                    .invalidParemeterCountHighForJustification))

    }

    func test_proof_with_tooFewParametersForJustification_shouldGiveAdvice() {

        let p = Proof(
            """
                p and q |- q and p
                p and q : Assumption
                """)

        XCTAssertTrue(
            getAdviceTypes(p,
                           forLine:1)
                .contains(AdviceInstance
                    .invalidParemeterCountLowForJustification))

    }

    func test_proof_with_withPoorlyFormedJustifiedLine_shouldGiveAdvice() {

        let p = Proof(
            """
                  p and q |- q and p
                  p and q and : Assumption 0
                """)

        XCTAssertTrue(
            getAdviceTypes(p,
                           forLine:1)
                .contains(AdviceInstance
                    .justifiedFormulaPoorlyFormed))

    }

    func test_proof_with_withPoorlyFormedTheoremLine_shouldGiveAdvice() {

        let p = Proof(
            """
                  p and q |- q and p and
                  p and q and : Assumption 0
                """)

        XCTAssertTrue(
            getAdviceTypes(p,
                           forLine:0)
                .contains(AdviceInstance
                    .theoremFormulaPoorlyFormed))

    }

    func test_proof_1_shouldBeProven() {

        let p = ExampleProofs.simpleProof

        XCTAssertTrue(p.getProven())
    }

    func test_proof_2_shouldBeProven() {

       let p = ExampleProofs.orIntroductionProof

        XCTAssertTrue(p.getProven())


    }

    func test_proof_3_shouldBeProven() {

        let p = ExampleProofs.orEliminationProof

        XCTAssertTrue(p.getProven())
    }

    func test_proof_5_shouldBeProven() {

        let p = ExampleProofs.ifEliminationProof

        XCTAssertTrue(p.getProven())
    }

    func test_proof_6_shouldBeProven() {

        let p = ExampleProofs.subProofProof

        XCTAssertTrue(p.getProven())


    }

    func test_proof_7_shouldBeProven() {

        let p = Proof(
            """
                p AND q |- p AND (r OR q)
                p AND q        : Assumption (0)
                p              : AND Elimination (1)
                q              : AND Elimination (1)
                r OR q         : OR Introduction (3)
                p AND (r OR q) : AND Introduction (2, 4)

                """
        )

        XCTAssertTrue(p.getProven())
    }

    func test_proof_8_shouldBeProven() {

        let p = ExampleProofs.ifIntroduction3Proof

        XCTAssertTrue(p.getProven())


    }

    func test_proof_9_shouldBeProven() {

        let p = ExampleProofs.ifIntroduction4Proof

        XCTAssertTrue(p.getProven())

        print(p.htmlVLN)

    }


    func test_proof_10_shouldBeProven() {

        let p = ExampleProofs.ifIntroduction5Proof

        XCTAssertTrue(p.getProven())
    }

    func test_proof_11_shouldBeProven() {

        let p = ExampleProofs.notEliminationProof

        XCTAssertTrue(p.getProven())
    }

    func test_proof_12_shouldBeProven() {

        let p = ExampleProofs.notEliminationProof

        XCTAssertTrue(p.getProven())

    }

    func test_proof_13_shouldBeProven() {

        // CO884 Eercise Sheet 2
        // (a)

        let p = Proof(
            """
                p AND q, p -> r |- r
                p AND q : Assumption (0)
                p -> r  : Assumption (0)
                p       : AND Elimination (1)
                r       : -> Elimination (2, 3)
                """
        )

        XCTAssertTrue(p.getProven())


    }

    func test_proof_14_shouldBeProven() {

        // CO884 Eercise Sheet 2
        // (b)

        let p = Proof(
            """
                p, q AND (p -> s) |- q AND s
                p              : Assumption (0)
                q AND (p -> s) : Assumption (0)
                q              : AND Elimination (2)
                (p -> s)       : AND Elimination (2)
                s              : -> Elimination (1, 4)
                q AND s        : AND Introduction (3, 5)

                """
        )

        XCTAssertTrue(p.getProven())


    }

    func test_proof_15_shouldBeProven() {

        // CO884 Eercise Sheet 2
        // (b)

        let p = Proof(
            """
                p AND q, p -> r |- r OR (q -> r)
                p AND q       : Assumption (0)
                p -> r        : Assumption (0)
                p             : AND Elimination (1)
                r             : -> Elimination (2, 3)
                r OR (q -> r) : OR Introduction (4)

                """
        )

        XCTAssertTrue(p.getProven())



    }

    func test_proof_16_shouldBeProven() {

        // CO884 Eercise Sheet 3
        // (a)

        let p = Proof(
            """
                (p AND q) -> r |- p -> (q -> r)
                    (p AND q) -> r : Assumption (0)
                    p |- (q -> r)
                        p              : Assumption (2)
                        q |- r
                            q              : Assumption (4)
                            p AND q        : AND Introduction (3, 5)
                            r              : -> Elimination (1, 6)
                        q -> r         : -> Introduction (4)
                    p -> (q -> r)  : -> Introduction (2)

                """
        )

        XCTAssertTrue(p.getProven())

    }

    func test_proof_17_shouldBeProven() {

        // CO884 Eercise Sheet 3
        // (b)

        let p = Proof(
            """
                (p OR q) AND r |- (p AND r) OR (q AND r)
                    (p OR q) AND r                : Assumption (0)
                    (p OR q)                      : AND Elimination (1)
                    r                             : AND Elimination (1)
                    p |- (p AND r) OR (q AND r)
                        p                             : Assumption (4)
                        p AND r                       : AND Introduction (5, 3)
                        (p AND r) OR (q AND r)        : OR Introduction (6)
                    p -> ( (p AND r) OR (q AND r)) : -> Introduction (4)
                    q |- (p AND r) OR (q AND r)
                        q                             : Assumption (9)
                        q AND r                       : AND Introduction (10, 3)
                        (p AND r) OR (q AND r)        : OR Introduction (11)
                    q -> ( (p AND r) OR (q AND r)) : -> Introduction (9)
                (p AND r) OR (q AND r)        : OR Elimination (2, 8, 13)

                """
        )


        XCTAssertTrue(p.getProven())

    }

    func test_proof_18_shouldBeProven() {

        // CO884 Eercise Sheet 3
        // (c)

        let p = Proof(
            """
                p -> q |- ~q -> ~p
                    p -> q   : Assumption (0)
                    ~q |- ~p
                        ~q       : Assumption (2)
                        p |- q AND ~q
                            p        : Assumption (4)
                            q        : -> Elimination (1, 5)
                            q AND ~q : AND Introduction (3, 6)
                        ~p       : ~ Introduction (4)
                    ~q -> ~p : -> Introduction (2)

                """
        )

        XCTAssertTrue(p.getProven())

    }

    func test_proof_19_shouldBeProven() {

        // CO884 Eercise Sheet 3
        // (d)

        let p = Proof(
            """
                ~p OR q |- p -> q
                    ~p OR q                      : Assumption (0)
                    ~p |- p -> q
                        ~p                       : Assumption (2)
                        p |- q
                            p                    : Assumption (4)
                            ~q |- p AND ~p
                                p AND ~p : AND Introduction (5, 3)
                            q               : ~ Elimination (6)
                        p -> q              : -> Introduction (4)
                    ~p -> (p -> q)          : -> Introduction (2)
                    q |- p -> q
                        p |- q
                            q                   : Assumption (11)
                        p -> q             : -> Introduction (12)
                    q -> (p -> q)          : -> Introduction (11)
                p -> q               : OR Elimination (1, 10, 15)

                """
        )

        XCTAssertTrue(p.getProven())

    }

    func test_proof_20_shouldBeProven() {

        // CO884 Eercise Sheet 3
        // (e)

        let p = Proof(
            """
                (p OR r) -> q |- (p -> q) OR (r -> q)
                    (p OR r) -> q        : Assumption (0)
                    p |- q
                        p                    : Assumption (2)
                        p OR r               : OR Introduction (3)
                        q                    : -> Elimination (1, 4)
                    p -> q               : -> Introduction (2)
                (p -> q) OR (r -> q) : OR Introduction (6)

                """
        )

        XCTAssertTrue(p.getProven())

    }

    func test_proof_21_shouldBeProven() {

        // CO884 Eercise Sheet 3
        // (f)

        let p = Proof(
            """
                (p AND r) OR (q AND r) |- (p OR q) AND r
                    (p AND r) OR (q AND r)    : Assumption (0)
                    p AND r |- (p OR q) AND r
                        p AND r                   : Assumption (2)
                        p                         : AND Elimination (3)
                        r                         : AND Elimination (3)
                        p OR q                    : OR Introduction (4)
                        (p OR q) AND r            : AND Introduction (6, 5)
                    p AND r -> (p OR q) AND r : -> Introduction (2)
                    q AND r |- (p OR q) AND r
                        q AND r                   : Assumption (9)
                        q                         : AND Elimination (10)
                        r                         : AND Elimination (10)
                        p OR q                    : OR Introduction (11)
                        (p OR q) AND r            : AND Introduction (13, 12)
                    q AND r -> (p OR q) AND r : -> Introduction (9)
                (p OR q) AND r            : OR Elimination (1, 8, 15)

                """
        )

        XCTAssertTrue(p.getProven())

    }

    func test_proof_22_shouldBeProven() {

        // CO884 Eercise Sheet 3
        // (g)

        let p = Proof(
            """
                ~p OR ~q |- ~(p AND q)
                    ~p OR ~q                                       : Assumption (0)
                    p AND q |- p AND ~p
                        p AND q                                    : Assumption (2)
                        p                                     : AND Elimination (3)
                        q                                     : AND Elimination (3)
                        ~p |- p AND ~p
                            ~p                                     : Assumption (6)
                            p AND ~p                      : AND Introduction (4, 7)
                        ~p -> p AND ~p                        : -> Introduction (6)
                        ~q |- p AND ~p
                            ~q                                    : Assumption (10)
                            p |- q AND ~q
                                p                                 : Assumption (12)
                                q AND ~q                 : AND Introduction (5, 11)
                            ~p                              : ~ Introduction (12)
                            p AND ~p                     : AND Introduction (15, 4)
                        ~q -> p AND ~p                       : -> Introduction (10)
                        p AND ~p                        : OR Elimination (17, 9, 1)
                    ~(p AND q)                               : ~ Introduction (2)

                """
        )

        XCTAssertTrue(p.getProven())

    }


    func test_proof_24_shouldBeProven() {

        // CO884 Eercise Sheet 3
        // (i)

        let p = Proof(
            """
                |- p OR ~p
                    ~(p OR ~p) |- (p OR ~p) AND ~(p OR ~p)
                        ~(p OR ~p)                             : Assumption (1)
                        p |- (p OR ~p) AND ~(p OR ~p)
                            p                                  : Assumption (3)
                            p OR ~p                       : OR Introduction (4)
                            (p OR ~p) AND ~(p OR ~p)  : AND Introduction (5, 2)
                        ~p                               : ~ Introduction (3)
                        p OR ~p                           : OR Introduction (7)
                        (p OR ~p) AND ~(p OR ~p)      : AND Introduction (2, 5)
                    p OR ~p                               : ~ Elimination (1)

                """
        )

        XCTAssertTrue(p.getProven())

    }


    func test_proof_25_shouldBeProven() {

        let p = Proof(
            """
              |- p OR ~p
                ~(p OR ~p) |- p AND ~p
                    ~(p OR ~p)                                      : Assumption (1)
                    p |- (p OR ~p) AND ~(p OR ~p)
                        p                                           : Assumption (3)
                        p OR ~p                                : OR Introduction (4)
                        (p OR ~p) AND ~(p OR ~p)           : AND Introduction (5, 2)
                    ~p                                        : ~ Introduction (3)
                    ~p |- (p OR ~p) AND ~(p OR ~p)
                        ~p                                          : Assumption (8)
                        p OR ~p                                : OR Introduction (9)
                        (p OR ~p) AND ~(p OR ~p)          : AND Introduction (10, 2)
                    p                                          : ~ Elimination (8)
                    p AND ~p                              : AND Introduction (12, 7)
                p OR ~p                                        : ~ Elimination (1)
            """
        )

        XCTAssertTrue(p.getProven())

    }

    func test_proof_26_shouldBePRoven() {

        let p = ExampleProofs.falseEliminationProof

        XCTAssertTrue(p.getProven())

    }

    func test_proof_withSameLHSandRHS_shouldNotBeProven() {

        let p = Proof("p and q |- p and q")

        XCTAssertFalse(p.getProven())
    }



    func test_proof_7_shouldBeNotProven() {

        let p = Proof(
            """
                p AND q |- p AND (r OR q)
                p AND q        : Assumption ()
                p              : AND Elimination (1)
                q              : AND Elimination (1)
                r OR q         : OR Introduction (3)
                p AND (r OR q) : AND Introduction (2, 4)

                """
        )

        XCTAssertFalse(p.getProven())
    }




    func test_proof_13_shouldBeNotProven() {

        // CO884 Eercise Sheet 2
        // (a)

        let p = Proof(
            """
                p AND q, p -> r |- r
                p AND q : Assumption (0)
                p       : AND Elimination (1)
                r       : -> Elimination (2, 3)
                """
        )

        XCTAssertFalse(p.getProven())



    }

    func test_proof_14_shouldBeNotProven() {

        // CO884 Eercise Sheet 2
        // (b)

        let p = Proof(
            """
                p, qq AND (p -> s) |- q AND s
                p              : Assumption (0)
                q AND (p -> s) : Assumption (0)
                q              : AND Elimination (2)
                (p -> s)       : AND Elimination (2)
                s              : -> Elimination (1, 4)
                q AND s        : AND Introduction (3, 5)

                """
        )

        XCTAssertFalse(p.getProven())


    }

    func test_proof_15_shouldBeNotProven() {

        // CO884 Eercise Sheet 2
        // (b)

        let p = Proof(
            """
                p AND q, p -> r |- r OR (q -> r)
                p AND q       : Assumption (0)
                p <-> r        : Assumption (0)
                p             : AND Elimination (1)
                r             : -> Elimination (2, 3)
                r OR (q -> r) : OR Introduction (4)

                """
        )

        XCTAssertFalse(p.getProven())

    }

    func test_proof_16_shouldBeNotProven() {

        // CO884 Eercise Sheet 3
        // (a)

        let p = Proof(
            """
                (p AND q) -> r |- p -> (q -> r)
                    (p AND q) -> r : Assumption (0)
                    p |- (q -> r)
                        p              : Assumption (3)
                        q |- r
                            q              : Assumption (4)
                            p AND q        : AND Introduction (3, 5)
                            r              : -> Elimination (1, 6)
                        q -> r         : -> Introduction (4)
                    p -> (q -> r)  : -> Introduction (2)

                """
        )

        XCTAssertFalse(p.getProven())

    }

    func test_proof_17_shouldBeNotProven() {

        // CO884 Eercise Sheet 3
        // (b)

        let p = Proof(
            """
                (p OR q) AND r |- (p AND r) OR (q AND r)
                    (p OR q) AND r                : Assumption (0)
                    (p OR q)                      : AND Elimination (1)
                    r                             : AND Elimination (1)
                    p |- (p AND r) OR (q AND r)
                        p                             : Assumption (4)
                        p AND r                       : AND Introduction (5, 3)
                        (p AND r) OR (q AND r)        : OR Introduction (6)
                    p -> ( (p AND r) OR (q AND r)) : -> Introduction (4)
                    q |- (p AND r) OR (q AND r)
                        q                             : Assumption (9)
                        q AND r                       : AND Introduction (10, 3)
                        (p AND r) OR (q AND r)        : OR Introduction (11)
                    q -> ( (p AND r) OR (q AND r)) : -> Introduction (9)
                (p AND r) OR (q AND r)        : OR Elimination (2, 9, 13)

                """
        )

        XCTAssertFalse(p.getProven())

    }

    func test_proof_18_shouldBeNotProven() {

        // CO884 Eercise Sheet 3
        // (c)

        let p = Proof(
            """
                p -> q |- ~q -> ~p
                    p -> q   : Assumption (0)
                    ~q |- ~p
                        ~q       : Assumption (2)
                        p |- q AND ~q
                            p        : Assumption (4)
                            q        : -> Elimination (1, 5, 4)
                            q AND ~q : AND Introduction (3, 6)
                        ~p       : ~ Introduction (4)
                    ~q -> ~p : -> Introduction (2)

                """
        )

        XCTAssertFalse(p.getProven())

    }

    func test_proof_19_shouldBeNotProven() {

        // CO884 Eercise Sheet 3
        // (d)

        let p = Proof(
            """
                ~p OR q |- p -> q
                    ~p OR q                      : Assumption (0, 1)
                    ~p |- p -> q
                        ~p                       : Assumption (2)
                        p |- q
                            p                    : Assumption (4)
                            ~q |- p AND ~p
                                p AND ~p : AND Introduction (5, 3)
                            q               : ~ Elimination (6)
                        p -> q              : -> Introduction (4)
                    ~p -> (p -> q)          : -> Introduction (2)
                    q |- p -> q
                        p |- q
                            q                   : Assumption (11)
                        p -> q             : -> Introduction (12)
                    q -> (p -> q)          : -> Introduction (11)
                p -> q               : OR Elimination (1, 10, 15)

                """
        )

        XCTAssertFalse(p.getProven())

    }

    func test_proof_20_shouldBeNotProven() {

        // CO884 Eercise Sheet 3
        // (e)

        let p = Proof(
            """
                (p OR r) -> q |- (p -> q) OR (r -> q)
                    (p OR r) -> q        : Assumption (0)
                    p |- q
                    p |- q
                        p                    : Assumption (2)
                        p OR r               : OR Introduction (3)
                        q                    : -> Elimination (1, 4)
                    p -> q               : -> Introduction (2)
                (p -> q) OR (r -> q) : OR Introduction (6)

                """
        )

        XCTAssertFalse(p.getProven())

    }

    func test_proof_21_shouldBeNotProven() {

        // CO884 Eercise Sheet 3
        // (f)

        let p = Proof(
            """
                (p AND r) OR (q AND r) |- (p OR q) AND r
                    (p AND r) OR (q AND r)    : Assumption (0)
                    p AND r |- (p OR q) AND r
                        p AND r                   : Assumption (2)
                        p                         : AND Elimination (3)
                                                 : AND Elimination (3)
                        p OR q                    : OR Introduction (4)
                        (p OR q) AND r            : AND Introduction (6, 5)
                    p AND r -> (p OR q) AND r : -> Introduction (2)
                    q AND r |- (p OR q) AND r
                        q AND r                   : Assumption (9)
                        q                         : AND Elimination (10)
                        r                         : AND Elimination (10)
                        p OR q                    : OR Introduction (11)
                        (p OR q) AND r            : AND Introduction (13, 12)
                    q AND r -> (p OR q) AND r : -> Introduction (9)
                (p OR q) AND r            : OR Elimination (1, 8, 15)

                """
        )

        XCTAssertFalse(p.getProven())

    }

    func test_proof_22_shouldBeNotProven() {

        // CO884 Eercise Sheet 3
        // (g)

        let p = Proof(
            """
                ~p OR ~q |- ~(p AND q)
                    ~p OR ~q                                       : Assumption (0)
                    p AND q |- p AND ~p
                        p AND q                                    : Assumption (2)
                        p                                     : AND Elimination (3)
                        q                                     : AND Elimination (3)
                        ~p |- p AND ~p
                            ~p                                     : Assumption (6)
                            p AND ~p                      : AND Introduction (4, 7)
                        ~p -> p AND ~p                        : -> Introduction (6)
                        ~q |- p AND ~p
                            ~q                                    : Assumption (10)
                            p |- q AND ~q
                                p                                 : Assumption (12)
                                q AND ~q                 : AND Introduction (5, 11)
                            ~p                              : ~ Introduction (12)
                            p AND ~p                     : AND Introduction (15, 4)
                        ~q -> p AND ~p                       : -> Introduction (10, 11)
                        p AND ~p                        : OR Elimination (17, 9, 1)
                    ~(p AND q)                               : ~ Introduction (2)

                """
        )

        XCTAssertFalse(p.getProven())

    }

    func test_proof_23_shouldBeNotProven() {

        // CO884 Eercise Sheet 3
        // (h)

        let p = Proof(
            """
                |- ~p OR ~q <-> ~(p AND q)
                    ~p OR ~q |- ~(p AND q)
                        ~(p AND q) |- ~p OR ~q
                            ~(p AND q)                                            : Assumption (2)
                            ~(~p OR ~q) |- (p AND q) AND ~(p AND q)
                                ~(~p OR ~q)                                       : Assumption (4)
                                ~p |- ~(~p OR ~q) AND (~p OR ~q)
                                    ~p                                            : Assumption (6)
                                    ~p OR ~q                                 : OR Introduction (7)
                                    ~(~p OR ~q) AND (~p OR ~q)           : AND Introduction (5, 8)
                                p                                            : ~ Elimination (6)
                                ~q |- ~(~p OR ~q) AND (~p OR ~q)
                                    ~q                                           : Assumption (11)
                                    ~p OR ~q                                : OR Introduction (12)
                                    ~(~p OR ~q) AND (~p OR ~q)          : AND Introduction (5, 13)
                                q                                           : ~ Elimination (11, -1)
                                p AND q                                : AND Introduction (10, 15)
                                (p AND q) AND ~(p AND q)                : AND Introduction (16, 3)
                            ~p OR ~q                                         : ~ Elimination (4)
                        ~p OR ~q -> ~(p AND q)                               : -> Introduction (1)
                    ~(p AND q) -> ~p OR ~q                                   : -> Introduction (2)
                    ~p OR ~q <-> ~(p AND q)                            : <-> Introduction (19, 20)

                """
        )

        XCTAssertFalse(p.getProven())

    }

    func test_proof_24_shouldBeNotProven() {

        // CO884 Eercise Sheet 3
        // (i)

        let p = Proof(
            """
                |- p OR ~p
                    ~(p OR ~p) |- (p OR ~p) AND ~(p OR ~p)
                        ~(p OR ~p)                             : Assumption (1)
                        p |- (p OR ~p) AND ~(p OR ~p)
                            true                                  : Assumption (3)
                            p OR ~p                       : OR Introduction (4)
                            (p OR ~p) AND ~(p OR ~p)  : AND Introduction (5, 2)
                        ~p                               : ~ Introduction (3)
                        p OR ~p                           : OR Introduction (7)
                        (p OR ~p) AND ~(p OR ~p)      : AND Introduction (2, 5)
                    p OR ~p                               : ~ Elimination (1)

                """
        )

        XCTAssertFalse(p.getProven())

    }


    func test_proof_25_shouldBeNotProven() {

        let p = Proof(
            """
              |- p OR ~p
                ~(p OR ~p) |- p AND ~p
                    p |- (p OR ~p) AND ~(p OR ~p)
                        p                                           : Assumption (3)
                        p OR ~p                                : OR Introduction (4)
                        (p OR ~p) AND ~(p OR ~p)           : AND Introduction (5, 2)
                    ~p                                        : ~ Introduction (3)
                    ~p |- (p OR ~p) AND ~(p OR ~p)
                        ~p                                          : Assumption (8)
                        p OR ~p                                : OR Introduction (9)
                        (p OR ~p) AND ~(p OR ~p)          : AND Introduction (10, 2)
                    p                                          : ~ Elimination (8)
                    p AND ~p                              : AND Introduction (12, 7)
                p OR ~p                                        : ~ Elimination (1)
            """
        )

        XCTAssertFalse(p.getProven())

    }

}
