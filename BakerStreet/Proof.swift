//
//  Proof.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Cocoa

import Foundation

/**
 The Proof represents the top level of the user's proof

 # Testing
 - ProofTests
 */
public class Proof: BKSelfProvable, BKInspectable, BKAdvising {

    var inspectableText = ""

    var delegate: BKProofDelegate?

    var scope = [BKLine]()
    var scopeLevel = 0
    var theorems = [Int : UUID]()
    var currentTheorem: Theorem?
    var proven = false

    // Return an Int telling us which line of the scope
    // contains the overall proof theorem
    // If we can't find it, return -1
    var proofLine: Int {

        // If no lines, there can be no proof
        if scope.count == 0 {
            return -1
        }

        var i = 0
        for l in scope {

            if let _ = l as? Theorem {
                return i
            }

            i = i + 1

        }

        return -1

    }

    var eProof: ExportedProof?

    // A convenience variable to access .htmlVLN, which
    // might be nil (saving callers from having to unwrap)
    var htmlVLN: String {

        return eProof?.htmlVLN ?? ""

    }

    // When true, all advice is suppressed. Useful because some advice
    // calls Proof, and we can stop an infinite recursion by creating
    // a Proof object without advice
    var minimalVersion: Bool

    var advice = [Advice]()

    // MARK: Init

    init(_ text: String,
                minimalVersion: Bool = false) {

        // Minimal version will suppress advice
        // and only export html
        self.minimalVersion = minimalVersion

        // Preprocessing includes preserving empty lines
        let lines = preprocessedText(text)

        // Step through each line and add to proof
        addAll(lines: lines)

        // Store exported version of proof
        export()

    }

    init(_ text: String,
                minimalVersion: Bool = false,
                withDelegate delegate: BKProofDelegate) {

        self.minimalVersion = minimalVersion

        self.delegate = delegate

        let lines = preprocessedText(text)

        addAll(lines: lines)

        export()

    }

    private func preprocessedText(_ text: String) -> [String.SubSequence] {

        // Preserve lines with no content
        // (user might use these as spacing)
        let preservedEmptyLines = text.replacingOccurrences(
            of: "\n\n", with: "\n \n")

        return preservedEmptyLines.split(separator: "\n")

    }

    private func addAll(lines linesToAdd: [String.SubSequence]) {

        var i = 0
        for l in linesToAdd {

            add(String(l).trim)

            i = i + 1
        }


    }

    // MARK: Advising

    public func getAdvice() -> [Advice] {
        return advice
    }


    func appendAdvice(_ advice: Advice) {

        guard minimalVersion != true else {
            return
        }

        let lineCount = scope.count

        // Requested line should exist
        if advice.line > lineCount {
            return
        }

        // Don't add the same advice twice
        if self.advice.contains(advice) == false {
            self.advice.append(advice)
        }

    }

    func replaceAdvice(_ replacementAdvice: Advice) {

        guard minimalVersion != true else {
            return
        }

        let lineCount = scope.count

        // Requested line should exist
        if replacementAdvice.line > lineCount {
            return
        }

        // Some advice should exist. If not, simply add
        // the replacement advice instead of replacing
        if getAdvice().count == 0 {
            appendAdvice(replacementAdvice)
            return
        }


        // If requested line doesn't exist in current advice list
        // then add it
        var replacementLineExists = false

        for a in getAdvice() {
            if a.line == replacementAdvice.line {
                replacementLineExists = true
            }
        }

        // Therefore add it
        if replacementLineExists == false {
            appendAdvice(replacementAdvice)
            return
        }

        var myAdvice = [Advice]()

        for a in getAdvice() {
            if a.line == replacementAdvice.line {
                myAdvice.append(replacementAdvice)
            } else {
                myAdvice.append(a)
            }
        }

        self.advice = myAdvice

    }

    // MARK: Inpsection Text

    public func setInspectionText(){

        self.inspectableText = ""
        var i = 0
        for l in scope {
            self.inspectableText = self.inspectableText +
                ("\(i): \(l.getInspectionText())\n")
            i = i + 1

        }

        if getProven() == true {
            self.inspectableText = self.inspectableText +
            "Debug: Top level proof is proven\n"
        } else {
            self.inspectableText = self.inspectableText +
            "Debug: Top level proof is not yet proven\n"
        }
    }

    public func getInspectionText() -> String {
        return self.inspectableText
    }

}

// MARK: Export

extension Proof {

    // Populate our RudimentaryProof
    func export() {

        // We only work with justified lines and thorems
        let proofLines = scope

        // We must have at least one line
        guard proofLines.count > 0 else {
            return
        }

        guard minimalVersion != true else {
            eProof = ExportedProof(withProofLines: proofLines,
                                   withProofStatement: getLineFromNumber(proofLine),
                                   giveHtml: true,
                                   giveHtmlVLN: true)
            return
        }

        // Create an array of ProofExportData items from the proof
        eProof = ExportedProof(withProofLines: proofLines,
                               withProofStatement: getLineFromNumber(proofLine),
                               giveHtml: true,
                               giveHtmlVLN: true,
                               giveLatex: true,
                               giveMarkdown: true,
                               givePlainText: true)

        // Ask for pdf and images asynchronously, then notify delegate
        let concurrentQueue = DispatchQueue(label: "bakerstreet.concurrent.queue",
                                            attributes: .concurrent)

        concurrentQueue.async {
            self.eProof!.makePdf()
            self.eProof!.makeImage()

            DispatchQueue.main.async {
                self.notifyDelegateOfProofChange()
            }
        }

    }


}

// MARK: BKProofDelegate functions
extension Proof {

    func notifyDelegateOfProofChange() {

        guard let d = delegate else { return }

        d.proofDidCompleteExport(withExportedProoof: eProof!)

    }

}

// MARK: Storing theorems

extension Proof {
    

    private func getScopeLevel() -> Int {
        return self.scopeLevel
    }

    private func setCurrentTheorem(_ theorem: Theorem) {

        self.currentTheorem = theorem

    }

    func getCurrentTheorem(forScopeLevel s: Int) -> Theorem? {

        var t: Theorem?

        // Look through the proof. We want the last
        // theorem at the scope level above where we
        // are now (bearing in mind that a theorem
        // is a parent for lines that exist at one
        // level of scope increase (i.e. down in the
        // hierarchy)
        for l in scope {

            if l.lineType == .theorem {

                let lT = l as! Theorem

                if s - 1 == lT.scopeLevel {
                    t = lT

                }

            }

        }

        return t
    }

    func getLinesForTheorem(withTheoremUUID uuid: UUID) -> [BKLine] {

        var matchedLines = [BKLine]()

        for l in scope {

            guard l.lineType != .comment else {
                continue
            }

            guard l.lineType != .inactive else {
                continue
            }

            if l.lineType == .justified {
                let j = l as! Justified

                if j.parentTheorem.getIdentifier() == uuid {

                    matchedLines.append(j)

                }

            }

            if l.lineType == .theorem {
                let t = l as! Theorem

                if t.parentTheorem?.getIdentifier() == uuid {

                    matchedLines.append(t)

                }

            }

        }

        return matchedLines

    }

    private func getTheorem(forUUID uuid: UUID?) -> Theorem? {
        for l in scope {
            if l.getLineType() == .theorem {
                let t = l as! Theorem
                if t.getIdentifier() == uuid {
                    return t
                }
            }
        }
        return nil
    }

    private func getTheorem(forScopeLevel scope: Int) -> Theorem? {

        guard let t = getTheorem(forUUID: self.theorems[scope]) else {
            return nil
        }

        return t
    }

    private func setTheorem(_ theorem: Theorem){

        theorems[getScopeLevel()] = theorem.getIdentifier()

    }
}

// MARK: Provability

extension Proof {

    func setProven() {

        if scope.count == 0 {
            self.proven = false
            return
        }

        var proofProven = true
        var theoremFound = false
        var justifiedFound = false
        var i = 0



        for l in scope {

            if let t = l as? Theorem {

                theoremFound = true

                t.setProven()
                // t.setInspectionText()

                if t.proven == false {

                    proofProven = false

                    if minimalVersion != true {

                        advise(.theoremNotProven, lineNumber: i,
                               longDescription: HtmlLongDesc.theoremNotProven)

                    }

                } else {

                    if minimalVersion != true {

                        advise(.theoremProven, lineNumber: i)

                    }

                }

            }

            if let j = l as? Justified {

                justifiedFound = true

                j.setProven()
                // j.setInspectionText()
                if j.proven == true && minimalVersion != true {

                    advise(.justificationProven, lineNumber: i)

                } else {

                }

            }

            i = i + 1
        }

        // If we've found a theorem and a justified line, the
        // proof may be true. Otherwise, it can't be true
        if theoremFound == true && justifiedFound == true {
            self.proven = proofProven
        } else {
            proofProven = false
        }

        if proofProven == true && minimalVersion != true {

            replaceAdvice(Advice(
                forLine: proofLine,
                ofType: AdviceInstance.proofProven))


        } else {


        }

        // setInspectionText()

    }

    public func getProven() -> Bool {
        return self.proven
    }

    func getProof() -> Proof {
        return self
    }
}

// MARK: Line adding

extension Proof {

    private func add(_ text: String) {

        // It is inactive?
        // Make an inactive line
        if lineIsEmpty(text) {
            addInactive(text)
            setProven()
            return
        }

        // Does it start with two slashes?
        // Make it a comment
        if lineIsComment(text) {
            addCommentLine(text)
            setProven()
            return
        }

        // Does it have a turnstile?
        let turnStile = MetaType.turnStile.description
        let jS = MetaType.justificationSeparator.description

        if text.uppercased().contains(turnStile) {

            guard !(text.contains(jS)) else {

                appendAdvice(Advice(
                    forLine: getMyLineNumber(),
                    ofType: AdviceInstance.thereomNeedsNoJustification))
                addInactive(text)
                setProven()
                return

            }

            addTheorem(text)
            setProven()

            return

        }


        // Does it have a colon?
        // split and call addJustified, else call addJustified with empty assumption

        if text.contains(jS) {

            let parts = text.split(separator: Character(jS))

            // If we have a colon but there is only one 'part'
            // then a part is missing
            guard parts.count > 1 else {

                appendAdvice(
                    Advice(forLine: getMyLineNumber(),
                           ofType:
                        AdviceInstance.justificationNeedsJustified))
                addInactive(text)
                setProven()
                return

            }

            let formula = String(parts[0]).trim

            let justification = String(parts[1]).trim

            addJustified(formula, justification)

            setProven() // Is the overall proof now proven?
        } else {

            addJustified(text, "")

            setProven()
            return

        }

    }

    private func addInactive(_ text: String) {

        addToScope(Inactive(text, atScopeLevel: scopeLevel))
        // setInspectionText()
    }

    private func addCommentLine(_ text: String) {

        addToScope(Comment(text, atScopeLevel: scopeLevel))
        // setInspectionText()
    }

    private func addTheorem(_ text: String) {


        let il = Inactive(text, atScopeLevel: scopeLevel)

        do {

            let t = try Theorem(text,
                                atScopeLevel: scopeLevel,
                                parentTheorem: getCurrentTheorem(forScopeLevel: scopeLevel),
                                proof: self)
            setTheorem(t)
            addToScope(t)
            addToTheorem(t)
            // setInspectionText()
            setCurrentTheorem(t)
            self.scopeLevel += 1

        } catch Theorem.Error.formulaPoorlyFormed {

            appendAdvice(Advice(forLine: getMyLineNumber(),
                                ofType: AdviceInstance.theoremFormulaPoorlyFormed))
            addToScope(il)
            // setInspectionText()
        } catch Theorem.Error.LHSandRHSsame {

            appendAdvice(Advice(forLine: getMyLineNumber(),
                                ofType: AdviceInstance.theoremLHSandRHSsame))
            addToScope(il)
            // setInspectionText()
        } catch {

            appendAdvice(Advice(forLine: getMyLineNumber(),
                                ofType: AdviceInstance.unknownIssue))
            addToScope(il)
            // setInspectionText()
        }



    }

    // - ToDo: Some ugly logic here; can it be simplified?
    private func addJustified(_ infixFormula: String,
                              _ justification: String) {

        var text = ""
        if justification != "" {
            text = infixFormula + " : " + justification } else {
            text = infixFormula
        }

        let il = Inactive(text, atScopeLevel: scopeLevel)

        guard self.theorems.count > 0 else {

            if !(Formula(infixFormula).isWellFormed) {

                appendAdvice(Advice(forLine: getMyLineNumber(),
                                    ofType: AdviceInstance.justifiedFormulaPoorlyFormed))

            }

            appendAdvice(Advice(forLine: getMyLineNumber(),
                                ofType: AdviceInstance.justifiedNeedsParentTheorem))

            addToScope(il)
            // setInspectionText()
            return

        }

        guard let _ = getCurrentTheorem(forScopeLevel: scopeLevel) else {
            appendAdvice(Advice(forLine: getMyLineNumber(),
                                ofType: AdviceInstance.justifiedNeedsParentTheorem))

            addToScope(il)
            // setInspectionText()
            return
        }

        if justification == "" {

            appendAdvice(Advice(forLine: getMyLineNumber(),
                                ofType: AdviceInstance.justifiedNeedsJustification))

        }

        do {

            if operatorDecreasesOurScopeLevel(forJustification: justification) {

                self.scopeLevel -= 1

                guard let _ = getCurrentTheorem(forScopeLevel: scopeLevel) else {
                    appendAdvice(Advice(forLine: getMyLineNumber(),
                                        ofType: AdviceInstance.justifiedNeedsParentTheorem))

                    addToScope(il)
                    // setInspectionText()
                    return
                }

                let j = try Justified(infixFormula: infixFormula,
                                      parentTheorem: getCurrentTheorem(forScopeLevel: scopeLevel),
                                      justification: justification,
                                      proof: self,
                                      atScopeLevel: scopeLevel)
                addToScope(j)
                addToTheorem(j)
                return

            } else {
                let j = try Justified(infixFormula: infixFormula,
                                      parentTheorem: getCurrentTheorem(forScopeLevel: scopeLevel),
                                      justification: justification,
                                      proof: self,
                                      atScopeLevel: scopeLevel)
                addToScope(j)

                addToTheorem(j)
                // setInspectionText()
                return
            }

        } catch Justified.Error.formulaPoorlyFormed {

            appendAdvice(Advice(forLine: getMyLineNumber(),
                                ofType: AdviceInstance.justifiedFormulaPoorlyFormed))

        } catch Justified.Error.justificationNotRecognised {

            appendAdvice(Advice(forLine: getMyLineNumber(),
                                ofType: AdviceInstance.justificationNotRecognised))


        } catch {

            appendAdvice(Advice(forLine: getMyLineNumber(),
                                ofType: AdviceInstance.unknownIssue))

        }

        addToScope(il)
        addToTheorem(il)
        // setInspectionText()

    }

    private func operatorDecreasesOurScopeLevel(
        forJustification justification: String) -> Bool {

        let jString = justification.lowercased()
        let jIfString = Justification.ifIntroduction.description.lowercased()
        let jNotIString = Justification.notIntroduction.description.lowercased()
        let jNotEString = Justification.notElimination.description.lowercased()

        guard !jString.contains("<->") else {
            return false
        }

        if jString.contains(jIfString) ||
            jString.contains(jNotIString) ||
            jString.contains(jNotEString) {
            return true
        } else {
            return false
        }


    }

    private func addToTheorem(_ line : BKLine) {
        guard let t = getTheorem(forScopeLevel: getScopeLevel()) else {
            return
        }

        t.addToScope(line)
    }



}

// MARK: Line Processing

extension Proof {

    private func lineIsEmpty(_ text: String) -> Bool {

        if text.trim == "" {
            return true

        } else
        {
            return false

        }
    }

    private func lineIsComment(_ text: String) -> Bool {

        if text.trim.prefix(2) == "//" { return true } else { return false}

    }

    func getLineNumberFromIdentifier(_ id: UUID) -> Int {

        var i = 0
        for l in scope {
            if l.identifier == id {
                return i
            }
            i = i + 1
        }

        return i

    }

    func getIdentifierFromLineNumber(_ line: Int) -> UUID {

        let l = getLineFromNumber(line)
        return l.identifier

    }

    func getLineNumberFromLine(_ line: BKLine) -> Int? {

        var i = 0
        for l in scope {

            if l.getIdentifier() == line.getIdentifier() {
                return i

            }
            i = i + 1

        }

        return nil
    }

    func getLineFromNumber(_ number: Int) -> BKLine {
        var i = 0
        for l in scope {
            if i == number {
                return l

            }
            i = i + 1

        }

        return Inactive("", atScopeLevel: scopeLevel)

    }

    public func getLineCount() -> Int {
        return scope.count
    }

    func getMyLineNumber() -> Int {
        if scope.count == 0 {
            return 0
        } else {
            return scope.count
        }
    }

}

// MARK: Scope

extension Proof {

    private func addToScope(_ line: BKLine){

        self.scope.append(line)
    }

    private func getTheoremScope(forTheorem: Theorem) -> [BKLine] {
        var subSet = [BKLine]()

        for l in scope {

            if let j = l as? Justified {

                if j.parentTheorem.identifier == forTheorem.identifier {
                    subSet.append(l)
                }
            }
        }

        return subSet

    }
}
