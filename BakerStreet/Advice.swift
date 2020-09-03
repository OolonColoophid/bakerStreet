//
//  Advice.swift
//  Baker Street
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
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
    case theoremUnprovable
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
                return "Needs justification"
            case .justificationNotRecognised:
                return "Unknown justification"
            case .theoremUnprovable:
                return "Theorem unprovable"
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
                return "No theorem specified"
            case .assumptionFormulaNotFound:
                return "Formula not found"
            case .inferenceFailure:
                return "Inference rule failure"
            case .inferenceMustReferToTheorem:
                return "No theorem specified"
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
            case .theoremUnprovable:
                return 19
            case .justifiedNeedsJustification:
                return 18
            case .justifiedNeedsParentTheorem:
                return 17
            case .inferenceRefersToUnprovenLine:
                return 16
            case .justificationNeedsJustified:
                return 15
            case .justificationNotRecognised:
                return 14
            case .assumptionFormulaNotFound:
                return 13
            case .theoremLHSandRHSsame:
                return 12
            case .invalidParameterPositionEarly:
                return 11

            case .invalidParemeterCountLowForJustification:
                return 10
            case .invalidParemeterCountHighForJustification:
                return 9
            case .justificationNotProven:
                return 8
            case .theoremNotProven:
                return 7
            case .assumptionMustReferToTheorem:
                return 6
            case .inferenceMustReferToTheorem:
                return 5
            case .inferenceFailure:
                return 4

            case .proofProven:
                return 3
            case .theoremProven:
                return 2
            case .justificationProven:
                return 1

            case .thereomNeedsNoJustification:
                return 0
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
            case .theoremNotProven, .theoremUnprovable, .justificationNotProven, .justifiedNeedsJustification, .justifiedNeedsParentTheorem, .justificationNeedsJustified, .justificationNotRecognised, .thereomNeedsNoJustification, .theoremLHSandRHSsame, .invalidParameterPositionEarly, .invalidParemeterCountLowForJustification, .invalidParemeterCountHighForJustification, .justifiedFormulaPoorlyFormed, .theoremFormulaPoorlyFormed, .assumptionMustReferToTheorem, .assumptionFormulaNotFound, .inferenceFailure, .inferenceMustReferToTheorem, .inferenceRefersToUnprovenLine, .unknownIssue:
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

            case .theoremNotProven, .theoremUnprovable, .justificationNotProven, .justifiedNeedsJustification, .justifiedNeedsParentTheorem, .justificationNeedsJustified, .justificationNotRecognised, .thereomNeedsNoJustification, .theoremLHSandRHSsame, .invalidParameterPositionEarly, .invalidParemeterCountLowForJustification, .invalidParemeterCountHighForJustification, .justifiedFormulaPoorlyFormed, .theoremFormulaPoorlyFormed, .assumptionMustReferToTheorem, .assumptionFormulaNotFound, .inferenceFailure, .inferenceMustReferToTheorem, .inferenceRefersToUnprovenLine, .unknownIssue:
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


