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
 The Proof represents the user's proof

 # Testing
 - ProofTests
 */
public class Proof: BKSelfProvable {

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
    private var proofLineAsInt: Int {

        // If no lines, there can be no proof
        if scope.count == 0 {
            return -1
        }

        let proofLine = getProofLine()

        guard proofLine != nil else {
            return -1
        }

        var i = 0
        for l in scope {

            if l.identifier == proofLine!.identifier {
                return i
            }
            i = i + 1
        }

        return -1

    }

    var proofLineAsUUID: UUID {

        // Didn't find anything? Return a dummy UUID
        return getProofLine()?.identifier ?? UUID()

    }

    var eProof: ExportedProof?

    // A convenience variable to access .htmlVLN, which
    // might be nil (saving callers from having to unwrap)
    public var htmlVLN: String {

        return eProof?.htmlVLN ?? ""

    }

    // When true, all advice is suppressed. Useful because some advice
    // calls Proof, and we can stop an infinite recursion by creating
    // a Proof object without advice
    var isPedagogic: Bool

    // Normally, operands are pressed into lower case. But we generally
    // disprefer this for examples like A |- B OR ~B
    var respectCase: Bool

    public var advice = [Advice]()

    // MARK: Init

    public init(_ text: String,
                isPedagogic: Bool = false,
                respectCase: Bool = false) {

        // Pedagogic version will suppress advice
        self.isPedagogic = isPedagogic

        // Respect case if asked
        self.respectCase = respectCase

        // Preprocessing includes preserving empty lines
        let lines = preprocessedText(text)

        // Step through each line and add to proof
        addAll(lines: lines)

        // Store exported version of proof
        export()

    }

    init(_ text: String,
                isPedagogic: Bool = false,
                respectCase: Bool = false,
                withDelegate delegate: BKProofDelegate) {

        self.isPedagogic = isPedagogic

        self.respectCase = respectCase

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

}

// MARK: BKInspectable
extension Proof: BKInspectable {

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

    func inspectableTextAppend(property: String, value: String) -> String {
        return "\t[ \(property): \(value) ]"
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

        guard isPedagogic != true else {
            eProof = ExportedProof(withProofLines: proofLines,
                                   withProofStatement: getLineFromNumber(proofLineAsInt),
                                   giveHtml: true,
                                   giveHtmlVLN: true)
            return
        }

        // Create an array of ProofExportData items from the proof
        eProof = ExportedProof(withProofLines: proofLines,
                               withProofStatement: getLineFromNumber(proofLineAsInt),
                               giveHtml: true,
                               giveHtmlVLN: true,
                               giveLatex: true,
                               giveMarkdown: true)

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

                if j.parentTheorem.identifier == uuid {

                    matchedLines.append(j)

                }

            }

            if l.lineType == .theorem {
                let t = l as! Theorem

                if t.parentTheorem?.identifier == uuid {

                    matchedLines.append(t)

                }

            }

        }

        return matchedLines

    }

    private func getTheorem(forUUID uuid: UUID?) -> Theorem? {
        for l in scope {
            if l.lineType == .theorem {
                let t = l as! Theorem
                if t.identifier == uuid {
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

        theorems[getScopeLevel()] = theorem.identifier

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

                    if isPedagogic != true {

                        advise(AdviceInstance.theoremNotProven, lineNumberAsInt: i,
                               lineNumberAsUUID: t.identifier,
                               longDescription: HtmlLongDesc.theoremNotProven)

                    }

                } else {

                    if isPedagogic != true {

                        advise(.theoremProven, lineNumberAsInt: i, lineNumberAsUUID: t.identifier)

                    }

                }

            }

            if let j = l as? Justified {

                justifiedFound = true

                j.setProven()
                // j.setInspectionText()
                if j.proven == true && isPedagogic != true {

                    advise(.justificationProven, lineNumberAsInt: i, lineNumberAsUUID: j.identifier)

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

        if proofProven == true && isPedagogic != true {

            advise(.proofProven,
                lineNumberAsInt: proofLineAsInt,
                lineNumberAsUUID: proofLineAsUUID)


        } else {


        }

        // setInspectionText()

    }

    public func getProven() -> Bool {
        return self.proven
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

                addInactive(text)
                advise(AdviceInstance.thereomNeedsNoJustification)
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

                addInactive(text)
                advise(AdviceInstance.justificationNeedsJustified)
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

            addToScope(il)
            advise(AdviceInstance.theoremFormulaPoorlyFormed)
            // setInspectionText()

        } catch Theorem.Error.theoremUnprovable {

            let descriptionStyled = ("The left hand side of your theorem does not entail the right hand side. Without entailment, it cannot be proven.".p).asStyledHTML()

            addToScope(il)
            advise(AdviceInstance.theoremUnprovable,
                   longDescription: descriptionStyled)
            // setInspectionText()

        } catch Theorem.Error.LHSandRHSsame {

            addToScope(il)
            advise(AdviceInstance.theoremLHSandRHSsame)
            // setInspectionText()

        } catch {

            addToScope(il)
            advise(AdviceInstance.unknownIssue)
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

        
        guard Formula(infixFormula).isWellFormed == true else {

            addToScope(il)

            advise(AdviceInstance.justifiedFormulaPoorlyFormed)

            // setInspectionText()

            return

        }

        guard self.theorems.count > 0 else {

            addToScope(il)

            advise(AdviceInstance.justifiedNeedsParentTheorem)
            // setInspectionText()

            return

        }

        guard let _ = getCurrentTheorem(forScopeLevel: scopeLevel) else {

            addToScope(il)
            appendAdvice(Advice(forLine: getMyLineAsInt(),
                                forLineUUID: getMyLineAsUUID(),
                                ofType: AdviceInstance.justifiedNeedsParentTheorem))

            // setInspectionText()

            return
        }

        if justification == "" {

            addToScope(il)
            advise(AdviceInstance.justifiedNeedsJustification)

            // setInspectionTest()

            return
        }

        do {

            if operatorDecreasesOurScopeLevel(forJustification: justification) {

                self.scopeLevel -= 1

                guard let _ = getCurrentTheorem(forScopeLevel: scopeLevel) else {

                    addToScope(il)

                    advise(AdviceInstance.justifiedNeedsParentTheorem)

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

            addToScope(il)

            advise(AdviceInstance.justifiedFormulaPoorlyFormed)

        } catch Justified.Error.justificationNotRecognised {

            addToScope(il)

            advise(AdviceInstance.justificationNotRecognised)


        } catch {

            addToScope(il)

            advise(AdviceInstance.unknownIssue)

        }

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

            if l.identifier == line.identifier {
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




    func getProofLine() -> BKLine? {

        var i = 0
        for l in scope {

            if l is Theorem {
                return l
            }

            i = i + 1

        }

        return nil

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

// MARK: BKAdvising
extension Proof: BKAdvising {

    func getMyLineAsUUID() -> UUID {

        return getLineFromNumber(getMyLineAsInt()).identifier

    }

    func getMyLineAsInt() -> Int {

        // We count from 0, so if we have 1 line,
        // it is line 0
        return scope.count - 1

    }

    func getProof() -> Proof {
        return self
    }

    func addAdviceToLine(_ newAdvice: Advice) {

        guard isPedagogic != true else {
            return
        }

        // Requested line should exist
        if newAdvice.lineAsInt > scope.count {
            return
        }

        // Some advice should exist. If not, simply add
        // the replacement advice instead of replacing
        if advice.count == 0 {
            appendAdvice(newAdvice)
            return
        }

        // If requested line doesn't exist in current advice list
        // then add it
        var replacementLineExists = false

        for a in advice {
            if a.lineAsInt == newAdvice.lineAsInt {
                replacementLineExists = true
            }
        }

        // It doesn't exist yet - therefore add it
        if replacementLineExists == false {
            appendAdvice(newAdvice)
            return
        }

        var myAdvice = [Advice]()

        for a in advice {
            if a.lineAsInt == newAdvice.lineAsInt {
                myAdvice.append(newAdvice)
            } else {
                myAdvice.append(a)
            }
        }

        self.advice = myAdvice

    }

    func appendAdvice(_ advice: Advice) {

        guard isPedagogic != true else {
            return
        }

        let lineCount = scope.count

        // Requested line should exist
        if advice.lineAsInt > lineCount {
            return
        }

        // Don't add the same advice twice
        if self.advice.contains(advice) == false {
            self.advice.append(advice)
        }

    }

    public func getAdviceForLineUUID(withLineUUID uuid: UUID) -> Advice? {

        guard advice.count != 0 else {
            // No advice
            return nil
        }

        // Collect all advice for line
        var myAdvice = [Advice]()
        for a in advice {
            if a.lineAsInt == getLineNumberFromIdentifier(uuid) {
                myAdvice.append(a)
            }
        }

        guard myAdvice.count > 0 else {
            // No advice for line
            return nil
        }

        // Of the advice, find the highest priority
        var highestPriorityAdvice: Advice?
        var currentPriority = 0
        for a in myAdvice {

            if a.instance.priority > currentPriority {
                highestPriorityAdvice = a
            }

            currentPriority = a.instance.priority

        }

        return highestPriorityAdvice

    }

    public func getAdviceForAdviceUUID(withAdviceUUID uuid: UUID) -> Advice? {

        guard advice.count != 0 else {
            // No advice
            return nil
        }

        for a in advice {
            if a.id == uuid {
                return a
            }
        }

        return nil

    }

    // Do we have advice of a particular type (e.g.
    // proof success) for a given line?
    public func isAdviceForLine(_ uuid: UUID,
                                ofType type: AdviceType)
        -> Bool {

            guard advice.count != 0 else {
                // No advice
                return false
            }

            var typeFound = false

            for a in advice {
                let adviceType = a.type
                let thisLineNumber = a.lineAsInt

                if adviceType == type &&
                    getLineNumberFromIdentifier(uuid) == thisLineNumber {

                    typeFound = true

                }

            }

            return typeFound

    }

    public func getSuccessForLine(_ line: Int) -> [Advice]? {

        guard advice.count != 0 else {
            // No advice
            return nil
        }

        var myAdvice = [Advice]()
        for a in advice {

            guard a.type == .lineSuccess || a.type == .proofSuccess else {
                continue
            }

            guard a.lineAsInt == line else {
                continue
            }

            guard getLineFromNumber(line).lineType == .theorem else {
                continue
            }

            myAdvice.append(a)

        }

        return myAdvice

    }


}
