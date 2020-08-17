//
//  Theorem.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Foundation

public class Theorem {

    // BKLine
    var lineType = LineType.theorem
    var scopeLevel: Int
    var userText: String

    // BKInspectable
    var inspectableText = ""

    // BKIdentifiable
    var identifier = UUID()

    // BKSelfProvable
    var proven = false
    var scope = [BKLine]()

    // BKParseable
    var wellFormed = false

    // The theorem whose scope includes this theorem
    var parentTheorem: Theorem?
    // The proof to which this theorem belongs
    var proof: Proof

    // Formula(s) left of turnstile
    var lhsFormula = [Formula]()
    // Formula right of turnstile
    var rhsFormula = Formula("")

    var lhsAndRhsDiffer: Bool
    var lhsWellFormed: Bool
    var rhsWellFormed: Bool

    public enum Error: Swift.Error {
        case formulaPoorlyFormed
        case theoremUnprovable
        case LHSandRHSsame
    }

    init(_ text: String,               // What the user wrote
        atScopeLevel scopeLevel: Int,  // The current scope level
        parentTheorem: Theorem?,       // We may have a parent theorem
        proof: Proof                   // The current proof
    ) throws {

        if parentTheorem != nil {
            self.parentTheorem = parentTheorem
        }

        // Sensible defaults for later things to check
        lhsAndRhsDiffer = true
        lhsWellFormed = false
        rhsWellFormed = false

        // Set properties according to parameters
        self.userText = text
        self.scopeLevel = scopeLevel
        self.proof = proof

        // Determine LHS and RHS
        setLhsAndRhs(text)

        guard lhsAndRhsDiffer == true else {
            throw Theorem.Error.LHSandRHSsame
        }

        setWellFormed()

        guard wellFormed == true else {
            throw Theorem.Error.formulaPoorlyFormed
        }

        guard theoremProvable() == true || proof.isPedagogic == true else {
            throw Theorem.Error.theoremUnprovable
        }

        setProven()

        //setInspectionText()
    }

    // MARK: Scope

    func addToScope(_ line: BKLine) {
        self.scope.append(line)
    }

    func setScope(_ scope: [BKLine]) {
        self.scope = scope
    }


    // MARK: Parse

    func setLhsAndRhs(_ text: String) {

        let lhs = getLhsString(fromText: text)
        let rhs = getRhsString(fromText: text)

        self.lhsWellFormed = lhsIsWellFormed(lhs)
        self.rhsWellFormed = rhsIsWellFormed(rhs)

        // Set lhs and rhs formulae
        self.rhsFormula = Formula(rhs, respectCase: proof.respectCase)

        // Check if LHS and RHS differ
        if lhsFormula.count == 1 {
            self.lhsAndRhsDiffer = lhsFormula[0] != rhsFormula
        }

    }

    public func getLhsFormulae() -> [Formula] {
        return self.lhsFormula
    }

    public func getRhsFormula() -> Formula {
        return self.rhsFormula
    }

    private func getLhsString(fromText text: String) -> String {

        let range = getRangeOfTurnStile(forText: text)

        var lhs = text[text.startIndex...range.lowerBound]

        lhs.removeLast() // This is 'T' if turnstile text is |-

        let sLhs = String(lhs).trim

        return sLhs
    }

    private func getRhsString(fromText text: String) -> String {

        let range = getRangeOfTurnStile(forText: text)

        var rhs = text[range.lowerBound..<text.endIndex]

        rhs.removeFirst(MetaType.turnStile.description.count)

        let sRhs = String(rhs).trim

        return sRhs

    }

    private func getRangeOfTurnStile(forText text: String)
        -> Range<String.Index> {

            let turnstile = MetaType.turnStile.description
            return text.uppercased().range(of: turnstile)!

    }

    private func lhsIsWellFormed(_ lhs: String) -> Bool {

        // If LHS formula is empty, consider it true
        // (i.e. it is not false)
        guard lhs != "" else {
            return true
        }

        var wellFormed = true

        // Multiple LHS formulas
        if lhs.contains(",") {
            let formulae = lhs.split(separator: ",")

            for f in formulae {
                let i = Formula(String(f), respectCase: proof.respectCase)
                self.lhsFormula.append(i)
                if i.isWellFormed == false {
                    wellFormed = false
                }
            }
            return wellFormed
        }

        // Single LHS formula
        let myLhs = Formula(lhs, respectCase: proof.respectCase)

        self.lhsFormula.append(myLhs)

        return myLhs.isWellFormed

    }

    private func rhsIsWellFormed(_ rhs: String) -> Bool {

        // A theorem without a RHS is not well formed
        guard rhs != "" else {
            return false
        }

        return Formula(rhs).isWellFormed

    }

    // MARK: Description

    func shortDescription() -> String {

        var lhsDescription = ""
        let turnstile = MetaType.turnStile.description

        if self.wellFormed == false {
            return self.userText
        }

        if lhsFormula.count == 1 {

            return lhsFormula[0].infixText + " "
                + turnstile + " " + rhsFormula.infixText
        } else {

            for f in lhsFormula {
                lhsDescription += f.infixText + ", "
            }

            return lhsDescription + " "
                + turnstile + " " + rhsFormula.infixText
        }
    }

    // MARK: Helper

    func getFormulae() -> [Formula] {
        var formulae = lhsFormula
        formulae.append(rhsFormula)
        return formulae
    }

}

// MARK: BKLine (BKIdentifiable, BKInspectable)
extension Theorem: BKLine {

    // MARK: BKInspectable
    func setInspectionText() {

        var s = String(scopeLevel)

        s = s + " " + shortDescription()

        s = s.padding(toLength: 30, withPad: " ", startingAt: 0)

        s += inspectableTextAppend(property: "Type",
                                   value: lineType.description)
        s += inspectableTextAppend(property: "Well formed",
                                   value: getWellFormed().description)
        s += inspectableTextAppend(property: "Proven",
                                   value: getProven().description)

        self.inspectableText = s

    }

    func getInspectionText() -> String {
        return self.inspectableText

    }

    func inspectableTextAppend(property: String, value: String) -> String {
        return "\t[ \(property): \(value) ]"
    }

}

// MARK: Theorem provable

extension Theorem {

    func theoremProvable() -> Bool {

        // Get all LHS formulas in scope
        let lhsInScope = getAllLhsFormulasInScope()

        // Turn into super formula
        let lhsSuperFormula = Formula.makeSuperFormula(lhsInScope)

        // If we have no LHS, return true; i.e. don't throw
        guard lhsInScope.count > 0 else {
            return true
        }

        return lhsDoesEntailRhs(forLhs: lhsSuperFormula.infixText,
                                forRhs: rhsFormula.infixText)

    }

    // Collect all LHS formulas in scope (including current theorem)
    func getAllLhsFormulasInScope() -> [Formula] {

        var lhsInScope = [Formula]()

        // Add LHS of theorems above the current theorem in the scope
        for l in proof.scope {
            if l.lineType == .theorem {
                let t = l as! Theorem

                for l in t.lhsFormula {

                    lhsInScope.append(l)

                }

            }
        }

        // Add LHS of current theorem
        for l in self.lhsFormula {

            lhsInScope.append(l)

        }

        return lhsInScope

    }

}

// NOTE: This function is available at the global scope
//       to facilitate testing

func lhsDoesEntailRhs(forLhs lhs: String, forRhs rhs: String) -> Bool {

    // We take the LHS and the RHS and make them into a superformula
    // using ->
    //
    // e.g. For proof:
    //    p -> q |- p -> (q OR r)
    //    p -> q                                    : Assumption (3)
    //    p |- q OR r
    //    p                                     : Assumption (5)
    //
    // We test theorem provability for p |- q OR r with:
    // ( (p -> q) AND (p) ) -> (q OR r)
    //
    // Thus, if the LHS is true, the RHS must be true
    // but if the LHS is not true, we don't care about the RHS

    let entailmentFormulaInfix = "(" + lhs + ") -> (" + rhs + ")"

    let entailmentFormula = Formula(entailmentFormulaInfix,
                                    withTruthTable: true)

    return entailmentFormula.areTruthValuesAllTrue

}



// MARK: BKEvaluatable (BKSelfProvable, BKParseable)

extension Theorem: BKEvaluatable {

    // MARK: BKSelfProvable
    func setProven() {

        // Our theorem is true if:
        // - the RHS formula exists in the scope
        //   of the theorem and is proven
        // - all subproofs (theorems) are proven

        let rhs = self.getRhsFormula()
        let rF = rhs.tree.getAsText()

        // Remove self theorem from the current scope
        // so we don't include it in proof checking below
        // (where we are interested in the lines that follow it)

        let myScope = proof.getLinesForTheorem(withTheoremUUID: identifier)

        guard myScope.count > 0 else {
            self.proven = false
            return
        }

        for l in myScope {

            // Is it a theorem line?
            if let t = l as? Theorem {

                // Is it not proven?
                if t.getProven() != true {

                    // Then our theorem cannot be proven
                    // Early exit
                    self.proven = false
                    return
                }

            }

            // Continue if the line is justified
            guard let j = l as? Justified else { continue }

            // Is it in our RHS but not proven?
            let jF = j.formula.tree.getAsText()

            // Line's formula must be RHS of theorem
            guard jF == rF else { continue }

            if j.proven == true {

                // Then our theorem is not proven
                self.proven = true
            }


        }
    }


    func getProven() -> Bool {
        return self.proven
    }

    // MARK: BKParseable
    func setWellFormed() {

        if rhsFormula.isWellFormed != true {
            self.wellFormed = false
            return
        }

        if lhsFormula.count != 0 {

            for f in lhsFormula {
                if f.isWellFormed != true {
                    self.wellFormed = false
                    return
                }
            }
        }

        self.wellFormed = true
        return
    }

    func getWellFormed() -> Bool {
        return self.wellFormed
    }

}

// MARK: Equatable
extension Theorem: Equatable {

    public static func == (lhs: Theorem, rhs: Theorem) -> Bool {

        return lhs.lhsFormula == rhs.lhsFormula &&
            lhs.rhsFormula == rhs.rhsFormula

    }

}
