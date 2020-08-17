//
//  Justification.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Foundation

public enum Justification: CaseIterable {
    
    case empty
    case assumption
    case andIntroduction
    case orIntroduction
    case notIntroduction
    case ifIntroduction
    case iffIntroduction
    case andElimination
    case orElimination
    case notElimination
    case ifElimination
    case iffElimination
    case trueIntroduction
    case falseElimination

    var description: String {
        switch self {
            case .empty:
                return ""
            case .assumption:
                return "Assumption"
            // e.g. "AND Introduction"
            case .andIntroduction:
                return OperatorType.lAnd.description + " Introduction"
            case .orIntroduction:
                return OperatorType.lOr.description + " Introduction"
            case .notIntroduction:
                return OperatorType.lNot.description + " Introduction"
            case .ifIntroduction:
                return OperatorType.lIf.description + " Introduction"
            case .iffIntroduction:
                return OperatorType.lIff.description + " Introduction"
            case .andElimination:
                return OperatorType.lAnd.description + " Elimination"
            case .orElimination:
                return OperatorType.lOr.description + " Elimination"
            case .notElimination:
                return OperatorType.lNot.description + " Elimination"
            case .ifElimination:
                return OperatorType.lIf.description + " Elimination"
            case .iffElimination:
                return OperatorType.lIff.description + " Elimination"

            case .trueIntroduction:
                return "true Introduction"
            case .falseElimination:
                return "false Elimination"
        }
    }

    var htmlEntityDescription: String {
        switch self {
            case .empty:
                return ""
            case .assumption:
                return ""
            // e.g. "AND Introduction"
            case .andIntroduction:
                return OperatorType.lAnd.htmlEntity + "-Introduction"
            case .orIntroduction:
                return OperatorType.lOr.htmlEntity + "-Introduction"
            case .notIntroduction:
                return OperatorType.lNot.htmlEntity + "-Introduction"
            case .ifIntroduction:
                return OperatorType.lIf.htmlEntity + "-Introduction"
            case .iffIntroduction:
                return OperatorType.lIff.htmlEntity + "-Introduction"
            case .andElimination:
                return OperatorType.lAnd.htmlEntity + "-Elimination"
            case .orElimination:
                return OperatorType.lOr.htmlEntity + "-Elimination"
            case .notElimination:
                return OperatorType.lNot.htmlEntity + "-Elimination"
            case .ifElimination:
                return OperatorType.lIf.htmlEntity + "-Elimination"
            case .iffElimination:
                return OperatorType.lIff.htmlEntity + "-Elimination"

            case .trueIntroduction:
                return "true-Introduction"
            case .falseElimination:
                return "false-Elimination"
        }
    }

    // Primarily used for exporting proofs
    // We use HTML entities for glyphs
    var htmlEntityShortDescription: String {
        switch self {
            case .empty:
                return ""
            case .assumption:
                return "ass"

            case .andIntroduction:
                return OperatorType.lAnd.htmlEntity + "-I"
            case .orIntroduction:
                return OperatorType.lOr.htmlEntity + "-I"
            case .notIntroduction:
                return OperatorType.lNot.htmlEntity + "-I"
            case .ifIntroduction:
                return OperatorType.lIf.htmlEntity + "-I"
            case .iffIntroduction:
                return OperatorType.lIff.htmlEntity + "-I"

            case .andElimination:
                return OperatorType.lAnd.htmlEntity + "-E"
            case .orElimination:
                return OperatorType.lOr.htmlEntity + "-E"
            case .notElimination:
                return OperatorType.lNot.htmlEntity + "-E"
            case .ifElimination:
                return OperatorType.lIf.htmlEntity + "-E"
            case .iffElimination:
                return OperatorType.lIff.htmlEntity + "-E"

            case .trueIntroduction:
                return "<em>true</em>" + "-E"
            case .falseElimination:
                return "<em>false</em>" + "-E"

        }

    }

    // Primarily used for exporting proofs
    // We use HTML entities for glyphs
    var latexEntityShortDescription: String {
        let mStart = "\\("
        let mEnd = "\\)"

        switch self {
            case .empty:
                return ""
            case .assumption:
                return "ass"

            case .andIntroduction:
                return mStart + OperatorType.lAnd.latexEntity + mEnd + "-I"
            case .orIntroduction:
                return mStart + OperatorType.lOr.latexEntity + mEnd + "-I"
            case .notIntroduction:
                return mStart + OperatorType.lNot.latexEntity + mEnd + "-I"
            case .ifIntroduction:
                return mStart + OperatorType.lIf.latexEntity + mEnd + "-I"
            case .iffIntroduction:
                return mStart + OperatorType.lIff.latexEntity + mEnd + "-I"

            case .andElimination:
                return mStart + OperatorType.lAnd.latexEntity + mEnd + "-E"
            case .orElimination:
                return mStart + OperatorType.lOr.latexEntity + mEnd + "-E"
            case .notElimination:
                return mStart + OperatorType.lNot.latexEntity + mEnd + "-E"
            case .ifElimination:
                return mStart + OperatorType.lIf.latexEntity + mEnd + "-E"
            case .iffElimination:
                return mStart + OperatorType.lIff.latexEntity + mEnd + "-E"

            case .trueIntroduction:
                return "\\emph{true}" + "-E"
            case .falseElimination:
                return "\\emph{false}" + "-E"

        }

    }

    // Primarily used for sorting into an order that
    // makes sense for a student when giving definitions of all.
    // Lowest first
    var order: Int {
        switch self {
            case .empty:
                return 0
            case .assumption:
                return 0

            case .andIntroduction:
                return 1
            case .andElimination:
                return 2
            case .orIntroduction:
                return 3
            case .orElimination:
                    return 4
            case .iffIntroduction:
                return 5
            case .iffElimination:
                return 6
            case .ifIntroduction:
                return 7
            case .ifElimination:
                return 8
            case .notIntroduction:
                return 9
            case .notElimination:
                return 10
            case .trueIntroduction:
                return 11
            case .falseElimination:
                return 12

        }
    }

    // Arity
    var arity: Int {
        switch self {
            case .empty:
                return 0
            case .assumption:
                return 1
            case .andIntroduction:
                return 2
            case .orIntroduction:
                return 1
            case .notIntroduction:
                return 1
            case .ifIntroduction:
                return 1
            case .iffIntroduction:
                return 2
            case .andElimination:
                return 1
            case .orElimination:
                return 3
            case .notElimination:
                return 1
            case .ifElimination:
                return 2
            case .iffElimination:
                return 1
            case .trueIntroduction:
                return 0
            case .falseElimination:
                return 1
        }
    }

    // Type
    // This intended for use as the adjective prior to naming
    // the justification. So you'd say "your justification Assumption" or
    // "your inference rule AND Elimination"
    var type: String {
        switch self {
            case .assumption, .empty:
                return "justification"
            case .andIntroduction, .orIntroduction, .notIntroduction, .ifIntroduction, .iffIntroduction, .andElimination, .orElimination, .notElimination, .ifElimination, .iffElimination, .trueIntroduction, .falseElimination:
                return "inference"
        }
    }

    var alternativeAntecedents: String {
        switch self {
            case .andElimination:

                return "A or B".formulaToHTMLRespectingCase

            case .orIntroduction:

                return "B".formulaToHTMLRespectingCase

            case .iffElimination:

                let a1 = "A <-> B".formulaToHTMLRespectingCase

                return a1

            case .assumption, .empty, .andIntroduction, .orElimination, .notIntroduction, .ifIntroduction, .iffIntroduction, .notElimination, .ifElimination, .trueIntroduction, .falseElimination:
                return ""
        }

    }

    var antecedents: String {
        switch self {
            case .empty:
                return ""
            case .assumption:
                return ""
            case .andIntroduction:

                return "formulas " + "A".formulaToHTMLRespectingCase + ", " +
                    "B".formulaToHTMLRespectingCase

            case .orIntroduction:

                return "formula " + "A".formulaToHTMLRespectingCase

            case .notIntroduction:

                let p = Proof("A |- B and ~B",
                              isPedagogic: true,
                              respectCase: true)
                return p.htmlVLN

            case .iffIntroduction:

                let a1 = "A -> B".formulaToHTMLRespectingCase
                let a2 = "B -> A".formulaToHTMLRespectingCase

                return "formulas " + a1 + ", " + a2

            case .ifIntroduction:

                let p = Proof("A |- B", isPedagogic: true, respectCase: true)
                return p.htmlVLN

            case .andElimination:

                return "formulas " + "A and B".formulaToHTMLRespectingCase

            case .orElimination:

                let a1 = "A or B".formulaToHTMLRespectingCase
                let a2 = "A -> C".formulaToHTMLRespectingCase
                let a3 = "B -> C".formulaToHTMLRespectingCase

                return "formulas " + a1 + ", " + a2 + ", " + a3

            case .notElimination:

                let p = Proof("~A |- B and ~B",
                              isPedagogic: true,
                              respectCase: true)
                return p.htmlVLN

            case .ifElimination:
                let a1 = "A -> B".formulaToHTMLRespectingCase
                let a2 = "A".formulaToHTMLRespectingCase

                return "formulas " + a1 + ", " + a2

            case .iffElimination:

                let a1 = "A <-> B".formulaToHTMLRespectingCase

                return "formula " + a1

            case .trueIntroduction:

                return "Anything"

            case .falseElimination:

                return "formula " + "false".formulaToHTML

        }
    }

    var alternativeConsequents: String {
        switch self {
            case .andElimination:

                return "formula " + "B".formulaToHTMLRespectingCase

            case .orIntroduction:

                return "formula " + "A or B".formulaToHTMLRespectingCase

            case .iffElimination:

                return "formula " + "B -> A".formulaToHTMLRespectingCase

            case .assumption, .empty, .andIntroduction, .orElimination, .notIntroduction, .ifIntroduction, .iffIntroduction, .notElimination, .ifElimination, .trueIntroduction, .falseElimination:
                return ""
        }

    }

    var consequent: String {
        switch self {
            case .empty:
                return ""
            case .assumption:
                return ""
            case .andIntroduction:

                return "formula " + "A and B".formulaToHTMLRespectingCase

            case .orIntroduction:

                return "formula " + "A or B".formulaToHTMLRespectingCase

            case .notIntroduction:

                return "formula " + "~A".formulaToHTMLRespectingCase

            case .iffIntroduction:

                return "formula " + "A <-> B".formulaToHTMLRespectingCase

            case .ifIntroduction:

                return "formula " + "A -> B".formulaToHTMLRespectingCase


            case .andElimination:

                return "formula " + "A".formulaToHTMLRespectingCase

            case .orElimination:

                return "formula " + "C".formulaToHTMLRespectingCase

            case .notElimination:

                return "formula " + "A".formulaToHTMLRespectingCase

            case .ifElimination:

                return "formula " + "B".formulaToHTMLRespectingCase

            case .iffElimination:

                return "formula " + "A -> B".formulaToHTMLRespectingCase

            case .trueIntroduction:

                return "formula " + "true".formulaToHTML

            case .falseElimination:

                return "formula " + "A".formulaToHTMLRespectingCase

        }
    }

    var example: String {

        switch self {
            case .empty:
                return ""
            case .assumption:
                return ""
            case .andIntroduction:
                return ExampleProofs.simpleProof.htmlVLN
            case .orIntroduction:
                return ExampleProofs.orIntroductionProof.htmlVLN
            case .notIntroduction:
                return ExampleProofs.notIntroductionProof.htmlVLN
            case .ifIntroduction:
                return ExampleProofs.ifIntroduction3Proof.htmlVLN
            case .iffIntroduction:
                return ExampleProofs.iffIntroductionProof.htmlVLN
            case .andElimination:
                return ExampleProofs.ifEliminationProof.htmlVLN
            case .orElimination:
                return ExampleProofs.orEliminationProof.htmlVLN
            case .notElimination:
                return ExampleProofs.notEliminationProof.htmlVLN
            case .ifElimination:
                return ExampleProofs.ifEliminationProof.htmlVLN
            case .iffElimination:
                return ""
            case .trueIntroduction:
                return ""
            case .falseElimination:
                return ExampleProofs.falseEliminationProof.htmlVLN
        }
    }

}

extension Justification: Comparable {
    public static func < (lhs: Justification, rhs: Justification) -> Bool {

        return lhs.order < rhs.order
    }
}
