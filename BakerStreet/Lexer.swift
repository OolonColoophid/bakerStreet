//
//  Lexer.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Foundation

/**

 Tokenise - i.e. assign lexemes - given a formula string like `p AND p`

 The Lexer should be the initial step in taking the string of a formula
 to parse it. This is a typically a two step process, for instance:

 ```
 var infixText = "p AND p"
 var l = try Lexer(text: infixText) // Initialise
 let t = l.getTokenised()           // Get array of type Token
 ```

 In the above example, we'll give the array `t` to an instance of
 `RpnMake`, e.g. `var rpn = try RpnMake(infixFormula: t)`

 ## Tests
 Included in test `PrecedenceTests`

 */
public struct Lexer {

    /// The formula string as an array of words
    private let splitText: [Substring]

    /// The formula as an array of `Token` types
    private var textTokenised = [Token]()

    /// Is false, all operands are output in lower case
    private var respectCase: Bool = false

    /// The formula as a string of Tokens
    /// i.e. reconstructed from Tokens
    private var tokenString: String

    /// The formula in HTML, e.g. "<em>p</em> AND <em>q</em>"
    public var tokenStringHTML: String

    /// The formula in HTML with glyphs, e.g. "<em>p</em> ∧ <em>q</em>"
    public var tokenStringHTMLWithGlyphs: String {

        var s = tokenStringHTML

        let operators = OperatorType.allCases

        for o in operators {
            s = s.replacingOccurrences(of: o.description, with: o.htmlEntity)
        }

        return s
    }

    /// The formula in Latex
    public var tokenStringLatex: String {

        var s = tokenString

        let operators = OperatorType.allCases

        for o in operators {
            s = s.replacingOccurrences(of: o.description, with: " " + o.latexEntity + " ")
        }

        // Latex commands to start and stop maths environment
        s = "\\(" + s + "\\)"

        return s

    }

    public enum Error: Swift.Error {
        case invalidStringLength
    }

    /**
     Initializes with a string containing the formula, e.g. `p AND p`

     This also does some tidying of the string
     - Throws: `invalidStringLength` if the string is zero length
     */
    public init(text: String, respectCase: Bool = false) throws {

        if text.count == 0 {
            throw Lexer.Error.invalidStringLength
        } else {

            self.respectCase = respectCase

            var s = text

            // Pad brackets to ensure they are tokenised
            s = s.replacingOccurrences(of: ")", with: " ) ")
            s = s.replacingOccurrences(of: "(", with: " ( ")

            // Pad NOT to ensure it is tokenised
            let notPlainText = OperatorType.lNot.description
            s = s.replacingOccurrences(of: notPlainText,
                                       with: " " + notPlainText + " ")

            // Pad IF and IFF
            // We treat this differently because padding
            let iffPlainText = OperatorType.lIff.description
            s = s.replacingOccurrences(of: iffPlainText,
                                       with: " " + iffPlainText + " ")

            let ifPlainText = OperatorType.lIf.description
            s = s.replacingOccurrences(of: ifPlainText,
                                       with: " " + ifPlainText + " ")

            // A correction in case padding an IF caused us to
            // pad a IFF (-> being a substring of <-->
            // (This is not an elegant solution - it will break if
            // the string for IF or IFF are changed, so we are affecting
            // customisation somewhat)
            s = s.replacingOccurrences(of: "< ->",
                                       with: iffPlainText)

            // Trim any trailing or preceding spaces
            s = s.trim

            self.splitText = s.split(separator: " ")
            self.tokenString = ""
            self.tokenStringHTML = ""
        }

    }

    /// Returns string `splitText`, i.e. the formula as an array of words
    public func getSplitText() -> String {
        return String(self.splitText.description)
    }

    /// Returns an array of `Token` type based on the formula string
    public mutating func getTokenised() -> [Token] {
        tokenise()
        return self.textTokenised
    }

    /// Returns `self.tokenString`, a string built from the `Token` types
    public mutating func getTokenString() -> String {
        tidyTokenString()
        return self.tokenString
    }

    /// Adds the plain text of a `Token` to `self.tokenString`
    public mutating func addToTokenString(_ token: String) {
        self.tokenString.append(" " + token)
    }

    /**
     Corrects spacing in`self.tokenString`

     When built by `addToTokenString`, `self.tokenString`
     tends to take this form:

     - `<SPACE>Token<SPACE>Token`

     This can lead to: `p ( AND` when we want `p (AND`
     */
    public mutating func tidyTokenString() {

        let s = self.tokenString

        self.tokenString = s.tidyFormula
    }

    /**
     Scans the split formula string

     When a tokenisable string is seen, add to array of tokens
     `textTokenised` as well as our string representing the
     tokenised formula, `tokenString`
     */
    private mutating func tokenise(){
        var textTokenised = BuildTokenisedText()

        // Retrieve the strings representing operators, e.g. "AND", "~"
        let andPlainText = OperatorType.lAnd.description
        let orPlainText  = OperatorType.lOr.description
        let notPlainText = OperatorType.lNot.description
        let ifPlainText  = OperatorType.lIf.description
        let iffPlainText = OperatorType.lIff.description

        for element in self.splitText {

            let elementStr = String(element).uppercased()

            switch elementStr {
            case andPlainText:
                // Add to Token array
                textTokenised.addOperator(.lAnd)
                // Add to string of Tokens
                addToTokenString(andPlainText)
                // Add to HTML string of Tokens
                tokenStringHTML += " " + elementStr + " "

            case orPlainText:
                textTokenised.addOperator(.lOr)
                addToTokenString(orPlainText)
                tokenStringHTML += " " + elementStr + " "

            case notPlainText:
                textTokenised.addOperator(.lNot)
                addToTokenString(notPlainText)
                tokenStringHTML += " " + elementStr

            case ifPlainText:
                textTokenised.addOperator(.lIf)
                addToTokenString(ifPlainText)
                tokenStringHTML += " " + elementStr + " "

            case iffPlainText:
                textTokenised.addOperator(.lIff)
                addToTokenString(iffPlainText)
                tokenStringHTML += " " + elementStr + " "

            case "(" :
                textTokenised.addOpenBracket()
                addToTokenString("(")
                tokenStringHTML += elementStr

            case ")" :
                textTokenised.addCloseBracket()
                addToTokenString(")")
                tokenStringHTML += elementStr

            default:
                if isOperand(elementStr.lowercased()) {

                    var e = ""

                    if respectCase == true {
                        e = elementStr
                    } else {
                        e = elementStr.lowercased()
                    }

                    textTokenised.addOperand(e)
                    addToTokenString(e)
                    tokenStringHTML += e.em

                } else {

                    break

                }

            }
        }

        self.textTokenised = textTokenised.build()
    }

    /**
     Tests if a string could be an operand.

     - Parameter operand: Operand as string, e.g. `p`
     - Returns: `True` if the string is an operand

     Any potential operand string must match the
     regex `pattern` in type `Operand`
     */
    private func isOperand(_ operand: String) -> Bool {

        let op = OperandToken()

        // Test for single character, e.g. "p"
        if let _ = operand.regex(op.pattern) {

            return true

        }

        let specialCases = op.special

        // Test for special case, e.g. "true"

        for s in specialCases {
            if operand == s.lowercased() {
                return true
            }
        }

        return false

    }

    /// A helper struct for putting together an array of `Token` type
    private struct BuildTokenisedText {

        private var tokenisedText = [Token]()

        public mutating func addOperator(_ operatorType: OperatorType) {
                tokenisedText.append(Token(operatorType: operatorType))
        }

        public mutating func addOperand(_ operand: String) {
                tokenisedText.append(Token(operand: operand))
        }

        public mutating func addOpenBracket() {
            tokenisedText.append(Token(tokenType: .openBracket))
        }

        public mutating func addCloseBracket() {
            tokenisedText.append(Token(tokenType: .closeBracket))
        }

        public func build() -> [Token] {

            return tokenisedText
        }
    }
}
