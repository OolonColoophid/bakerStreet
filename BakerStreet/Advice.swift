//
//  Advice.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Foundation

// MARK: Enum AdviceClass
public enum AdviceType {

    case warning
    case lineSuccess
    case proofSuccess

    public var symbolWhenActive: String {
        switch self {
            case .warning:
                return "⚠️"
            case .lineSuccess:
                return "✅"
            case .proofSuccess:
                return "✅"
        }
    }

    public var symbolWhenInactive: String {
        switch self {
            case .warning:
                return ""
            case .lineSuccess:
                return ""
            case .proofSuccess:
                return ""
        }
    }
}

// MARK: Enum AdviceInstance
public enum AdviceInstance {

    case proofProven
    case theoremProven
    case theoremNotProven
    case justificationProven
    case justificationNotProven
    case justifiedNeedsJustification
    case justifiedNeedsParentTheorem
    case justificationNeedsJustified
    case justificationNotRecognised
    case thereomNeedsNoJustification
    case theoremLHSandRHSsame
    case invalidParameterPositionEarly
    case invalidParemeterCountLowForJustification
    case invalidParemeterCountHighForJustification
    case justifiedFormulaPoorlyFormed
    case theoremFormulaPoorlyFormed
    case assumptionMustReferToTheorem
    case assumptionFormulaNotFound
    case inferenceFailure
    case inferenceMustReferToTheorem
    case inferenceRefersToUnprovenLine
    case unknownIssue

    public var shortDescription: String {
        // Maximum length 23 characters
        //              xxxxxxxxxxxxxxxxxxxxxxx
        switch self {
            case .proofProven:
                return "Correct"
            case .theoremProven:
                return "Proven"
            case .theoremNotProven:
                return "Theorem not proven"
            case .justificationProven:
                return "Proven"
            case .justificationNotProven:
                return "Justification not proven"
            case .justifiedNeedsJustification:
                return "Needs justification"
            case .justifiedNeedsParentTheorem:
                return "Needs parent theorem"
            case .justificationNeedsJustified:
                return "Needs assertion"
            case .justificationNotRecognised:
                return "Unknown justification"
            case .thereomNeedsNoJustification:
                return "Redundant justification"
            case .theoremLHSandRHSsame:
                return "Same LHS and RHS"
            case .invalidParameterPositionEarly:
                return "Antecedent must precede"
            case .invalidParemeterCountLowForJustification:
                return "Too few antecedents"
            case .invalidParemeterCountHighForJustification:
                return "Too many antecedents"
            case .justifiedFormulaPoorlyFormed:
                return "Formula not well-formed"
            case .theoremFormulaPoorlyFormed:
                return "Theorem not well-formed"
            case .assumptionMustReferToTheorem:
                return "No referencing theorem"
            case .assumptionFormulaNotFound:
                return "Formula not found"
            case .inferenceFailure:
                return "Inference rule failure"
            case .inferenceMustReferToTheorem:
                return "No referencing theorem"
            case .inferenceRefersToUnprovenLine:
                return "Antecedent not proven"
            case .unknownIssue:
                return "Unknown issue"
        }
    }

    public var priority: Int {

        // Lower numbers indicate higher priority
        switch self {
            case .justifiedFormulaPoorlyFormed:
                return 21
            case .theoremFormulaPoorlyFormed:
                return 20
            case .justifiedNeedsJustification:
                return 19
            case .justifiedNeedsParentTheorem:
                return 18
            case .inferenceRefersToUnprovenLine:
                return 17
            case .justificationNeedsJustified:
                return 16
            case .justificationNotRecognised:
                return 15
            case .assumptionFormulaNotFound:
                return 14
            case .theoremLHSandRHSsame:
                return 13
            case .invalidParameterPositionEarly:
                return 12

            case .invalidParemeterCountLowForJustification:
                return 11
            case .invalidParemeterCountHighForJustification:
                return 10
            case .justificationNotProven:
                return 9
            case .theoremNotProven:
                return 8
            case .assumptionMustReferToTheorem:
                return 7
            case .inferenceMustReferToTheorem:
                return 6
            case .inferenceFailure:
                return 5

            case .proofProven:
                return 4
            case .theoremProven:
                return 3
            case .justificationProven:
                return 2

            case .thereomNeedsNoJustification:
                return 1
            case .unknownIssue:
                return 0

        }
    }

    public var symbol: String {
        let warning = AdviceType.warning.symbolWhenActive
        let success = AdviceType.lineSuccess.symbolWhenActive
        let proofSuccess = AdviceType.proofSuccess.symbolWhenActive

        switch self {
            case .proofProven:
                return proofSuccess
            case .theoremProven, .justificationProven:
                return success
            case .theoremNotProven, .justificationNotProven, .justifiedNeedsJustification, .justifiedNeedsParentTheorem, .justificationNeedsJustified, .justificationNotRecognised, .thereomNeedsNoJustification, .theoremLHSandRHSsame, .invalidParameterPositionEarly, .invalidParemeterCountLowForJustification, .invalidParemeterCountHighForJustification, .justifiedFormulaPoorlyFormed, .theoremFormulaPoorlyFormed, .assumptionMustReferToTheorem, .assumptionFormulaNotFound, .inferenceFailure, .inferenceMustReferToTheorem, .inferenceRefersToUnprovenLine, .unknownIssue:
                return warning

        }


    }

    public var type: AdviceType {

        switch self {
            case .proofProven:
                return AdviceType.proofSuccess

            case .theoremProven:
                return AdviceType.lineSuccess
            case .justificationProven:
                return AdviceType.lineSuccess

            case .theoremNotProven, .justificationNotProven, .justifiedNeedsJustification, .justifiedNeedsParentTheorem, .justificationNeedsJustified, .justificationNotRecognised, .thereomNeedsNoJustification, .theoremLHSandRHSsame, .invalidParameterPositionEarly, .invalidParemeterCountLowForJustification, .invalidParemeterCountHighForJustification, .justifiedFormulaPoorlyFormed, .theoremFormulaPoorlyFormed, .assumptionMustReferToTheorem, .assumptionFormulaNotFound, .inferenceFailure, .inferenceMustReferToTheorem, .inferenceRefersToUnprovenLine, .unknownIssue:
                return AdviceType.warning

        }
    }

}

// MARK: Struct Advice
public struct Advice: Equatable {

    var id: UUID
    var idAsString: String {
        get {
            return id.uuidString
        }
    }

    // The line that the advice refers to
    public let lineAsInt: Int
    var lineAsString: String {
        get {
            return String(lineAsInt)
        }
    }
    public let lineAsUUID: UUID

    public let instance: AdviceInstance

    public let type: AdviceType

    // Return the symbol, such as a warning triangle
    var symbol: String {
        get {
            return instance.type.symbolWhenActive
        }
    }

    // The hyperlink text, e.g. "more"
    let hyper: String

    // The short description, e.g. "Theorem not proven"
    var shortDescription: String {
        get {
            return instance.shortDescription
        }
    }

    // The long description should be an HTML
    // formatted extended text
    let longDescription: String
    var longDescriptionAsNSMAS: NSMutableAttributedString {
        get {
            return longDescription.htmlToNSMAS()
        }
    }

    init(forLine newLineNumber: Int,
         forLineUUID newLineUUID: UUID,
         ofType newAdviceType: AdviceInstance,
         _ newLongDescription: String = "",
         _ newHyperlinkText: String = "more") {

        id = UUID()
        lineAsInt = newLineNumber
        lineAsUUID = newLineUUID
        instance = newAdviceType
        type = instance.type
        hyper = newHyperlinkText
        longDescription = newLongDescription

    }

    @available(*, deprecated, message: "Use .id")
    public func getIdentifier() -> UUID {
        return id
    }

    @available(*, deprecated, message: "Use .hyper")
    public func getHyperlinkText() -> String {
        return hyper
    }

    @available(*, deprecated, message: "Use .line or .lineAsString")
    public func getLineNumber() -> Int {
        return lineAsInt
    }

    @available(*, deprecated, message: "Use .type")
    public func getType() -> AdviceInstance {
        return instance
    }

    @available(*, deprecated, message: "Use .shortDescription")
    public func getShortDescription() -> String {
        return getType().shortDescription
    }

    @available(*, deprecated, message: "Use .longDescription")
    public func getLongDescription() -> String {
        
        return self.longDescription
    }
}


