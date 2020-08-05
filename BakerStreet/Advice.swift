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

        switch self {
            case .proofProven:
                return "Proof correct"
            case .theoremProven:
                return "Theorem proven"
            case .theoremNotProven:
                return "Theorem not proven"
            case .justificationProven:
                return "Justification proven"
            case .justificationNotProven:
                return "Justification not proven"
            case .justifiedNeedsJustification:
                return "Justification needed"
            case .justifiedNeedsParentTheorem:
                return "Parent theorem needed"
            case .justificationNeedsJustified:
                return "Justification needs assertion"
            case .justificationNotRecognised:
            return "Justification not recognised"
            case .thereomNeedsNoJustification:
                return "No justification needed"
            case .theoremLHSandRHSsame:
                return "LHS and RHS should differ"
            case .invalidParameterPositionEarly:
                return "All antecedent lines must be above"
            case .invalidParemeterCountLowForJustification:
                return "Too few antecedents"
            case .invalidParemeterCountHighForJustification:
                return "Too many antecedents"
            case .justifiedFormulaPoorlyFormed:
                return "Formula not well-formed"
            case .theoremFormulaPoorlyFormed:
                return "Theorem formula(s) not well-formed"
            case .assumptionMustReferToTheorem:
                return "Assumption must refer to theorem"
            case .assumptionFormulaNotFound:
                return "Assumption formula not found"
            case .inferenceFailure:
                return "Inference rule failure"
            case .inferenceMustReferToTheorem:
                return "Inference must refer to theorem"
            case .inferenceRefersToUnprovenLine:
                return "Antecedent or antecedents unproven"
            case .unknownIssue:
                return "Unknown issue"
        }
    }

    public var priority: Int {

        switch self {
            case .proofProven:
                return "Proof correct"
            case .theoremProven:
                return "Theorem proven"
            case .theoremNotProven:
                return "Theorem not proven"
            case .justificationProven:
                return "Justification proven"
            case .justificationNotProven:
                return "Justification not proven"
            case .justifiedNeedsJustification:
                return "Justification needed"
            case .justifiedNeedsParentTheorem:
                return "Parent theorem needed"
            case .justificationNeedsJustified:
                return "Justification needs assertion"
            case .justificationNotRecognised:
                return "Justification not recognised"
            case .thereomNeedsNoJustification:
                return "No justification needed"
            case .theoremLHSandRHSsame:
                return "LHS and RHS should differ"
            case .invalidParameterPositionEarly:
                return "All antecedent lines must be above"
            case .invalidParemeterCountLowForJustification:
                return "Too few antecedents"
            case .invalidParemeterCountHighForJustification:
                return "Too many antecedents"
            case .justifiedFormulaPoorlyFormed:
                return "Formula not well-formed"
            case .theoremFormulaPoorlyFormed:
                return "Theorem formula(s) not well-formed"
            case .assumptionMustReferToTheorem:
                return "Assumption must refer to theorem"
            case .assumptionFormulaNotFound:
                return "Assumption formula not found"
            case .inferenceFailure:
                return "Inference rule failure"
            case .inferenceMustReferToTheorem:
                return "Inference must refer to theorem"
            case .inferenceRefersToUnprovenLine:
                return "Antecedent or antecedents unproven"
            case .unknownIssue:
                return "Unknown issue"
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

    // The line number
    public let line: Int
    var lineAsString: String {
        get {
            return String(line)
        }
    }

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
         ofType newAdviceType: AdviceInstance,
         _ newLongDescription: String = "",
         _ newHyperlinkText: String = "more") {

        id = UUID()
        line = newLineNumber
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
        return line
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


