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
    public var tokenStringHTMLWithGlyphs: String // e.g. `<em>p</em> ∧ <em>q</em>`
    public var tokenStringLatex:          String // e.g. \(p \Rightarrow q\)
    public let postfixText:               String // e.g. `p p AND`
    public let isWellFormed:              Bool   // e.g. `true`
    public let tree:                      Tree   // `Tree` representation
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
    public init (_ infixText: String) {

        do {
            var l = try Lexer(text: infixText) // Initialise
            let t = l.getTokenised()           // Get array of Token

            // Convert to RPN
            var rpn = try RpnMake(infixFormula: t)
            try rpn.rpnEvaluate() // Evaluate RPN

            self.infixText = l.getTokenString()       // e.g. `p AND p`

            // e.g. `<em>p</em>`
            tokenStringHTML = l.tokenStringHTML

            // e.g. `<em>p</em> ∧ <em>q</em>`
            tokenStringHTMLWithGlyphs = l.tokenStringHTMLPrettified

            // e.g. `\(p \Rightarrow q\)`
            tokenStringLatex = l.tokenStringLatex

            tokens = t                           // tokenised
            postfixText = rpn.getRpnString()     // e.g. `p p AND`
            isWellFormed = rpn.getIsWellFormed() // e.g. `true`
            tree = rpn.getRpnTree()!             // Obtain tree

        } catch {
            self.error = "An \(error.localizedDescription) occured"

            self.infixText = ""
            postfixText = ""
            tokenStringHTML = ""
            tokenStringHTMLWithGlyphs = ""
            tokenStringLatex = ""
            isWellFormed = false
            let emptyToken = Token(tokenType: .poorlyFormed)
            tree = Tree(emptyToken)
        }
    }

    public static func == (lhs: Formula, rhs: Formula) -> Bool {
        return lhs.tree == rhs.tree
    }

    public func debug() {
        print("Infix string:   >\(self.infixText)<")
        print("Postfix string: >\(self.postfixText)<")
        print("Well formed?    >\(self.isWellFormed)<")
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
