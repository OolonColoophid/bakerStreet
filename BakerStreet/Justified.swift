//
//  Justified.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Foundation

public class Justified {

    // BKLine
    var lineType = LineType.justified
    var scopeLevel: Int
    var userText: String

    // BKIdentifidable
    var identifier = UUID()

    // BKInspectable
    var inspectableText = ""

    // BKSelfProvable
    var proven = false
    var scope = [BKLine]()

    // BKParseable
    var wellFormed = false

    // The theorem whose scope includes this justified line
    var parentTheorem: Theorem
    // The proof to which this justified line belongs
    var proof: Proof

    var formula: Formula
    var justification: Justification
    var antecedents: [Int]
    var hasJustification: Bool

    public enum Error: Swift.Error {
        case formulaPoorlyFormed
        case justifiedNeedsParentTheorem
        case justificationNotRecognised
    }

    init(infixFormula: String,          // What the user wrote (formula)
         parentTheorem: Theorem?,       // We may have a parent theorem
         justification: String = "",    // What the user wrote (justif.)
         antecedents: [Int] = [],       // Antecedents - needed?
         proof: Proof,                  // Our proof
         atScopeLevel scopeLevel: Int   // Our scope level
    ) throws {

        // Sensible defaults
        hasJustification = false
        self.antecedents = [Int]()

        // Set properties according to parameters
        self.userText = infixFormula
        self.scopeLevel = scopeLevel

        self.formula = Formula(infixFormula)
        self.proof = proof

        // If there is no parent theorem,
        // throw
        if parentTheorem == nil {
            throw Justified.Error.justifiedNeedsParentTheorem
        }

        // Set parentTheorem
        self.parentTheorem = parentTheorem!

        self.justification = Justification.empty
        try self.justification = parseJustification(justification)

        self.antecedents = parseAntecedents(justification)

        setWellFormed()
        setProven()

        // If a formula in a justification is
        // poorly formed, throw
        if getWellFormed() == false {
            throw Justified.Error.formulaPoorlyFormed
        }

        // setInspectionText()

    }

    // MARK: Parsing

    public func parseJustification(_ text: String) throws -> Justification {

        let t = text.trim.lowercased()

        if t.contains(Justification.assumption.description.lowercased()) {
            return Justification.assumption
        }

        if t.contains(Justification.andIntroduction.description.lowercased()) {
            return Justification.andIntroduction
        }
        if t.contains(Justification.orIntroduction.description.lowercased()) {
            return Justification.orIntroduction
        }
        if t.contains(Justification.notIntroduction.description.lowercased()) {
            return Justification.notIntroduction
        }
        if t.contains(Justification.iffIntroduction.description.lowercased()) {
            return Justification.iffIntroduction
        }

        if t.contains(Justification.ifIntroduction.description.lowercased()) {
            return Justification.ifIntroduction
        }


        if t.contains(Justification.andElimination.description.lowercased()) {
            return Justification.andElimination
        }
        if t.contains(Justification.orElimination.description.lowercased()) {
            return Justification.orElimination
        }
        if t.contains(Justification.notElimination.description.lowercased()) {
            return Justification.notElimination
        }
        if t.contains(Justification.iffElimination.description.lowercased()) {
            return Justification.iffElimination
        }
        if t.contains(Justification.ifElimination.description.lowercased()) {
            return Justification.ifElimination
        }

        if t.contains(Justification.trueIntroduction.description.lowercased()) {
            return Justification.trueIntroduction
        }
        if t.contains(Justification.falseElimination.description.lowercased()) {
            return Justification.falseElimination
        }

        // Nothing recognised?
        throw Justified.Error.justificationNotRecognised
    }

    public func parseAntecedents(_ text: String) -> [Int] {

        // Receives e.g. "Assumption 1, 2, 3"

        // `\\d+` will match any numbers
        // In above example, expect ["1","2","3"]
        if let antecedentsMatches = text.regex("\\d+") {

            var antecedentsInt = [Int]()

            for a in antecedentsMatches {
                antecedentsInt.append(Int(a)!)
            }
            return antecedentsInt

        } else {
            return []
        }


    }

    func getAntecedentsAsString() -> String {

        if antecedents.count == 0 {
            return ""
        }

        if antecedents.count == 1 {
            let antecedentsString = " (" + String(antecedents[0]) + ")"
            return antecedentsString
        }

        var antecedentsString = " ("
        for a in antecedents {

            antecedentsString = antecedentsString + String(a) + ", "

        }

        // Trim the trailing ", "
        antecedentsString.removeLast(2)

        antecedentsString = antecedentsString + ")"

        return antecedentsString

    }

    // Window Text

    func getWindowText() -> String {
        if self.wellFormed == true {
            return self.formula.infixText
        } else {
            return self.userText
        }
    }

    // MARK: Description

    func shortDescription() -> String {
        return self.formula.infixText
    }

    // MARK: Scope

    func getParentTheorem() -> Theorem {
        return self.parentTheorem
    }



}

// MARK: BKLine (BKIdentifiable, BKInspectable)
extension Justified: BKLine {

    // MARK: BKInspectable
    func setInspectionText() {

        var s = String(scopeLevel)

        s += " \(self.formula.infixText)"

        s = s.padding(toLength: 30, withPad: " ", startingAt: 0)

        s += inspectableTextAppend(property: "Type",
                                   value: lineType.description)

        s += inspectableTextAppend(property: "Well formed",
                                   value: getWellFormed().description)
        s += inspectableTextAppend(property: "Proven",
                                   value: getProven().description)
        s += inspectableTextAppend(property: "RPN",
                                   value: self.formula.postfixText)
        s += inspectableTextAppend(property: "Parent Theorem",
                                   value: getParentTheorem().shortDescription())
        s += inspectableTextAppend(property: "Antecedents",
                                   value: self.getAntecedentsAsString())

        self.inspectableText = s
    }

    func getInspectionText() -> String {
        return self.inspectableText
    }

    func inspectableTextAppend(property: String, value: String) -> String {
        return "\t[ \(property): \(value) ]"
    }

}

// MARK: BKEvaluatable (BKSelfProvable, BKParseable)
extension Justified: BKEvaluatable {

    // MARK: BKSelfProvable
    func setProven() {

        var myInferenceController = InferenceController(
            line: self, proof: proof)

        guard justification != .empty else {
            self.proven = false
            return
        }

        self.proven = myInferenceController.rule(justification)

        return
    }

    func getProven() -> Bool {
        return self.proven
    }

    // MARK: BKParseable
    func setWellFormed() {
        self.wellFormed = self.formula.isWellFormed
    }

    func getWellFormed() -> Bool {
        return self.wellFormed
    }

}

// MARK: Equatable
extension Justified: Equatable {

    public static func == (lhs: Justified, rhs: Justified) -> Bool {
        return lhs.formula == rhs.formula
    }

}
