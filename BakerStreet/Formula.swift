//
//  Formula.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Foundation


/// Holds a formula, e.g. `p AND p`
public struct Formula: Equatable {

    public let identifier =               UUID()  // i.e. 4 random bytes
    public var infixText:                 String  // e.g. `p AND p`
    public var tokenStringHTML:           String  // e.g. `<em>p</em>`
    public var tokenStringHTMLPrettified: String  // e.g. `<em>p</em>∧<em>q</em>`
    public var tokenStringHTMLPrettifiedUppercased: String
    public let postfixText:               String  // e.g. `p p AND`
    public var isWellFormed:              Bool    // e.g. `true`
    public let tree:                      Tree    // `Tree` representation
    public var truthResult:               String  // e.g. "true", empty if
                                                  //   not well formed
    public var truthTable:                [String] // e.g. ["true", "false"]

    // e.g. 'An invalidStringLength error occured'
    public var error =       ""
    public var tokens =      [Token(tokenType: .empty)]

    /// Initialises with a formula and evaluates
    ///
    /// - Parameter infixText: the formula as a string, e.g. `p AND p`
    ///
    /// - Warning: Catches to `error` string
    ///   - `invalidStringLength` from `Lexer.init()`
    ///   - `invalidTokenArrayLength` from `reversePolish()`
    ///   - `invalidRpnTokensArrayLength` from
    ///   `reversePolish.rpnEvaluate()`
    public init (_ infixText: String,
                 withTruthTable: Bool = false,
                 forNTruthTableVariables: Int = 0) {

        do {
            
            var l = try Lexer(text: infixText) // Initialise
            let t = l.getTokenised()           // Get array of Token

            var rpn = try RpnMake(infixFormula: t)

            try rpn.rpnEvaluate() // Evaluate RPN

            self.infixText = l.getTokenString()       // e.g. `p AND p`

            // e.g. `<em>p</em>`
            self.tokenStringHTML = l.tokenStringHTML

            // e.g. `<em>p</em> ∧ <em>q</em>`
            self.tokenStringHTMLPrettified = l.tokenStringHTMLPrettified
            // uppercased version
            self.tokenStringHTMLPrettifiedUppercased =
                l.tokenStringHTMLPrettifiedUppercased

            self.tokens = t                           // tokenised
            self.isWellFormed = rpn.getIsWellFormed() // e.g. `true`
            self.postfixText = rpn.getRpnString()     // e.g. `p p AND`
            self.tree = rpn.getRpnTree()!             // Obtain tree

            // Now, perhaps, we can compute the truth table if needed
            // using our semanticPermuter and the same RpnMake, which
            // will detect when it's been given a semantics version
            self.truthResult = rpn.truthResult
            self.truthTable = [String]()

            if withTruthTable == true && isWellFormed == true {

                makeTruthTable(forNTruthTableVariables)

            }

        } catch {
            self.error = "An \(error.localizedDescription) occured"

            self.infixText = ""
            self.postfixText = ""
            self.tokenStringHTML = ""
            self.tokenStringHTMLPrettified = ""
            self.tokenStringHTMLPrettifiedUppercased = ""
            self.isWellFormed = false
            self.truthResult = ""
            self.truthTable = [String]()
            let emptyToken = Token(tokenType: .poorlyFormed)
            self.tree = Tree(emptyToken)
        }
    }

    public static func == (lhs: Formula, rhs: Formula) -> Bool {
        return lhs.tree == rhs.tree
    }



    public func debug() {
        print("Infix string:   >\(self.infixText)<")
        print("Postfix string: >\(self.postfixText)<")
        print("Well formed?    >\(self.isWellFormed)<")
        print("Truth result    >\(self.truthResult)<")
        print("Truth table:    >\(self.truthTable)<")
        print("Graph of: \(self.infixText)\n\(self.tree.getTreeGraph())")
    }
}

extension Formula: Hashable {
    // To conform to Hashable
    // - Return a unique identifier
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

// MARK: Truth tables
extension Formula {

    mutating func makeTruthTable(_ forNTruthTableVariables: Int) {

        let myPermuter = SemanticPermuter(withTokens: self.tokens,
                                          forVariableCount: forNTruthTableVariables)
        let myPermutationsAsStrings = myPermuter.permutationAsStrings

        var myTokensAsStrings = [String]()

        for p in myPermutationsAsStrings {

            let myTruthResult = Formula(p).truthResult

            print(" P: \(infixText)")
            print(" P: \(p.description)")
            myTokensAsStrings.append(myTruthResult)

        }

        // e.g. ["true", "true", "false", "false"]
        truthTable = myTokensAsStrings

    }

    // As a shortcut, we can create a super formula from the LHS
    // and find the permutations where each are true by combining them:
    // e.g. p AND q, r -> s
    //      (p AND q) AND (r -> s)
    public static func makeSuperFormula(_ formulas: [Formula]) -> Formula{

        var superFormulaInfixTemp = ""
        for f in formulas {

            superFormulaInfixTemp = superFormulaInfixTemp + "(" + f.infixText + ") AND "

        }

        let superFormulaInfix = String(superFormulaInfixTemp.dropLast(5))

        let superFormula = Formula(superFormulaInfix)

        return superFormula

    }
}
