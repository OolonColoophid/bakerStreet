//
//  RudimentaryProofLine.swift
//  Baker Street
//
//  Created by Ian Hocking on 30/07/2020.
//  Copyright © 2020 Ian. All rights reserved.
//

import Foundation

// This struct contains a proof line in rudimentary form.
// It can be used to create any visual form of the
// proof
public struct RudimentaryProofLine {

    // A int representing scope depth
    var scopeLevel = 0

    // The visual line number of a given line
    var visuaLineNumberSelf: String = ""

    var lineNumberUUID: UUID

    // e.g. 0
    var intLineNumber: Int = 0

    // e.g. "<em>p</em> ∧ <em>q</em>"
    var statementHTMLWithGlyphs: String = ""

    // e.g. "p ∧ q"
    var statementWithGlyphs: String {
        statementHTMLWithGlyphs.htmlToNSMAS().string
    }

    // e.g. "(p \lor q)"
    var statementLatex: String {

        let operators = OperatorType.allCases
        var s = statementWithGlyphs

        // Replace ∧ etc.
        for o in operators {
            s = s.replacingOccurrences(of: o.glyph, with: " " + o.latexEntity + " ")
        }

        // Replace the ⊦
        s = s.replacingOccurrences(of: MetaType.turnStile.glyph, with: MetaType.turnStile.latexEntity)

        return "\\(" + s + "\\)"

    }

    var justification: Justification = .empty

    // Only used for Theorem lines
    var theoremProven: Bool = false

    var antecedentsUUIDs = [UUID]()

    // Visual ine numbers for those lines in the antecedentsUUIDs
    var visualLineNumbersAntecedents: String = ""

    var debugDescription: String {
        return "intLineNumber: \(intLineNumber), " +
        "visualLineNumber: \(visuaLineNumberSelf), " +
            "statementHTML: \(statementHTMLWithGlyphs), " +
            "statement: \(statementWithGlyphs), " +
            "UUID: \(lineNumberUUID), " +
            "scopeLevel: \(scopeLevel), " +
            "antecedentUUIDs: \(antecedentsUUIDs), " +
            "vAnt: \(visualLineNumbersAntecedents) \n"
    }

    init (withLineNumberUUID uuid: UUID) {

        lineNumberUUID = uuid

    }

}
