//
//  SemanticPermuter.swift
//  Baker Street
//
//  Created by Ian Hocking on 09/08/2020.
//  Copyright © 2020 Ian. MIT Licence.
//

import Foundation

struct SemanticPermuter {

    private var permutations = [[Token]]()

    public var permutationAsStrings: [String] {

        var allPermutations = [String]()

        for p in permutations { // for permutation

            var thisPermutation = ""

            for t in p { // for token in permutation

                thisPermutation = thisPermutation + t.description + " "

            }

            allPermutations.append(thisPermutation)

        }

        return allPermutations
    }

    // Get semantic permutations of a formula (as a array of tokens)
    // that can be used to create a truth table
    // Thus "p AND q" will have 4 permutations:
    //
    //  p   q   AND
    //  -----------
    //  T   T   T (permutation 1)
    //  T   F   F ..
    //  F   T   F ..
    //  F   F   F (permutation n)
    //

    init (withTokens tokens: [Token]) {
        // -> [[Token]] {
        // Algorithm:
        // 2. Create two sets of new permutations, representing
        //    top and bottom half of the set e.g. (for "p and q")
        //    "p and q" <- top half
        //    "p and q" <- bot half
        //    (If this set has one item, create its first permutation now)
        // 3. Go through each permutation, alternatively replacing
        //    target variable with T, then F
        // 5. Sub result for replacing "p":
        //    "T and q"
        //    "F and q"
        // 6. Go to 2, stop when no longer any variable operands
        // 7. Would continue like this:
        //    "T and T"
        //    "T and F"
        //    "F and T"
        //    "F and F"

        // The top half of our set is just the tokens as they
        // stand, e.g. ["p", "AND", "q"]
        var top = [tokens]
        // The bottom half is empty for now; we'll fill it using
        // doubleUp()
        var bot = [[Token]]()

        // Iterate over our operands:
        //  Get operands
        let operandsAll = tokens.filter { $0.isOperand == true }

        // Reduce to only unique operands
        let operands = operandsAll.uniques.sorted()

        for o in operands {

            // Create our new permutations (i.e. rows in the truth
            // table) by expanding the current permutations
            addPermutations(top: &top, bot: &bot)

            // Now, for our current operand (still an operand
            // in the truth table) replace instances of it with semantics
            addSemantics(forOperand: o, top: &top, bot: &bot)

        }

        // Top and bottom are now complete. Let's combine them
        var allPermutations = top
        allPermutations.append(contentsOf: bot)

        self.permutations = allPermutations

    }

    // Apply true/false values to top and bottom sets of permutations
    func addSemantics(forOperand operand: Token,
                      top: inout [[Token]],
                      bot: inout [[Token]]) {

        findAndReplaceOpWithSemantics(forOp: operand, permutations: &top,
                                       isFirstTrue: true)

        findAndReplaceOpWithSemantics(forOp: operand,
                                       permutations: &bot,
                                       isFirstTrue: false)

    }

    // Iterature through a set of permutations and alternatively
    // replace target operand with true/false semantics
    func findAndReplaceOpWithSemantics(forOp operand: Token,
                                        permutations: inout [[Token]],
                                        isFirstTrue: Bool) {
        
        // We only want variables. If the operand is false or
        // true, no replacement is necessary
        guard (operand.description != "false") && (operand.description != "true") else {
            return
        }
        
        // Our true/false state
        var semTrue = isFirstTrue
        var semanticValue = ""

        // For each permutation (using .enurated() gives us pIndex, the index)
        for (pIndex, p) in permutations.enumerated() { // Where p is a permutation

            // For reach token
            for (tIndex, t) in p.enumerated() { // Where t is a token

                // Is this the token we're looking for?
                if t.description == operand.description {

                    // Set the semantics
                    if semTrue == true {
                        semanticValue = "true"
                    } else {
                        semanticValue = "false"
                    }

                    // Apply the semantics
                    permutations[pIndex][tIndex] = Token(tokenType: .operand(semanticValue))

                }

            }

            semTrue.toggle()

        }

    }

    // Add permutations to the current sets
    func addPermutations(top: inout [[Token]],
                         bot: inout [[Token]]) {

        guard !(bot.isEmpty) else {
            bot.append(contentsOf: top)
            return
        }

        duplicateEachElement(permutations: &top)

        duplicateEachElement(permutations: &bot)

    }

    // For each element, double it up
    func duplicateEachElement(permutations: inout [[Token]]) {
        var newPermutations = [[Token]]()

        for p in permutations {
            newPermutations.append(p)
            newPermutations.append(p)
        }

        permutations = newPermutations

    }

}
