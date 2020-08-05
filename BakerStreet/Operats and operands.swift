//
//  Operats and operands.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Foundation

/**
 Operator Token type, including `precedence`, `arity` and `associativity`

 For more on `precedence`,  see this reference:
 http://intrologic.stanford.edu/glossary/operator_precedence.html
 - The ¬ operator has higher precedence than ∧;
 - ∧ has higher precedence than ∨;
 - and ∨ has higher precedence than ⇒ and ⇔.
 */
public struct OperatorToken: CustomStringConvertible {
    let operatorType: OperatorType

    public init(operatorType: OperatorType) {
        self.operatorType = operatorType
    }

    var precedence: Int {
        switch operatorType {
        case .lIf, .lIff:
            return 0
        case .lOr:
            return 1
        case .lAnd:
            return 5
        case .lNot:
            return 10
        }
    }

    var arity: Int {
        switch operatorType {
        case .lIf, .lIff, .lOr, .lAnd:
            return 2
        case .lNot:
            return 1
        }
    }

    /** Returns `associativity`
     See  https://en.wikipedia.org/wiki/Operator_associativity
     */
    var associativity: OperatorAssociativity {
        switch operatorType {
        case .lAnd, .lOr, .lIf, .lIff:
            return .leftAssociative
        case .lNot:
            return .rightAssociative
        }
    }

    public var description: String {
        return operatorType.description
    }
}

/**
 A type to store how we match operands in a string

 An operand must be:
 - in the set a-z or A-Z
 - one character in length
 - Exceptions:
 - `true`
 - `false`
 */
public struct OperandToken {

    /// Returns the regular expression
    public var pattern: String {
        return "^[a-zA-Z]{1}$"
    }

    public var special: [String] {
        return ["true","false"]
    }
}

/**
 Convenience function allowing a comparison of `OperatorToken` precedence.

 We need to consider this in cases of ambiguity, e.g. "p AND q OR s"

 ```
 Graph of: p AND q OR s
 AND
 OR
 s
 q
 p
 ```

 ## Tests
 Included in test `PrecedenceTests`

 - Parameters:
 - left: The lefthand OperatorToken
 - `right`: The righthand OperatorToken
 - Returns: True if `right` has higher or equal precedence as left.
 */
public func <= (left: OperatorToken, right: OperatorToken) -> Bool {
    return left.precedence <= right.precedence
}

/**
 Convenience function allowing a copmarison of `OperatorToken`precedence.

 ## Tests
 Included in test `PrecedenceTests`

 - Parameters:
 - left: The lefthand OperatorToken
 - right: The righthand OperatorToken
 - Returns: True if `left` has lower precedence.
 */
public func < (left: OperatorToken, right: OperatorToken) -> Bool {
    return left.precedence < right.precedence
}

/// The Token type, e.g. operand
public struct Token: CustomStringConvertible {
    let tokenType: TokenType

    /// Returns the specified `TokenType`
    public init(tokenType: TokenType) {
        self.tokenType = tokenType
    }

    /// Returns the specified `Operand` `TokenType`
    public init(operand: String) {
        tokenType = .operand(operand)
    }

    /// Returns the specified `Operator` `TokenType`
    public init(operatorType: OperatorType) {
        tokenType = .Operator(OperatorToken(operatorType: operatorType))
    }

    /// If the `Token` is an operator, return it
    var operatorToken: OperatorToken? {
        switch tokenType {
        case .Operator(let operatorToken):
            return operatorToken
        default:
            return nil
        }
    }

    var isNegation: Bool {
        switch tokenType {
        case .Operator(let operatorToken):
            return operatorToken.operatorType == .lNot
        default:
            return false
        }
    }

    var isOpenBracket: Bool {
        switch tokenType {
        case .openBracket:
            return true
        default:
            return false
        }
    }

    var isCloseBracket: Bool {
        switch tokenType {
        case .closeBracket:
            return true
        default:
            return false
        }
    }

    var isOperand: Bool {
        switch tokenType {
        case .operand(_):
            return true
        default:
            return false
        }
    }

    var isOperator: Bool {
        switch tokenType {
        case .Operator(_):
            return true
        default:
            return false
        }
    }

    var isPoorlyFormed: Bool {
        switch tokenType {
        case .poorlyFormed:
            return true
        default:
            return false
        }
    }

    public var description: String {
        return tokenType.description
    }
}
