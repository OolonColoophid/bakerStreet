//
//  ProofController.swift
//  Baker Street
//
//  Created by Ian Hocking on 22/06/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Cocoa
import Foundation

// Creates a Proof struct and manages its style.
public class ProofController {

    var proof: Proof

    public var lineViewTextStyled: NSMutableAttributedString {
        get {
            return makeLineViewTextStyled()
        }
    }


    public var mainViewTextStyled: NSMutableAttributedString {
        get {
            return makeMainViewTextStyled()
        }
    }

    public var adviceViewTextStyled: NSMutableAttributedString {
        get {
            return makeAdviceViewTextStyled()
        }
    }

    // These take text and style it
    private var mySyntaxHighlighter: SyntaxStyler = SyntaxStyler()
    private var myAdviceStyler: AdviceStyler = AdviceStyler()

    // Receive the text from the view where the user
    // types. This should be the text of the proof. Also
    // receive a delegate that will be informed of things
    // (principally, that background export of PDf etc. is complete)
    init(proofText: String = "",
         withDelegate delegate: BKProofDelegate) {

        proof = Proof(proofText, withDelegate: delegate)

    }

    // Receive the text from the view where the user
    // types. This should be the text of the proof.
    init(proofText: String = "") {

        proof = Proof(proofText)

    }



    func getLineFromUUID(_ uuid: UUID) -> BKLine {

        let line = proof.getLineNumberFromIdentifier(uuid)
        return proof.getLineFromNumber(line)

    }

}

// MARK: Style Line View

extension ProofController {

    public func makeLineViewTextStyled() -> NSMutableAttributedString {

        var lt = ""
        var lineViewText = ""
        var i = 0

        guard proof.scope.count != 0  else {

            return NSMutableAttributedString(string: lineViewText)

        }

        for _ in proof.scope {

            var successGlyphs = ""

            if let successes = proof.getSuccessForLine(i) {
                for s in successes {
                    successGlyphs = successGlyphs +
                        s.symbol
                }

            }

            lt = lt + successGlyphs + " " + String(i) + "\n"

            i = i + 1
        }

        // Trim trailing newline
        lineViewText = String(lt.dropLast())

        return mySyntaxHighlighter.style(lineViewText,
                                         with: OverallStyle.lineText.attributes)

    }

}

// MARK: Style Main Text View

extension ProofController {

    private func makeMainViewTextStyled() -> NSMutableAttributedString {

        guard proof.scope.count != 0 else {

            return NSMutableAttributedString()

        }

        let mainText = NSMutableAttributedString()

        for l in proof.scope {

            switch l {
                case is Justified:
                    let j = l as! Justified

                    // Add syntax highlighting to the formula
                    let paintedFormula = mySyntaxHighlighter.getPaintedFormula(j.formula)

                    mainText.append(addMainTextViewStyled(withScopeLevel: j.scopeLevel,
                                                          paintedFormula,
                                                          endOfLine: false))

                    guard j.justification != .empty else {

                        mainText.append(mainViewNewLine())

                        break

                    }

                    // Give me the linear string length of the antecedents
                    // e.g. "1, 2, 3" -> 7
                    var antecedentsSize: Int {

                        guard j.antecedents.count > 0 else { return 0 }

                        if j.antecedents.count == 1 {
                            return String(j.antecedents[0]).count
                        }

                        var aSize = 0
                        for a in j.antecedents {
                            aSize = aSize + String(a).count
                        }

                        // Each element will be separated by ", "
                        // apart from the last
                        aSize = aSize + ((j.antecedents.count - 1) * 2)

                        return aSize

                    }

                    let paintedJustificationAndAntecedents =
                        mySyntaxHighlighter.getPaintedJustificationAndAntecedents(
                            j.justification,
                            j.antecedents,
                            0)

                    mainText.append(
                        addMainTextViewStyled(
                            paintedJustificationAndAntecedents,
                            endOfLine: false))

                    mainText.append(mainViewNewLine())

                case is Theorem:

                    let t = l as! Theorem

                    let paintedTheorem = mySyntaxHighlighter.getPaintedTheorem(
                        t.getLhsFormulae(),
                        t.getRhsFormula())

                    mainText.append(
                        addMainTextViewStyled(
                            withScopeLevel: t.scopeLevel,
                            paintedTheorem,
                            endOfLine: true))

                case is Comment:

                    let c = l as! Comment

                    let cStyled = mySyntaxHighlighter.style(
                        c.getWindowText(),
                        with: OverallStyle.mainTextComment.attributes)

                    mainText.append(
                        addMainTextViewStyled(
                            withScopeLevel: c.scopeLevel,
                            cStyled, endOfLine: true))

                default: // i.e. LineType is Inactive

                    let i = l as! Inactive

                    let iStyled = mySyntaxHighlighter.style(
                        i.getWindowText(),
                        with: OverallStyle.mainTextInactive.attributes)

                    mainText.append(
                        addMainTextViewStyled(withScopeLevel: i.scopeLevel,
                                              iStyled,
                                              endOfLine: true))

            }

        }

        return mainText

    }

    public func addMainTextViewStyled(
        withScopeLevel scope: Int = 0,
        _ text: NSMutableAttributedString,
        endOfLine: Bool = true)
        -> NSMutableAttributedString {

            let indented = getIndent(scope: scope)

            indented.append(text)

            if endOfLine == true {
                indented.append(mainViewNewLine())
            }

            return indented

    }

    private func mainViewNewLine() -> NSMutableAttributedString {

        return   mySyntaxHighlighter.style(
            "\n",
            with: OverallStyle.mainText.attributes)

    }

}

// MARK: Style Advice View

extension ProofController {

    public func makeAdviceViewTextStyled() -> NSMutableAttributedString {

        guard proof.advice.count > 0 else {
            // No advice
            return NSMutableAttributedString()
        }

        let lines = proof.scope
        let viewAdviceText = NSMutableAttributedString()

        var i = 0

        for l in lines {

            if proof.isAdviceForLine(l.identifier, ofType: .warning) == true {

                viewAdviceText.append(
                    getAdviceStringForLineStyled(withLineUUID: l.identifier,
                                                 suppressGlyphs: true))

            }

            viewAdviceText.append(
                mySyntaxHighlighter.style(
                    "\n", with: OverallStyle.adviceText.attributes))

            i = i + 1
        }

        return viewAdviceText

    }



    private func getAdviceStringForLineStyled(withLineUUID uuid: UUID,
                                              suppressGlyphs: Bool = false)
        -> NSMutableAttributedString {

            guard proof.advice.count != 0 else {
                // No advice
                return NSMutableAttributedString()
            }

            let adviceString = NSMutableAttributedString()

            let advice = proof.getAdviceForLineUUID(withLineUUID: uuid)

            guard advice != nil else {
                return adviceString
            }

            // Set symbol
            if suppressGlyphs == false {
                adviceString.append(myAdviceStyler.style(
                    advice!.symbol + " ",
                    with: OverallStyle.adviceText.attributes))
            }

            if advice!.type != .proofSuccess {
                // Set line number
                adviceString.append(myAdviceStyler.style(String(advice!.lineAsInt) + "  ",
                                                         with: OverallStyle.adviceText.attributes)) }

            // Set text
            adviceString.append(myAdviceStyler.style(
                advice!.shortDescription + " ",
                with: OverallStyle.adviceText.attributes))

            // Set hyperlink for popover
            if advice!.longDescription.isEmpty == false {
                adviceString.append (
                    myAdviceStyler.addHyperlink(
                        forAdviceUUID: advice!.id,
                        advice!.hyper)
                )

            }

            return adviceString

    }


}

// MARK: Indentation

extension ProofController {

    private func getIndent(scope: Int) -> NSMutableAttributedString {

        let indent = NSMutableAttributedString()
        var i = 0
        var scopeSymbol = true

        while i < scope {

            scopeSymbol.toggle()

            if scopeSymbol == true && i != 0 {
                indent.append(
                    mySyntaxHighlighter.style(" ",
                                              with:
                        OverallStyle.mainTextAssertionScopeBar.attributes))
            }

            if scopeSymbol == false && i != 0 {
                indent.append(
                    mySyntaxHighlighter.style(" ",
                                              with:
                        OverallStyle.mainTextAssertionScopeBar.attributes))
            }

            // Special case - no symbol for proof theorem
            if i == 0 {

                indent.append(
                    mySyntaxHighlighter.style(" ",
                                              with:
                        OverallStyle.mainText.attributes))
            }

            indent.append(mySyntaxHighlighter.style("   ",
                                                    with:
                OverallStyle.mainText.attributes))

            i = i + 1
        }

        return indent
    }

    private func getLengthLongestJustifiedFormula() -> Int {

        if proof.scope.count == 0 {
            return 0
        }

        var maxLength = 0

        for l in proof.scope {

            if l is Justified {

                let j = l as! Justified
                let myLength = j.formula.infixText.count

                if myLength > maxLength {
                    maxLength = myLength
                }


            }
        }

        return maxLength

    }

}



