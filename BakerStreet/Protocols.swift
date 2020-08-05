//
//  Protocols.swift
//
//  These protocols help to define aspects of how proofs are handled
//  at the level of the proof itself and individual lines.
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
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
}

// Uniquely identifiable
// e.g. 4 random bytes
protocol BKIdentifiable {
    var identifier: UUID { get set }

    func getIdentifier() -> UUID

}

// Components are well formed
protocol BKParseable {
    var wellFormed: Bool { get set }

    mutating func setWellFormed()
    func getWellFormed() -> Bool

}

// A line
protocol BKLine: BKIdentifiable, BKInspectable {
    var lineType: LineType { get set }
    var scopeLevel: Int { get set }

    func getLineType() -> LineType

}

// An evaluatable line
protocol BKEvaluatable: BKSelfProvable, BKParseable { }

// Produces user-readable text about its state
protocol BKAdvising {

    func getMyLineNumber() -> Int
    func getProof() -> Proof

}

extension BKAdvising {

    // Replace advise for a particular line
    func advise(_ AdviceType: AdviceInstance,
                lineNumber: Int = -1,
                longDescription: String = "") {

        let proof = getProof()

        if lineNumber == -1 {                 // Not provided
            proof.replaceAdvice(Advice(
                forLine: getMyLineNumber(),   // Determine line functionally
                ofType: AdviceType,
                longDescription)) }
        else {                                // Provided
            proof.replaceAdvice(Advice(
                forLine: lineNumber,          // Use provided
                ofType: AdviceType,
                longDescription))
        }
    }
}

// Allows the user to zoom in/out
protocol BKZoomable {

    func BKzoomIn(_ view: NSTextView) -> Void
    func BKzoomOut(_ view: NSTextView) -> Void
    func BKzoomIn(_ views: [NSTextView]) -> Void
    func BKzoomOut(_ views: [NSTextView]) -> Void

}

extension BKZoomable {

    private func getZoomIn() -> CGFloat {
        return CGFloat(1 + BKPrefConstants.zoomIncrement)
    }

    private func getZoomOut() -> CGFloat {
        return CGFloat(1 - BKPrefConstants.zoomIncrement)
    }

    private func zoom(inDirection: String, forView view: NSTextView) {

        if inDirection == "in" {

            let largerSize = NSMakeSize(getZoomIn(), getZoomIn())
            view.scaleUnitSquare(to: largerSize)

        } else {

            let smallerSize = NSMakeSize(getZoomOut(), getZoomOut())
            view.scaleUnitSquare(to: smallerSize)

        }

    }

    public func BKzoomIn(_ view: NSTextView) {

        zoom(inDirection: "in", forView: view)

    }

    public func BKzoomOut(_ view: NSTextView) {

        zoom(inDirection: "out", forView: view)

    }

    public func BKzoomIn(_ views: [NSTextView]) {

        views.forEach {view in
            zoom(inDirection: "in", forView: view) }

    }

    public func BKzoomOut(_ views: [NSTextView]) {

        views.forEach {view in
            zoom(inDirection: "out", forView: view) }

    }
}
