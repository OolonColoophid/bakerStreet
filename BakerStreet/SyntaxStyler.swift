//
//  SyntaxHighlighter.swift
//  Baker Street
//
//  Created by Ian Hocking on 29/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Foundation

public struct SyntaxStyler: Styling {


    public func style(_ text: String,
                      with attributes: [NSAttributedString.Key : Any])
    -> NSMutableAttributedString {
        
        let s = Styler(text, with: attributes)
        return s.getFormatted()
    }


    public func getPaintedFormula(_ formula: Formula)
        -> NSMutableAttributedString {

            let tokens = formula.tokens
            let pFormula = NSMutableAttributedString()
            let operandStyle = OverallStyle.mainTextAssertionOperand.attributes
            let operatorStyle = OverallStyle.mainTextAssertionOperator.attributes
            let bracketStyle = OverallStyle.mainTextAssertionBracket.attributes

            var i = 0
            var lastElement = Token(tokenType: .empty)
            var spacer = ""
            for token in tokens {

                i = i + 1

                if token.isOperand {

                    if lastElement.isOpenBracket || lastElement.isNegation {
                        spacer = ""
                    } else {
                        spacer = " "
                    }

                    if i == 1 { spacer = "" }

                      pFormula.append(style(
                        spacer + token.description,
                        with: operandStyle))

                }

                if token.isOperator {

                    if lastElement.isOpenBracket || lastElement.isNegation {
                        spacer = ""
                    } else {
                        spacer = " "
                    }

                    if i == 1 { spacer = "" }

                    pFormula.append(style(
                        spacer + token.description,
                        with: operatorStyle))

                }

                if token.isOpenBracket {

                    if lastElement.isNegation {
                        spacer = ""
                    } else {
                        spacer = " "
                    }

                    if i == 1 { spacer = "" }

                    pFormula.append(
                        style(spacer + token.description,
                              with: bracketStyle))

                }

                if token.isCloseBracket {

                    pFormula.append(
                        style(token.description,
                              with: bracketStyle))

                }

                lastElement = token
                spacer = ""
            }

            return pFormula
    }

    public func getPaintedJustificationAndAntecedents (
        _ justification: Justification,
        _ antecedents: [Int],
        _ spaceSize: Int)
        -> NSMutableAttributedString {

            let justifiedLine = NSMutableAttributedString()
            let punctuationStyle = OverallStyle.mainTextAssertionPunctuation.attributes
            let textStyle = OverallStyle.mainTextAssertionJustificationText.attributes
            let numberStyle = OverallStyle.mainTextAssertionJustificationNumber.attributes

            let spacer = String(repeating: " ", count: spaceSize)

            justifiedLine.append(style(spacer, with: punctuationStyle))

            justifiedLine.append(style(" : ",
                                       with: punctuationStyle))
            justifiedLine.append(style(justification.description + " ", with: textStyle))


            var aStyled = [NSMutableAttributedString()]
            var aString = ""

            for a in antecedents {

                aString = String(a)

                aStyled.append(
                    style(aString, with: numberStyle))
            }

            // The constructor introduced a blank element
            // at the beginning of the array; remove it
            aStyled.remove(at: 0)

            justifiedLine.append(getPaintedList(
                hasParenthesis: true,
                withElements: aStyled,
                withPunctuationStyle: punctuationStyle))

            return justifiedLine

    }

    public func getPaintedTheorem(_ lhsFormulae: [Formula],
                                   _ rhsFormula: Formula)
        -> NSMutableAttributedString {

            let punctuationStyle = OverallStyle.mainTextAssertionPunctuation.attributes
            let textStyle = OverallStyle.mainTextAssertionTheoremText.attributes
            let turnStileStyle = OverallStyle.mainTextAssertionTurnstile.attributes

            let theoremLine = NSMutableAttributedString()

            if lhsFormulae.count > 0 {

                var fStyled = [NSMutableAttributedString()]

                for f in lhsFormulae {
                    let fPainted = getPaintedFormula(f)
                    fStyled.append(fPainted)
                }

                // The constructor introduced a blank element
                // at the beginning of the array; remove it
                fStyled.remove(at: 0)

                theoremLine.append(getPaintedList(
                    hasParenthesis: false,
                    withElements: fStyled,
                    withPunctuationStyle: punctuationStyle))

                theoremLine.append(style(" ", with: textStyle))
            }

            theoremLine.append(style(
                MetaType.turnStile.description + " ",
                with: turnStileStyle))

            theoremLine.append(getPaintedFormula(rhsFormula))

            return theoremLine

    }

    
    private func getPaintedList(

        hasParenthesis parenthesis:
        Bool = false,
        withParenthesisStyle parenthesisStyle:
        [NSAttributedString.Key : Any] = OverallStyle.mainTextAssertionBracket.attributes,
        withElements elements:
        [NSMutableAttributedString],
        withPunctuationStyle punctuationStyle:
        [NSAttributedString.Key : Any])

        -> NSMutableAttributedString {

            let myList = NSMutableAttributedString()

            if parenthesis == true {
                myList.append(style("(", with: parenthesisStyle))
            }

            var i = 0

            for e in elements {
                i = i + 1

                myList.append(e)
                if i < elements.count {
                    myList.append(style(", ", with: punctuationStyle))
                }
            }


            if parenthesis == true {
                myList.append(style(")", with: parenthesisStyle))
            }

            return myList

    }

}
