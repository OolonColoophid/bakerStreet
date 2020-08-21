//
//  Protocols.swift
//
//  These protocols help to define aspects of how proofs are handled
//  at the level of the proof itself and individual lines.
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Cocoa
import Foundation

// Proof delegate
// Used by controllers to receive proof updates
protocol BKProofDelegate {

    func proofDidCompleteExport(withExportedProoof: ExportedProof)

}

// Can report whether itself is proven
protocol BKSelfProvable {
    var proven: Bool { get set }
    var scope: [BKLine] { get set }

    mutating func setProven()
    func getProven() -> Bool

}

// Text of its main information can be rendered
// human readable
protocol BKInspectable {

    var inspectableText: String { get set }

    mutating func setInspectionText()

    func getInspectionText() -> String

    func inspectableTextAppend(property: String, value: String) -> String
}

// Uniquely identifiable
// e.g. 4 random bytes
protocol BKIdentifiable {
    var identifier: UUID { get set }

}

// Components can be queries about their wellformedness
protocol BKParseable {

    var wellFormed: Bool { get set }

    mutating func setWellFormed()
    func getWellFormed() -> Bool

}

// A line
protocol BKLine: BKIdentifiable, BKInspectable {

    var lineType: LineType { get set }
    var scopeLevel: Int { get set }
    var userText: String { get set }

}

// An evaluatable line
protocol BKEvaluatable: BKSelfProvable, BKParseable { }

// Produces user-readable text about its state
protocol BKAdvising {

    func getMyLineAsInt() -> Int
    func getMyLineAsUUID() -> UUID
    func getProof() -> Proof

}

extension BKAdvising {

    // Add advice for a particular line
    func advise(_ AdviceType: AdviceInstance,
                lineNumberAsInt: Int = -1,
                lineNumberAsUUID: UUID = UUID(),
                longDescription: String = "") {

        let proof = getProof()

        if lineNumberAsInt == -1 {                 // Not provided
            proof.addAdviceToLine(Advice(
                forLine: getMyLineAsInt(),   // Determine line as Int
                forLineUUID: getMyLineAsUUID(),     // Determine line as UUID
                ofType: AdviceType,
                longDescription)) }
        else {                                // Provided
            proof.addAdviceToLine(Advice(
                forLine: lineNumberAsInt,
                forLineUUID: lineNumberAsUUID,
                ofType: AdviceType,
                longDescription))
        }
    }

}

// Allows the user to zoom in/out
protocol BKZoomable {

    func BKZoomIn(_ view: NSView) -> Void
    func BKZoomOut(_ view: NSView) -> Void
    func BKZoomIn(_ views: [NSView]) -> Void
    func BKZoomOut(_ views: [NSView]) -> Void

}

