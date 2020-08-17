//
//  RudimentaryProofLine.swift
//  Baker Street
//
//  Created by Ian Hocking on 30/07/2020.
//  Copyright © 2020 Ian. All rights reserved.
//

import Foundation

// This struct contains a proof line in rudimentary form (i.e. just
// its data). It can be used to create any visual form of the
// proof:
public struct RudimentaryProofLine {

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
        "@vAnt: \(visualLineNumbersAntecedents) \n"
    }

    init (withLineNumberUUID uuid: UUID) {

        lineNumberUUID = uuid

    }

}
