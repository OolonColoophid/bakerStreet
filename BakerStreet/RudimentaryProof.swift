//
//  RudimentaryProof.swift
//  Baker Street
//
//  Created by ian.user on 30/07/2020.
//  Copyright © 2020 Ian. All rights reserved.
//

import Foundation

// The final output will be derived from a struct
// that contains the proof in rudimentary form (i.e. just
// its data). It can be used to create any visual form of the
// proof:
struct RudimentaryProofLine {

    // A int representing scope depth
    var scopeLevel = 0

    // The visual line number of a given line
    var visuaLineNumberSelf: String = ""

    var lineNumberUUID: UUID

    // e.g. 0
    var intLineNumber: Int = 0

    // e.g. p AND q
    var statement: String = ""

    var justification: Justification = .empty

    // Only used for Theorem lines
    var theoremProven: Bool = false

    var antecedentsUUIDs = [UUID]()

    // Visual ine numbers for those lines in the antecedentsUUIDs
    var visualLineNumbersAntecedents: String = ""

    var debugDescription: String {
        return
            "@visualLineNumber: \(visuaLineNumberSelf), " +
                "@statement: \(statement), " +
                "@UUID: \(lineNumberUUID), " +
                "@scopeLevel: \(scopeLevel), " +
                "@antecedentUUIDs: \(antecedentsUUIDs), " +
        "@v: \(visualLineNumbersAntecedents) \n"
    }

    func dump(_ data: [RudimentaryProofLine]) -> String {

        return data.reduce("") { x, y in x + y.debugDescription }

    }

}
