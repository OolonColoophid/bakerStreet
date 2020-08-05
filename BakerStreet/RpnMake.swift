//
//  RpnMake.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Foundation

/**
 Convert `infix` `Token` array to `postfix`/`Reverse Polish Notation`

 ## Example

 For instance, the infix `p AND p` should be rendered in postfix as `p p AND`.

 This is typically used following a `Lexer` instance, whose `getTokenised()`
 method provides an array of `Token` type. Typical use is:

 ```
 var rpn = try RpnMake(infixFormula: t) // t is [Token]
 try rpn.rpnEvaluate() // Evaluate RPN
 ```

 ## Evaluation
 Note that while `rpnEvaluate()` does the majority of the evaluation, evaluation
 may be pre-empted by `rpnToTokens()` if there are either of two obvious NOT
 operator syntactic errors.

 ## Useful Methods
 Get the resulting `String`, `Tree` or `Tokens` with
 - `getRpnString()`
 - `getRpnTree()`
 - `getRpnTokens()`

 To check whether the RPN is valid:
 - `getIsWellFormed()`.

 ## Tests
 Included in test `RpnMakeTests`
 */
public struct RpnMake {

    private var infixTokens = [Token]()

    private var rpnString: String
    private var rpnTree: Tree?
    private var rpnTokens = [Token]()
    private var rpnWellFormed: Bool

    public enum Error: Swift.Error {
        case invalidTokenArrayLength
        case invalidRpnTokensArrayLength
    }

    /**
     Initialises using a `Token` array that should be in `infix`.

     - Parameter infixFormula: The `infix` `Token` array
     - Throws: `invalidTokenArrayLength` if the `Token`
     array has zero items
     */
    public init (infixFormula: [Token]) throws {
        if infixFormula.count == 0 {
            throw RpnMake.Error.invalidTokenArrayLength } else {
            self.infixTokens = infixFormula
            self.rpnString = ""
            self.rpnWellFormed = false

            rpnToTokens()

            self.rpnString = self.rpnTokens.map(
                {token in token.description}).joined(separator: " ")
        }
    }

    /// Return a string representing the RPN of the formula
    public func getRpnString() -> String {
        return self.rpnString
    }

    /// Return a tree representing the RPN of the formula
    public func getRpnTree() -> Tree? {
        return self.rpnTree
    }

    /// Return a token array representing the RPN of the formula
    public func getRpnTokens() -> [Token] {
        return self.rpnTokens
    }

    /// Returns `true` if NOT operator is at the end of the infix statement - prima facie poorly formed
    public func notAtEndOfInfix() -> Bool {
        let l = self.infixTokens.last
        if l?.isOperator == true && l?.operatorToken?.operatorType == .lNot {
            return true
        } else {
            return false }
    }

    /// Returns `true` if NOT operator is left of an operator in the infix statement
    /// - prima facie poorly formed
    public func notLeftOfOperator() -> Bool {
        var i = 0

        var b = Token(tokenType: .empty)
        var c = Token(tokenType: .empty)

        // A two-character window moves through the Token
        // array; if the second character is an operator
        // and the first is a not, this can't be well
        // formed
        while infixTokens.count > 1 && i < infixTokens.count{
            b = infixTokens[i]
            if b.isOperator == true &&
                b.operatorToken!.operatorType != .lNot &&
                c.isOperator == true &&
                c.operatorToken!.operatorType == .lNot
            {
                return true
            }
            c = b
            i = i + 1
        }
        return false
    }

    /**
     Using an array of `Token` type in `infix`, sets `NPN` `Token` array

     We achieve this using the Shunting Yard Algorithm
     (Dijkstra): https://en.wikipedia.org/wiki/Shunting-yard_algorithm

     ## Data Types

     - Input is an array of type `Token`, stored in
     `self.infixTokens`
     - An intermediate stack is used to store operators,
     `tokenStack`
     - Output is the postfix array of tokens, `reversePolishNotation`

     ## Example

     1. Input infix: `p AND q`

     2. Push `p` to the output queue
     - (Whenever a number is read it is pushed to the output)

     3. Push `AND` onto the operator stack

     4. Push `q` to the output queue

     5. After reading the expression, pop the operators off
     the stack and add them to the output.

     6. In this case there is only one: `AND`.

     Output: p q +

     */
    private mutating func rpnToTokens() {
        var operatorStack = Stack<Token>()
        var output = [Token]()
        let input = self.infixTokens
        
        // Early abort (set Token array to a single `poorly
        // formed` token if):
        // 1. NOT operator appears at end of infix token array
        // 2. NOT operator is to the left of another operator
        if notAtEndOfInfix() == true || notLeftOfOperator() == true {
            self.rpnTokens = [Token(tokenType: .poorlyFormed)]
            return
        }

        for token in input {
            switch token.tokenType {

            case .poorlyFormed:
                break // skip; unused

            case .empty:
                break // skip; unused

            // An operand goes straight to the output
            case .operand(_):
                output.append(token)

            // An open bracket goes on the operator stack
            case .openBracket:
                operatorStack.push(token)

                // When we see a close bracket, we pop everything
                // from the operator stack (up to the matching open
            // bracket) and add these to the output
            case .closeBracket:
                while operatorStack.count > 0,
                    let tempToken = operatorStack.pop(),
                    !tempToken.isOpenBracket {
                        output.append(tempToken)
                }

            case .Operator(let operatorToken):
                
                for tempToken in operatorStack.makeIterator() {
                    if !tempToken.isOperator {
                        break
                    }
                    
                    if let tempOperatorToken = tempToken.operatorToken {
                        if operatorToken.associativity == .leftAssociative && operatorToken <= tempOperatorToken
                            || operatorToken.associativity == .rightAssociative && operatorToken < tempOperatorToken {
                            output.append(operatorStack.pop()!)
                        } else {
                            break
                        }
                    }
                }
                operatorStack.push(token)
                
            }
        }

        while operatorStack.count > 0 {
            output.append(operatorStack.pop()!)
        }

        self.rpnTokens = output
    }


    /**
     Starts the evaluation of the RPN formula.

     - Throws: `invalidRpnTokensArrayLength` if the
     struct's array of RPN tokens (held in `rpnTokens`)
     is zero length. This will probably happen if
     `rpnEvaluate()` is called before `rpnToTokens()`

     */
    public mutating func rpnEvaluate () throws {
        if self.rpnTokens.count == 0 {
            throw RpnMake.Error.invalidRpnTokensArrayLength

        } else {

            var myRpnEvaluator = RpnEvaluater(self.rpnTokens)

            myRpnEvaluator.evaluateFormula()

            self.rpnWellFormed = myRpnEvaluator.isWellFormed()

            //If tree not well formed, return tree with PF
            if self.rpnWellFormed == true {

                self.rpnTree = myRpnEvaluator.getTopmostTree() }

            else {

                let poorlyFormedToken = Token(tokenType: .poorlyFormed)
                let poorlyFormedTree = Tree(poorlyFormedToken)
                self.rpnTree = poorlyFormedTree
            }

        }
    }

    /// Returns `true` if the formula is well formed in its entirety
    public func getIsWellFormed() -> Bool {
        return self.rpnWellFormed
    }

    /// We evaluate our Reverse Polish Notation
    struct RpnEvaluater {

        var tokenStack = Stack<Token>()
        var reversePolishNotation = [Token]()
        var treeStack = Stack<Tree>()

        /// Initialises using an array of `Token` type representing a formula
        /// in RPN
        public init(_ formula: [Token]) {
            self.reversePolishNotation = formula
            evaluateFormula()
        }

        private func getTopmostElement() -> Token? {
            return self.tokenStack.top
        }

        public func getTopmostTree() -> Tree? {
            return self.treeStack.top
        }

        /// Returns `true` if the current phrase (a sub unit of the
        /// whole formula) is well formed in terms of`arity`
        private func evaluatePhrase(operat: OperatorToken, operands: [Token]) ->
            Token {

                for operand in operands {
                    if operand.isPoorlyFormed == true {
                        return operand
                    }
                }

                if phraseIsWellFormed(operat: operat, operands: operands) == true {
                    // a variable representing a well formed use of a connective
                    return Token(operand: "WF")
                } else {
                    return Token(tokenType: .poorlyFormed)
                }
        }

        /// Checks well-formedness; cf. `evaluatePhrase()`
        private func phraseIsWellFormed(
            operat: OperatorToken,
            operands: [Token])
            -> Bool {

                switch operat.arity {
                case 2:
                    if operands.count != 2 { return false }
                    if operands[0].isOperand && operands[1].isOperand { return true }

                default:
                    if operands.count != 1 { return false }
                    if operands[0].isOperand { return true }

                }

                return false
        }

        /// Evaluates a RPN `Token` array and builds a tree representing it
        public mutating func evaluateFormula() {

            var result: Token

            // Base condition
            if self.reversePolishNotation.count == 0 {
                return
            }

            // Push leftmost item of formula onto stack
            self.tokenStack.push(self.reversePolishNotation[0])

            // Do we have an operator on the top of the stack?
            // If so, evaluate stack and push result
            let currentToken = getTopmostElement()

            if currentToken!.isOperand == true {
                treeStack.push(Tree(currentToken!))
            }

            if currentToken!.isOperator == true {
                let operat = self.tokenStack.pop()?.operatorToken


                var i = 0
                var operands = [Token]()
                while tokenStack.count != 0 && i <= operat!.arity-1 {
                    operands.append(self.tokenStack.pop()!)
                    i = i + 1
                }

                result = evaluatePhrase(operat: operat!, operands: operands)
                tokenStack.push(result)

                i = 0
                let newTree = Tree(currentToken!)
                var children = [Tree]()
                while treeStack.count != 0 && i <= operat!.arity-1 {

                    children.append(treeStack.pop()!)
                    i = i + 1
                }

                newTree.addMany(children)

                treeStack.push(newTree)

            }

            // Remove left item from formula
            self.reversePolishNotation.remove(at: 0)

            // Begin recursion

            evaluateFormula()

            return
        }

        /// Returns `true` if the formula successfully evaluated
        public func isWellFormed() -> Bool{

            // If the stack has two or more items after
            // we finish, there is no single root node, therefore
            // the structure is not well formed
            if self.tokenStack.count > 1 {
                return false
            }

            // We might be left with one stack token
            // that is poorly formed
            if self.tokenStack.top?.isPoorlyFormed == false {

                return true

            } else {
                return false
            }

        }

    }

}
