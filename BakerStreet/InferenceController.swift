//
//  InferenceController.swift
//
//  An InferenceController contains the functions that check if
//  inference rules (e.g. AND Introduction) are successful.
//
//  As well as specific functions for these, it contains general
//  checking functions common to all inference rules.
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Foundation

public struct InferenceController: BKAdvising {

    var proof: Proof

    private var linesInScope: [BKLine]
    private var parentThereom: Theorem
    private var myLine: Justified
    private var myLineNumberAsInt: Int
    private var myLineNumberAsUUID: UUID
    private var antecedents: [Int]

    // Following a failure of checking (e.g. there are too
    // many antecedents), a message will be made available
    // in this string that can be passed back to the user.
    private var checkFunctionMessageData: String = ""

    private var checkFunctionMessage: String {
        set(message) {
            checkFunctionMessageData = message.p
        }
        get {
            return (checkFunctionMessageData).asStyledHTML()
        }
    }

    private var justificationTypeAndDescrpition: String {

        let type = myLine.justification.type
        let description = myLine.justification.description

        return "\(type) \(description)"
    }

    // Justification type and description
    private var jD: String {
        get {
            return justificationTypeAndDescrpition
        }
    }

    // Support functions for processing inferences:
    private var ii: InferenceInspector

    init(line: Justified,
         proof: Proof) {

        self.linesInScope = line.getParentTheorem().scope
        self.parentThereom = line.getParentTheorem()
        self.myLine = line
        self.proof = proof
        self.myLineNumberAsInt = proof.getLineNumberFromIdentifier(
            line.identifier)
        self.myLineNumberAsUUID = proof.getIdentifierFromLineNumber(myLineNumberAsInt)
        self.antecedents = line.antecedents

        self.ii = InferenceInspector(line: line, proof: proof)

    }

// MARK: Inference rule middle-manager

    // This function receives a request to validate a justification.
    // It does some general checks first (e.g. that the number of
    // antecedents is correct) and then goes ahead trying to validate
    // the justification. If the validation works for any permutation
    // of the antecedents, we can say that the validation works. We
    // return true.
    public mutating func rule (_ justification: Justification) -> Bool {

        // Some inference rules do not require all antecedents to be proven
        if  justification == .assumption  {

            guard checkGeneralConstraintsSatisfied(

                requiresAntecedentsProven: false

                ) == true
                else {
                    return false
            }

        } else {

            guard checkGeneralConstraintsSatisfied() == true
                else {
                    return false
            }

        }

        let antPermutations = antecedentPermutations()
        var permutationSucceeded = false

        for permutation in antPermutations {

            switch justification {
            case .empty:
                permutationSucceeded = false
            case .assumption:
                permutationSucceeded = ruleAssumption(permutation)
            case .andIntroduction:
                permutationSucceeded = ruleAndIntroduction(permutation)
            case .orIntroduction:
                permutationSucceeded = ruleOrIntroduction(permutation)
            case .notIntroduction:
                permutationSucceeded = ruleNotIntroduction(permutation)
            case .ifIntroduction:
                permutationSucceeded = ruleIfIntroduction(permutation)
            case .iffIntroduction:
                permutationSucceeded = ruleIffIntroduction(permutation)
            case .andElimination:
                permutationSucceeded = ruleAndElimination(permutation)
            case .orElimination:
                permutationSucceeded = ruleOrElimination(permutation)
            case .notElimination:
                permutationSucceeded = ruleNotElimination(permutation)
            case .ifElimination:
                permutationSucceeded = ruleIfElimination(permutation)
            case .iffElimination:
                permutationSucceeded = ruleIffElimination(permutation)
                case .trueIntroduction:
                permutationSucceeded = ruleTrueIntroduction(permutation)
                case .falseElimination:
                permutationSucceeded = ruleFalseElimination(permutation)
            }

            if permutationSucceeded == true {
                return permutationSucceeded
            }

        }

        // No permutation has succeeded
        return false

    }

    public func antecedentPermutations() -> [[Int]] {

        guard antecedents.count > 1 else {
            return [[antecedents[0]]]
        }

        if antecedents.count == 2 {
            let antecedentsArray = [

                [antecedents[0], antecedents[1]],
                [antecedents[1], antecedents[0]]

            ]
            return antecedentsArray

        } else {

            let antecedentsArray = [

                [antecedents[0], antecedents[1], antecedents[2]],
                [antecedents[0], antecedents[2], antecedents[1]],
                [antecedents[1], antecedents[0], antecedents[2]],
                [antecedents[1], antecedents[2], antecedents[0]],
                [antecedents[2], antecedents[0], antecedents[1]],
                [antecedents[2], antecedents[1], antecedents[0]]

            ]
            return antecedentsArray
        }

    }

    // MARK: Inference rule functions

    public mutating func ruleAssumption(_ antecedents: [Int]) -> Bool {

        let antecedentLine = ii.getAntecedentAsLine(forAntecedentLineNum: antecedents[0])

        // The antecendent must be a Theorem
        guard antecedentLine is Theorem else {

            checkFunctionMessage = "Your \(jD) must refer to a theorem. Currently, it refers to a \(antecedentLine.lineType.description) line."

            advise(AdviceInstance.assumptionMustReferToTheorem,
                   longDescription: checkFunctionMessage

            )

            return false
        }

        let consequentTree = ii.getMyTree()

        let antecedentTheorem = ii.getAntecedentLineAsTheorem(
            forLine: antecedentLine)


        // Try to find the assumption in the LHS of the theorem
        // If so, we can consider the assumption true
        for formula in antecedentTheorem.lhsFormula {
            if formula.tree == consequentTree {

                return true

            }
        }

        // If we got here, we haven't found the theorem
        // (long description reuses another error's description)
        let myFormula = myLine.formula.tokenStringHTMLPrettified
        let myTheoremLHS = antecedentTheorem.lhsFormula.commaList()

        checkFunctionMessage = "Your \(jD) must appear within the left hand side of a theorem. In other words, \(myFormula) must be a part of \(myTheoremLHS)."

        advise(AdviceInstance.assumptionFormulaNotFound,
               longDescription: checkFunctionMessage
        )

        return false

    }

    public mutating func ruleAndIntroduction(_ antecedents: [Int]) -> Bool {

        // Both antecedents must be justified lines
        guard checkAntecedentsAreJustified() == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // Currrent line must have AND has top level operator
        guard checkMyTopLevelOperator(isOperator: .lAnd) == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage
            )
            return false
        }

        // Current line first and second child must be different
        guard checkMyChildrenAreDifferent() == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage
            )
            return false
        }

        // Antecedent 1 and antecedent 2 must be different
        guard checkAntecedentsAreDifferent() == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage
            )
            return false
        }

        // Current line first child must be antecedent 1 or antecedent 2
        guard checkAChildIsAnAntecedent(whereChildIs: "first") else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage
            )
            return false
        }

        // Current line second child must be antecedent 1 or antecedent 2
        guard checkAChildIsAnAntecedent(whereChildIs: "second") else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage
            )
            return false
        }

        // All conditions satisfied

        return true

    }

    public mutating func ruleOrIntroduction(_ antecedents: [Int]) -> Bool {

        // All antecedents must be justified lines
        guard checkAntecedentsAreJustified() == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // Current line must have OR as its top level element
        guard checkMyTopLevelOperator(isOperator: .lOr) == true else {
                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage
                )
                return false
        }

        // Current line first and second child must be different
        guard checkMyChildrenAreDifferent() == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage
            )
            return false
        }


        // Current line must have the antecedent as a child
        guard checkAntecedentIsChild(
            forAntecedentLineNum: antecedents[0]
            ) == true else {
                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false

        }

        // All conditions satisfied

        return true

    }

    public mutating func ruleNotIntroduction(_ antecedents: [Int]) -> Bool {

        // Antecedent is a theorem
        guard checkAntecedentIsTheorem() == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // The RHS of the antecedent theorem has the toplevel element AND
        let rhs = ii.getTheoremRHS(forAntecedentLineNum: antecedents[0])

        guard checkHasTopLevelOperator(rhs.tree, .lAnd) == true else {

            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // The RHS first child is the NEGATED RHS second child
        let rhsFC = rhs.tree.getFirstChild()
        let negatedRhsSC = negate(rhs.tree.getSecondChild())

        guard checkTreesEquivalent(rhsFC, negatedRhsSC) else {

            checkFunctionMessage = "Your \(jD) requires that the first child (i.e. left of the top level logical connective, \(rhsFC.description)) of the theorem line \(antecedents[0].noun) is a negated form of the second child."

            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // The LHS has one formula
        let lhs = ii.getTheoremLHS(forAntecedentLineNum: antecedents[0])

        guard lhs.count == 1 else {

            checkFunctionMessage = "Your \(jD) requires that the left-hand side of the theorem at line \(antecedents[0].noun) contain one formula. At the moment, this line contains \(antecedents[0].adjective) element\(antecedents[0].s)."

            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // The LHS formula is the NEGATED current line formula
        let negatedCurrentTree = negate(ii.getMyTree())

        guard checkTreesEquivalent(lhs[0].tree, negatedCurrentTree) else {

            checkFunctionMessage = "Your \(jD) requires that the left-hand side of the theorem at line \(antecedents[0].noun), \(lhs[0].tokenStringHTMLPrettified), is a negated form of the current line (\(myLine.formula.tokenStringHTMLPrettified)."

            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // All conditions satisfied

        return true

    }

    public mutating func ruleIfIntroduction(_ antecedents: [Int]) -> Bool {

        // Antecedent must be theorem
        let line = ii.getAntecedentAsLine(forAntecedentLineNum: antecedents[0])

        guard line is Theorem else {
            checkFunctionMessage = "Your \(jD) must refer to a theorem. Currently, it refers to a \(line.lineType.description) line."

            advise(AdviceInstance.assumptionMustReferToTheorem,
                   longDescription: checkFunctionMessage)

            return false
        }

        // The LHS has one formula
        let lhs = ii.getTheoremLHS(forAntecedentLineNum: antecedents[0])

        guard lhs.count == 1 else {

            checkFunctionMessage = "Your \(jD) requires that the left-hand side of the theorem at line \(antecedents[0].noun) contain one formula. At the moment, this line contains \(antecedents[0].adjective) element\(antecedents[0].s)."

            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // Antecedent LHS and RHS must be different
        let rhs = ii.getTheoremRHS(forAntecedentLineNum: antecedents[0])

        guard checkTreesAreDifferent(lhs[0].tree, rhs.tree) == true else {

            checkFunctionMessage = "Your \(jD) requires that the left-hand and right-hand sides of the theorem at line \(antecedents[0].noun) must be different. Currently, they are the same."

            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // Currrent line must have IF has top level operator
        let tloRequired = OperatorType.lIf
        let tloSupplied = ii.getMyTopLevelToken()

        guard checkMyTopLevelOperator(isOperator: .lIf) == true else {

            checkFunctionMessage = "Your \(jD) requires that the top level operator (i.e. logical connective) of the current line is \(tloRequired.description). Currently, it is \(tloSupplied.description)."

            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage
            )
            return false
        }

        // Current line first and second child must be different
        guard checkMyChildrenAreDifferent() == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage
            )
            return false
        }


        // Antecedent LHS must match current line first child
        guard lhs[0].tree == ii.getMyTree().getFirstChild() else {

            checkFunctionMessage = "Your \(jD) requires that the left-hand side of the theorem at line \(antecedents[0].noun), \(lhs[0].tokenStringHTMLPrettified), matches the current line."

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage
                )
                return false
        }

        // Antecedent RHS must match current line second child
        let currentLineSC = ii.getMyTree().getSecondChild()

        guard rhs.tree == currentLineSC else {

            checkFunctionMessage = "Your \(jD) requires that the right-hand side of the theorem at line \(antecedents[0].noun), \(rhs.tokenStringHTMLPrettified), matches the current line's second child element (i.e. that part to the right of the top level operator, or \(currentLineSC.description))."

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage
                )
                return false
        }

        // All conditions satisfied

        return true
    }


    public mutating func ruleTrueIntroduction(_ antecedents: [Int]) -> Bool {

        // Current line is only the true constant
        guard ii.getMyTopLevelTokenAsString() == "true" else {

            checkFunctionMessage = "Your \(jD) requires that the current formula must be the constant <em>true</em>."

            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        return true

    }

    public mutating func ruleFalseElimination(_ antecedents: [Int]) -> Bool {

        // Antecedent is false
        guard ii.getAntecedentTopLevelElementAsString(
            forAntecedentLineNum: antecedents[0]) == "false" else {

                checkFunctionMessage = "Your \(jD) requires that the formula on line \(antecedents[0]) must be the constant <em>false</em>."

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        return true

    }

    public mutating func ruleIffIntroduction(_ antecedents: [Int]) -> Bool {

        // Both antecedents are justified lines
        guard checkAntecedentsAreJustified() == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // First antecedent must have IF as its top level element
        guard checkAntecedentTopLevelOperator(
            forAntecedentLineNum: antecedents[0],
            isOperator: .lIf
            ) == true else {
                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // Second antecedent must have IF as its top level element
        guard checkAntecedentTopLevelOperator(
            forAntecedentLineNum: antecedents[1],
            isOperator: .lIf
            ) == true else {
                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // First and second child of first antecdent are different
        guard checkAntecedentChildrenAreDifferent(
            antecedentLine: antecedents[0]) == true else {
                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // First and second child of current line are different
        guard checkMyChildrenAreDifferent() == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)

            return false
        }

        // The first child of the first antecedent is the second
        // child of the second antecedent
        guard ii.getAntecedentFirstChild(forAntecedentLineNum: antecedents[0]) ==
            ii.getAntecedentSecondChild(forAntecedentLineNum: antecedents[1]) else {

                checkFunctionMessage = "Your \(jD) requires that the first child of the first antecedent at line \(antecedents[0].noun) is the second child of the second antecedent at line \(antecedents[1].noun)."

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                // child of the second antecedent")
                return false
        }

        // The second child of the first antecedent is the first
        // child of the second antecedent
        guard ii.getAntecedentSecondChild(forAntecedentLineNum: antecedents[0]) ==
            ii.getAntecedentFirstChild(forAntecedentLineNum: antecedents[1]) else {

                checkFunctionMessage = "Your \(jD) requires that the second child of the first antecedent at line \(antecedents[0].noun) is the first child of the second antecedent at line \(antecedents[1].noun)."


                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                // child of the second antecedent")
                return false
        }

        // The first child of the current line is the first child
        // of the first antecedent
        guard ii.getMyFirstChild() ==
            ii.getAntecedentFirstChild(forAntecedentLineNum: antecedents[0]) else {

                checkFunctionMessage = "Your \(jD) requires that the first child of the current line is the first child of the first antecedent at line \(antecedents[0].noun)."

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // The second chlid of the current line is the second child
        // of the first antecedent
        guard ii.getMySecondChild() ==
            ii.getAntecedentSecondChild(forAntecedentLineNum: antecedents[0]) else {

                checkFunctionMessage = "Your \(jD) requires that the second child of the current line is the second child of the first antecedent at line \(antecedents[0].noun)."

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // The current line has IFF as its top level operator
        guard checkMyTopLevelOperator(isOperator: .lIff) == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage
            )
            return false
        }

        // All conditions satisfied

        return true

    }

    public mutating func ruleAndElimination(_ antecedents: [Int]) -> Bool {

        // All antecedents must be justified lines
        guard checkAntecedentsAreJustified() == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // Antecedent must have AND as its top level element
        guard checkAntecedentTopLevelOperator(
            forAntecedentLineNum: antecedents[0],
            isOperator: .lAnd
            ) == true else {
                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // Antecedent chlidren should be different
        guard checkAntecedentChildrenAreDifferent(
            antecedentLine: antecedents[0]) == true else {
                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage
                )
                return false
        }

        // Antecedent must be parent of current line
        guard checkAntecedentIsParent(
            forAntecedentLineNum: antecedents[0]
            ) == true else {
                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // All conditions satisfied

        return true

    }


    public mutating func ruleOrElimination(_ antecedents: [Int]) -> Bool {

        // All antecedents are justified lines
        guard checkAntecedentsAreJustified() == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // First antecedent should have OR as top level element
        guard checkAntecedentTopLevelOperator(
            forAntecedentLineNum: antecedents[0],
            isOperator: .lOr
            ) == true else {
                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // Second antecedent should have IF as top level element
        guard checkAntecedentTopLevelOperator(
            forAntecedentLineNum: antecedents[1],
            isOperator: .lIf
            ) == true else {
                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // Third antecedent should have IF as top level element
        guard checkAntecedentTopLevelOperator(
            forAntecedentLineNum: antecedents[2],
            isOperator: .lIf
            ) == true else {

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // First antecedent children should be different
        guard checkAntecedentChildrenAreDifferent(antecedentLine: antecedents[0]) == true else {
                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }


        // Second antecedent children should be different
        guard checkAntecedentChildrenAreDifferent(antecedentLine: antecedents[1]) == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // First antecedent first child should be second antecedent first child
        guard ii.getAntecedentFirstChild(forAntecedentLineNum: antecedents[0]) ==
            ii.getAntecedentFirstChild(forAntecedentLineNum: antecedents[1]) else {

                checkFunctionMessage = "Your \(jD) requires that the first child of the first antecedent at line \(antecedents[0].noun) is the second child of the second antecedent at line \(antecedents[1].noun)."


                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // First antecedent second child should be third antecedent first child
        guard ii.getAntecedentSecondChild(forAntecedentLineNum: antecedents[0]) ==
            ii.getAntecedentFirstChild(forAntecedentLineNum: antecedents[2]) else {

                checkFunctionMessage = "Your \(jD) requires that the second child of the first antecedent at line \(antecedents[0].noun) is the first child of the third antecedent at line \(antecedents[1].noun)."

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // Second antecedent second child should be third antecedent second child
        guard ii.getAntecedentSecondChild(forAntecedentLineNum: antecedents[1]) ==
            ii.getAntecedentSecondChild(forAntecedentLineNum: antecedents[2]) else {

                checkFunctionMessage = "Your \(jD) requires that the second child of the second antecedent at line \(antecedents[0].noun) is the second child of the third antecedent at line \(antecedents[2].noun)."

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // Current line should be second child of second antecedent
        guard ii.getMyTree() ==
            ii.getAntecedentSecondChild(forAntecedentLineNum: antecedents[1]) else {

                checkFunctionMessage = "Your \(jD) requires that the current line is the second child of the second antecedent at line \(antecedents[1].noun)."

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // Current line should be
        // second child of third antecedent
        guard ii.getMyTree() ==
            ii.getAntecedentSecondChild(forAntecedentLineNum: antecedents[2]) else {

                checkFunctionMessage = "Your \(jD) requires that the current line is the second child of the third antecedent at line \(antecedents[2].noun)."

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }

        // All conditions satisfied

        return true

    }

    public mutating func ruleNotElimination(_ antecedents: [Int]) -> Bool {

        // Antecedent is a theorem
        guard checkAntecedentIsTheorem() == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // The RHS of the antecedent theorem has the toplevel element AND
        let rhs = ii.getTheoremRHS(forAntecedentLineNum: antecedents[0])
        let tlo = OperatorType.lAnd

        checkFunctionMessage = "Your \(jD) requires that the top level operator (i.e. logical connective, \(rhs.tree.getToken().description) of the theorem line \(antecedents[0].noun) is \(tlo.description)."

        guard checkHasTopLevelOperator(rhs.tree, .lAnd) == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // The RHS first child is the NEGATED RHS second child
        let rhsFC = rhs.tree.getFirstChild()
        let negatedRhsFC = negate(rhs.tree.getSecondChild())

        guard checkTreesEquivalent(rhsFC, negatedRhsFC) else {

            checkFunctionMessage = "Your \(jD) requires that the first child (i.e. left of the top level logical connective, \(rhsFC.description) of the theorem line \(antecedents[0].noun) is a negated form of the second child."

            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // The LHS has one formula
        let lhs = ii.getTheoremLHS(forAntecedentLineNum: antecedents[0])

        guard lhs.count == 1 else {

            checkFunctionMessage = "Your \(jD) requires that the left-hand side of the theorem at line \(antecedents[0].noun) contain one formula. At the moment, this line contains \(antecedents[0].adjective) element\(antecedents[0].s)."

            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }
        // The NEGATED LHS formula is the current line formula
        let negatedLhs = negate(lhs[0].tree)

        guard checkTreesEquivalent(negatedLhs, ii.getMyTree()) == true else {

            checkFunctionMessage = "Your \(jD) requires that the negated left-hand side formula of the theorem line \(antecedents[0].noun) is a negated form of the current line."

            return false
        }

        // All conditions satisfied

        return true

    }

    public mutating func ruleIfElimination(_ antecedents: [Int]) -> Bool {

        // Both antecedents must be justified lines
        guard checkAntecedentsAreJustified() == true else {

            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)

            return false
        }

        // First antecedent should have IF as toplevel operator
        guard checkAntecedentTopLevelOperator(
            forAntecedentLineNum: antecedents[0],
            isOperator: .lIf) == true else {

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage
            )

            return false
        }

        // Second antecedent should be first child of first antecedent
        guard ii.getAntecedentFirstChild(
            forAntecedentLineNum: antecedents[0]) ==
            ii.getAntecedentAsTree(
                forAntecedentLineNum: antecedents[1]
            ) else {

                checkFunctionMessage = "Your \(jD) requires that the first child of the first antecedent at line \(antecedents[0].noun) is the second antecedent at line \(antecedents[1].noun)."

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage

                )
                return false
        }


        // Current line should be second child of first antecedent
        guard ii.getMyTree() == ii.getAntecedentSecondChild(
            forAntecedentLineNum: antecedents[0]) else {

              checkFunctionMessage = "Your \(jD) requires that the second child of the first antecedent at line \(antecedents[0].noun) is the current line."

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)

                return false
        }

        // All conditions satisfied

        return true

    }

    public mutating func ruleIffElimination(_ antecedents: [Int]) -> Bool {

        // All antecedents must be justified lines
        guard checkAntecedentsAreJustified() == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage)
            return false
        }

        // The first child of the current line is a child of the antecedent
        guard (
            ii.getMyFirstChild()
                ==
                ii.getAntecedentFirstChild(forAntecedentLineNum: antecedents[0])
            )
            ||
            (
                ii.getMyFirstChild() ==
                    ii.getAntecedentSecondChild(forAntecedentLineNum: antecedents[0])
            )
            else {

                checkFunctionMessage = "Your \(jD) requires that a child of the antecedent at line \(antecedents[0].noun) is the first child of the current line."

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage
                )
                return false
        }

        // The second child of the current line is a child of the antecedent
        guard (
            ii.getMySecondChild()
                ==
                ii.getAntecedentFirstChild(forAntecedentLineNum: antecedents[0])
            )
            ||
            (
                ii.getMySecondChild() ==
                    ii.getAntecedentSecondChild(forAntecedentLineNum: antecedents[0])
            )
            else {

                checkFunctionMessage = "Your \(jD) requires that a child of the antecedent at line \(antecedents[0].noun) is the second child of the current line."

                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage
                )
                return false
        }

        // The top level operator of the antecedent is IFF
        guard checkAntecedentTopLevelOperator(
            forAntecedentLineNum: antecedents[0],
            isOperator: .lIff
            ) == true else {
                advise(AdviceInstance.inferenceFailure,
                       longDescription: checkFunctionMessage)
                return false
        }


        // The top level operator of the current line is IF
        guard checkMyTopLevelOperator(isOperator: .lIf) == true else {
            advise(AdviceInstance.inferenceFailure,
                   longDescription: checkFunctionMessage
            )
            return false
        }

        // All conditions satisfied

        return true

    }



    // MARK: Checking

    private func checkTreesAreDifferent(_ a: Tree, _ b: Tree) -> Bool {
        return a != b
    }

    private func checkTreesEquivalent(_ lhs: Tree, _ rhs: Tree) -> Bool {

        let lNot = OperatorToken(operatorType: .lNot).description

        // Semantically equivalent (e.g. '~~p' == 'p')
        let joinedLhs = lhs.getAsText().joined(separator: " ")
        let joinedRhs = rhs.getAsText().joined(separator: " ")
        var joinedLhsRepl = ""
        var joinedRhsRepl = ""

        joinedLhsRepl = joinedLhs.replacingOccurrences(of: "\(lNot) \(lNot) ", with: "").trim

        joinedRhsRepl = joinedRhs.replacingOccurrences(of: "\(lNot) \(lNot) ", with: "").trim

        return joinedLhsRepl == joinedRhsRepl

    }

    private func checkChildrenAreDifferent(_ tree: Tree) -> Bool {

        if checkTreesAreDifferent(
            tree.getFirstChild(), tree.getSecondChild()) {
            return true
        } else {
            return false
        }
    }


    // MARK: Not tested
    private mutating func checkAntecedentChildrenAreDifferent(
        antecedentLine: Int) -> Bool {

        let aTree = ii.getAntecedentAsTree(
            forAntecedentLineNum: antecedentLine)

        if checkChildrenAreDifferent(aTree) == true {
            return true
        } else {

            checkFunctionMessage = "Your \(jD) requires that the first and second children (the parts to the left and of the top level operator) in line \(antecedentLine.noun) are different."

            return false

        }

    }


    // MARK: Not tested
    private mutating func checkMyChildrenAreDifferent() -> Bool {

        let myTree = ii.getMyTree()

        let areDifferent = checkChildrenAreDifferent(myTree)

        let myChildren = myTree.getFirstChild().getToken().description

        if areDifferent == false {

            checkFunctionMessage = """
                Your \(jD) requires that the formulas either side of the top level operator (i.e. logical connective) in line \(myLineNumberAsInt.noun) be different. However, they are both \(myChildren).
            """
        }

        return areDifferent


    }

    // MARK: Not tested
    private mutating func checkAntecedentsAreDifferent()
    -> Bool {

        let a1tree = ii.getAntecedentAsTree(
            forAntecedentLineNum: antecedents[0])
        let a2tree = ii.getAntecedentAsTree(
            forAntecedentLineNum: antecedents[1])

        let areDifferent = checkTreesAreDifferent(a1tree, a2tree)

        if areDifferent == false {

            checkFunctionMessage = """
                Your \(jD) requires that the antecedents (lines \(antecedents[0].noun) and \(antecedents[1].noun) be different. However, they are both \(a1tree.getToken().description).
                """
        }

        return areDifferent

    }

    // MARK: Untested
    private mutating func checkAChildIsAnAntecedent(whereChildIs order: String) -> Bool {

        if order == "first" {
            let fc = ii.getMyFirstChild()
            let a1 = ii.getAntecedentAsTree(
                forAntecedentLineNum: antecedents[0])
            let a2 = ii.getAntecedentAsTree(
                forAntecedentLineNum: antecedents[1])

            let al1 = ii.getAntecedentAsLine(forAntecedentLineNum: antecedents[0]) as! Justified
            let al2 = ii.getAntecedentAsLine(forAntecedentLineNum: antecedents[1]) as! Justified

            let isAntecedentIsFalse = fc == a1 || fc == a2

            if isAntecedentIsFalse {

                checkFunctionMessage = """
                    Your \(jD) requires that line \(myLineNumberAsInt.noun) is the first child element of either line \(antecedents[0].noun) or \(antecedents[1].noun). That is, \(myLine.formula.tokenStringHTMLPrettified) must be left of the top level operator (i.e. logical connective) in either \(al1.formula.tokenStringHTMLPrettified) or \(al2.formula.tokenStringHTMLPrettified)
                    """


            }

            return isAntecedentIsFalse

        } else { // second

            let sc = ii.getMySecondChild()
            let a1 = ii.getAntecedentAsTree(
                forAntecedentLineNum: antecedents[0])
            let a2 = ii.getAntecedentAsTree(
                forAntecedentLineNum: antecedents[1])

            let al1 = ii.getAntecedentAsLine(forAntecedentLineNum: antecedents[0]) as! Justified
            let al2 = ii.getAntecedentAsLine(forAntecedentLineNum: antecedents[1]) as! Justified

            let isAntecedentIsFalse = sc == a1 || sc == a2

            if isAntecedentIsFalse {

                checkFunctionMessage = """
                    Your \(jD) requires that line \(myLineNumberAsInt.noun) is the first child element of either line \(antecedents[0].noun) or \(antecedents[1].noun). That is, \(myLine.formula.tokenStringHTMLPrettified) must be right of the top level operator (i.e. logical connective) in either \(al1.formula.tokenStringHTMLPrettified) or \(al2.formula.tokenStringHTMLPrettified)
                    """

            }

            return isAntecedentIsFalse


        }

    }


    private func checkIsTopLevelChild(forParent parent: Tree,
                                      withChild child: Tree)
        -> Bool {

        let children = parent.getChildren()
        for c in children {
            if c == child {
                return true
            } else {
                continue
            }
        }
        return false
    }

    private func checkAreTopLevelChildren(
        forParent parent: Tree,
        withFirstChild child1: Tree,
        withSecondChild child2: Tree) -> Bool {

        if checkIsTopLevelChild(forParent: parent,
                                withChild: child1)
            && checkIsTopLevelChild(forParent: parent,
                                    withChild: child2) {
            return true

        } else {

            return false

        }

    }

    private mutating func checkAntecedentsTooFew() -> Bool {

        let myCount = myLine.antecedents.count
        let arity = myLine.justification.arity

        let aDifference = myCount - arity

        guard aDifference != 0 else {
            return false
        }

        if aDifference < 0 {

            checkFunctionMessage = """
                In your assertion you've supplied \(myCount.adjective) antecedent\(myCount.s), but your \(jD) requires \(arity.adjective).
            """

            return true
        } else {
            return false
        }

    }

    private mutating func checkAntecedentsTooMany() -> Bool {

        let myCount = myLine.antecedents.count
        let arity = myLine.justification.arity

        let aDifference = myCount - arity

        guard aDifference != 0 else {
            return false
        }

        if aDifference > 0 {

            checkFunctionMessage = """
                In your assertion you've supplied  \(myCount.adjective) antecedent\(myCount.s), but your \(jD) requires \(arity.adjective).
                """

            return true
        } else {
            return false
        }

    }

    private mutating func checkAntecedentsComeEarlier() -> Bool {

        for aLineNumber in antecedents {

            if aLineNumber >= myLineNumberAsInt {

                checkFunctionMessage = """

                    Any antecedent must come earlier in the proof than the current line. Your \(jD) is referencing line \(myLineNumberAsInt.noun).

                    """

                return false
            }

        }

        return true
    }

    private mutating func checkAntecedentsHaveDuplicates() -> Bool {

        guard antecedents.count > 1 else {
            return false
        }

        // We will create a set of all antecedents
        // The set must contain only unique elements,
        // so if its size is less than the number of
        // antecedents, it must contain duplication

        var allAntecedents = [Int]()
        var allAntecedentsText = [String]()

        for aLineNumber in antecedents {

            allAntecedents.append(aLineNumber)
            allAntecedentsText.append(aLineNumber.noun)

        }

        let setOfAntecedents = Set(allAntecedents)

        let duplicateCount = allAntecedents.count - setOfAntecedents.count

        guard duplicateCount == 0 else {

            checkFunctionMessage = """

                Antecedents must refer to different lines. Your \(jD) is referencing lines \(allAntecedentsText.commaList()). There \(duplicateCount.isAre) \(duplicateCount.noun) duplicate\(duplicateCount.s).

                """

            return true

        }

            return false

    }

    private mutating func checkAntecedentsProven()
        -> Bool {

        for aLineNumber in antecedents {

            let aLine = proof.getLineFromNumber(aLineNumber)

            guard aLine is Theorem || aLine is Justified else {

                checkFunctionMessage = """
                    Your \(jD) requires that your antecedents be proven. However, you refer here to line \(aLineNumber.noun), which is neither a theorem nor a line with a justification.
                    """

                return false
            }

            if aLine is Theorem {

                let line = aLine as! Theorem

                if line.getProven() == false {

                    let p = Proof(line.userText,
                                  minimalVersion: true)

                    checkFunctionMessage = """
                        Your \(jD) requires that your antecedents be proven. However, you refer here to the theorem on line \(aLineNumber.noun), which is not proven: \(p.htmlVLN)
                        """

                    return false
                }
            }

            if aLine is Justified {
                let line = aLine as! Justified
                if line.getProven() == false {

                    checkFunctionMessage = """
                        Your \(jD) requires that your antecedents be proven. However, you refer here to line \(aLineNumber.noun), which is not proven: \(line.formula.tokenStringHTMLPrettified)
                        """

                    return false
                }
            }

        }

        return true

    }

    // MARK: Untested
    private mutating func checkAntecedentsAreJustified() -> Bool {

        var allLinesJustified = true

        for a in antecedents {
            let aLine = ii.getAntecedentAsLine(forAntecedentLineNum: a)
            if aLine.lineType != .justified {

                checkFunctionMessage = """
                    Your \(jD) requires that your antecedents be lines with justifications. However, you refer to line \(a.noun), which is a \(aLine.lineType.description) line.

                """

                allLinesJustified = false
            }
        }

        return allLinesJustified

    }

    // MARK: Untested
    private mutating func checkAntecedentIsTheorem() -> Bool {

        let tLine = ii.getAntecedentAsLine(forAntecedentLineNum: antecedents[0])
        if tLine.lineType == .theorem {
            return true

        } else {

            checkFunctionMessage = """
                Your \(jD) requires that your antecedent be a theorem line. However, you refer to line \(antecedents[0].noun), which is a \(tLine.lineType.description) line.
            """

            return false

        }

    }


    private mutating func checkHasTopLevelOperator(_ tree: Tree,
                                          _ op: OperatorType) -> Bool {

        let targetOperator = tree.getToken().operatorToken?.description

        guard targetOperator != nil else { return false }

        if targetOperator == op.description {
            return true
        } else {



            return false
        }

    }

    // MARK: Untested
    private mutating func checkMyTopLevelOperator(isOperator op: OperatorType) -> Bool {

        if checkHasTopLevelOperator(ii.getMyTree(), op) {

            return true

        } else {

            let myTLO = ii.getMyTree().getToken().operatorToken

            checkFunctionMessage = """
            Your \(jD) requires that the top level operator (i.e. logical connective) for this line is \(op.description) (i.e. \(op.htmlEntity)). However, the top level operator is \(myTLO?.description ?? "unknown").
            """

            return false
        }

    }

    // MARK: Untested
    private mutating func checkAntecedentTopLevelOperator(
        forAntecedentLineNum antecedent: Int,
        isOperator op: OperatorType) -> Bool {

        if checkHasTopLevelOperator(
            ii.getAntecedentAsTree(forAntecedentLineNum: antecedent),
            op
            ) == true {

            return true

        } else {

            let antTLO = ii.getAntecedentAsTree(forAntecedentLineNum: antecedent).getToken().operatorToken

            checkFunctionMessage = """
                Your \(jD) requires that the top level operator (i.e. logical connective) for line \(antecedent.noun) is \(op.description) (i.e. \(op.htmlEntity)). However, the top level operator is \(antTLO?.description ?? "unknown").
            """

            return false
        }

    }



    private mutating func checkAntecedentIsParent (forAntecedentLineNum antecedent: Int) -> Bool {

        let antecedentTree = ii.getAntecedentAsTree(forAntecedentLineNum: antecedent)

        if checkIsTopLevelChild(forParent: antecedentTree,
                                withChild: ii.getMyTree()) {
            return true

        } else {

            checkFunctionMessage = "Your \(jD) requires that the antecedent at line \(antecedent.noun) has the current line as a child formula (i.e. is left or right of the top level operator in the antecedent)."

            return false

        }

    }

    // MARK: Untested
    private mutating func checkAntecedentIsChild (forAntecedentLineNum antecedent: Int) -> Bool {

        let antecedentTree = ii.getAntecedentAsTree(forAntecedentLineNum:
            antecedent)

        let antecdentLine = ii.getAntecedentAsLine(forAntecedentLineNum: antecedent) as! Justified

        let myTLO = ii.getMyTree().description

        if checkIsTopLevelChild(forParent: ii.getMyTree(),
                                withChild: antecedentTree) {
            return true

        } else {

            checkFunctionMessage = """
                        Your \(jD) requires that line \(antecedents[antecedent].noun) is a child element of line \(myLineNumberAsInt.noun). That is, \(antecdentLine.formula.tokenStringHTMLPrettified) must be to the left or right of the top level operator \(myTLO) (i.e. logical connective) in \(myLine.formula.tokenStringHTMLPrettified)
                    """


            return false

        }

    }

    // MARK: General Checks
    private mutating func checkGeneralConstraintsSatisfied(
        requiresAntecedentsProven: Bool = true)
        -> Bool {

        // The number of antecedents should match the arity
        // of the inference rule
        guard checkAntecedentsTooFew() != true else {
            advise(AdviceInstance.invalidParemeterCountLowForJustification,
                   longDescription: checkFunctionMessage)
            return false
        }

        guard checkAntecedentsTooMany() != true else {
            advise(AdviceInstance.invalidParemeterCountHighForJustification,
                   longDescription: checkFunctionMessage)
            return false
        }

        // Any antecedent must come earlier in the proof
        // than the current line
        guard checkAntecedentsComeEarlier() != false else {
            advise(AdviceInstance.invalidParameterPositionEarly,
            longDescription: checkFunctionMessage)
            return false
        }

        // Multiple antecedents must refer to different lines
        guard checkAntecedentsHaveDuplicates() != true else {
            advise(AdviceInstance.inferenceFailure,
                    longDescription: checkFunctionMessage)
            return false
        }

        // Any antecedent should be proven for most inference
        // rules, but not all
        if checkAntecedentsProven() == false &&
            requiresAntecedentsProven == true {
            advise(AdviceInstance.inferenceRefersToUnprovenLine, longDescription: checkFunctionMessage)
            return false
        }

        return true

    }

    // MARK: Helper functions

    private func negate(_ tree: Tree) -> Tree {

        let negatedTree = tree
        let lNotTree = Tree(Token(operatorType: .lNot))

        lNotTree.add(negatedTree)

        return lNotTree
    }

    func getMyLineAsInt() -> Int {
        return self.myLineNumberAsInt
    }

    func getMyLineAsUUID() -> UUID {
        return self.myLineNumberAsUUID
    }

    func getProof() -> Proof {
        return proof
    }


}
