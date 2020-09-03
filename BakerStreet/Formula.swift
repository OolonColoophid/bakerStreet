//
//  Formula.swift
//  Baker Street
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Foundation

// Takes a string like “p AND q” and returns a Formula type.
public struct Formula: Equatable {

    public let identifier =               UUID()   // i.e. 4 random bytes
    public var infixText:                 String   // e.g. `p AND p`
    public var tokenStringHTML:           String   // e.g. `<em>p</em>`
    public var tokenStringHTMLWithGlyphs: String // e.g. `<em>p</em> ∧ <em>q</em>`
    public var tokenStringLatex:          String // e.g. \(p \Rightarrow q\)
    public let postfixText:               String   // e.g. `p p AND`
    public var isWellFormed:              Bool     // e.g. `true`
    public let tree:                      Tree     // `Tree` representation
    public var truthResult:               String   // e.g. "true", empty if
                                                   //   not well formed

    public var truthTable:                [String] // e.g. ["true", "false"]

    // True if all values of truthTable are true
    public var areTruthValuesAllTrue: Bool {

        for r in truthTable {
            if r.description == "false" {
                return false
            }
        }

        return true
    }

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
                 respectCase: Bool = false) {

        do {

            // Initialise
            var l = try Lexer(text: infixText, respectCase: respectCase)
            let t = l.getTokenised()           // Get array of Token

            var rpn = try RpnMake(infixFormula: t)

            try rpn.rpnEvaluate() // Evaluate RPN

            self.infixText = l.getTokenString()       // e.g. `p AND p`

            // e.g. `<em>p</em>`
            tokenStringHTML = l.tokenStringHTML

            // e.g. `<em>p</em> ∧ <em>q</em>`
            tokenStringHTMLWithGlyphs = l.tokenStringHTMLWithGlyphs

            // e.g. `\(p \Rightarrow q\)`
            tokenStringLatex = l.tokenStringLatex

            tokens = t                           // tokenised
            isWellFormed = rpn.getIsWellFormed() // e.g. `true`
            postfixText = rpn.getRpnString()     // e.g. `p p AND`
            tree = rpn.getRpnTree()!             // Obtain tree

            truthResult = rpn.truthResult
            truthTable = [String]()

            if withTruthTable == true && isWellFormed == true {

                makeTruthTable()

            }

        } catch {
            self.error = "An \(error.localizedDescription) occured"

            self.infixText = ""
            postfixText = ""
            isWellFormed = false
            tokenStringHTML = ""
            tokenStringHTMLWithGlyphs = ""
            tokenStringLatex = ""
            truthResult = ""
            truthTable = [String]()
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

    mutating func makeTruthTable() {

        let myPermuter = SemanticPermuter(withTokens: self.tokens)
        let myPermutationsAsStrings = myPermuter.permutationAsStrings

        var myTokensAsStrings = [String]()

        for p in myPermutationsAsStrings {

            let myTruthResult = Formula(p).truthResult

              myTokensAsStrings.append(myTruthResult)

        }

        // e.g. ["true", "true", "false", "false"]
        truthTable = myTokensAsStrings

    }

    // As a shortcut, we can create a super formula from the LHS
    // and find the permutations where each are true by combining them:
    // e.g. p AND q, r -> s
    //      (p AND q) AND (r -> s)
    public static func makeSuperFormula(_ formulae: [Formula]) -> Formula{

        var superFormulaInfixTemp = ""
        for f in formulae {

            superFormulaInfixTemp = superFormulaInfixTemp + "(" + f.infixText + ") AND "

        }

        let superFormulaInfix = String(superFormulaInfixTemp.dropLast(5))

        let superFormula = Formula(superFormulaInfix)

        return superFormula

    }
}
