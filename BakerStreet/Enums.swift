//
//  Enums.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Foundation

/// A logical operator associativity type, e.g. left associative.
public enum OperatorAssociativity {
    case leftAssociative
    case rightAssociative
}

/// The syntactic turnstile
public enum MetaType: CustomStringConvertible {
    case turnStile
    case justificationSeparator

    /// Returns the string
    public var description: String {
        switch self {
        case .turnStile:
            return "|-"
        case .justificationSeparator:
            return ":"
        }
    }

    /// Returns the HTML string
    public var htmlEntity: String {
        switch self {
        case .turnStile:
            return " &#8870; "
        case .justificationSeparator:
            return ":"
        }
    }

    /// Returns the Latex string
    public var latexEntity: String {
        switch self {
            case .turnStile:
                return " \\vdash "
            case .justificationSeparator:
                return ":"
        }
    }

    /// Returns the glyph
    public var glyph: String {
        switch self {
            case .turnStile:
                return "⊦"
            case .justificationSeparator:
                return ":"
        }
    }

}

/// A logical operator type (e.g. `and`)
///
/// Currently, we have `and`, `or`, `not`, `if` and `iff` (bi-directional if)
public enum OperatorType: CustomStringConvertible, CaseIterable {
    case lAnd
    case lOr
    case lNot
    case lIff
    case lIf

    /// Returns the string of the operator type.
    public var description: String {
        switch self {
            case .lAnd:
                return "AND"
            case .lOr:
                return "OR"
            case .lNot:
                return "~"
            case .lIff:
                return "<->"
            case .lIf:
                return "->"
        }
    }

    /// Returns the glyph of the operator type.
    public var glyph: String {
        switch self {
            case .lAnd:
                return "∧"
            case .lOr:
                return "∨"
            case .lNot:
                return "¬"
            case .lIff:
                return "↔"
            case .lIf:
                return "→"
        }
    }

    /// Returns the HTML string of the operator type.
    public var htmlEntity: String {
        switch self {
            case .lAnd:
                return "&and;"
            case .lOr:
                return "&or;"
            case .lNot:
                return "&not;"
            case .lIff:
                return "&harr;"
            case .lIf:
                return "&rarr;"
        }
    }

    /// Returns the Latex string of the operator type.
    public var latexEntity: String {
        switch self {
            case .lAnd:
                return "\\land"
            case .lOr:
                return "\\lor"
            case .lNot:
                return "\\lnot"
            case .lIff:
                return "\\Leftrightarrow"
            case .lIf:
                return "\\Rightarrow"
        }
    }


}

/**
 The main Token type (e.g. `operator`).

 We have four types of token:

 - `bracket`
 - `operator`
 - `operand`
 - `poorly formed`
 - `empty`

 ## Poorly Formed
 Poorly formed is used *only* during evaluation, not string tokenising.
 For example, when evaluation fails (e.g. `AND `is given only
 one argument) we drop a `poorly  formed` token into the
 returned array of Tokens. A formula with any one of these means
 the whole formula must be poorly formed.

 ## Empty
 This is useful when we want to initialise a Token type without filling it
 with something meaningful.
 */
public enum TokenType: CustomStringConvertible, Hashable {

    public static func == (lhs: TokenType, rhs: TokenType) -> Bool {
        lhs.description == rhs.description
    }

    case openBracket
    case closeBracket
    case Operator(OperatorToken)
    case operand(String)
    case poorlyFormed
    case empty

    /// Returns the string of the operator type.
    public var description: String {
        switch self {
            case .openBracket:
                return "("
            case .closeBracket:
                return ")"
            case .Operator(let operatorToken):
                return operatorToken.description
            case .operand(let value):
                return "\(value)"
            case .poorlyFormed:
                return "PF"
            case .empty:
                return ""
        }
    }

}

public enum CompletionMode: String {
    case justification
    case logic
    case all

    public var completions: [String] {
        switch self {
        case .justification:
            let completion =
                [": " + Justification.assumption.description + " ",
                 ": " + Justification.andIntroduction.description + " ",
                 ": " + Justification.orIntroduction.description + " ",
                 ": " + Justification.notIntroduction.description + " ",
                 ": " + Justification.ifIntroduction.description + " ",
                 ": " + Justification.iffIntroduction.description + " ",
                 ": " + Justification.andElimination.description + " ",
                 ": " + Justification.orElimination.description + " ",
                 ": " + Justification.notElimination.description + " ",
                 ": " + Justification.ifElimination.description + " ",
                 ": " + Justification.iffElimination.description + " ",
                 ": " + Justification.trueIntroduction.description + " ",
                 ": " + Justification.falseElimination.description + " "]
            return completion
        case .logic:
            let completion =
                [OperatorType.lAnd.description + " ",
                 OperatorType.lOr.description + " ",
                 OperatorType.lNot.description + " ",
                 OperatorType.lIf.description + " ",
                 OperatorType.lIff.description + " ",
                 MetaType.turnStile.description + " "]
            return completion
        case .all:
            var completion = CompletionMode.justification.completions
            let logi = CompletionMode.logic.completions
            completion.append(contentsOf: logi)

            return completion
        }
    }

}
