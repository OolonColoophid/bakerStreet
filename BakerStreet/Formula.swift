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

    public let identifier =               UUID() // i.e. 4 random bytes
    public var infixText:                 String // e.g. `p AND p`
    public var tokenStringHTML:           String // e.g. `<em>p</em>`
    public var tokenStringHTMLPrettified: String // e.g. `<em>p</em> ∧ <em>q</em>`
    public var tokenStringHTMLPrettifiedUppercased: String
    public let postfixText:               String // e.g. `p p AND`
    public var isWellFormed:              Bool   // e.g. `true`
    public let tree:                      Tree   // `Tree` representation
    public var truthResult:               String // e.g. "true", empty if
                                                 //   not well formed
    public var truthTable:                String // e.g. "true, false, true"

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
                 withTruthTable: Bool = false) {

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
            self.truthTable = ""

            if withTruthTable == true {

                let myPermuter = SemanticPermuter(withTokens: t)
                let myPermutationsAsStrings = myPermuter.permutationAsStrings

                print(myPermutationsAsStrings)
                for p in myPermutationsAsStrings {

                    let myTruthResult = Formula(p).truthResult
                    truthTable = truthTable + myTruthResult + " "

                }

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
            self.truthTable = ""
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
