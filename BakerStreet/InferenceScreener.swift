//
//  InferenceScreener.swift
//  Baker Street
//
//  Created by ian.user on 02/07/2020.
//  Copyright © 2020 Ian. All rights reserved.
//

import Foundation

// Will typically be used by InferenceController

// This struct provides inference checking functions to support
// the InferenceController

public struct InferenceScreener {

    private var proof: Proof
    private var currentLine: Justified
    private var currentLineNumber: Int

    private var parentThereom: Theorem
    private var antecedents: [Int]

    // Support functions for processing inferences
    private var ii: InferenceInspector

    init (line: Justified,
          proof: Proof) {

        self.proof = proof
        self.currentLine = line
        self.parentThereom = line.getParentTheorem()
        self.currentLineNumber = proof.getLineNumberFromIdentifier(
            line.getIdentifier())
        self.antecedents = currentLine.getAntecedents()

        self.ii = InferenceInspector(line: line, proof: proof)

    }

       func checkIsTopLevelChild(forParent parent: Tree,
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

        func checkAreTopLevelChildren(
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

        func checkAntecedentsTooFew() -> Bool {

            let aDifference =
                currentLine.getAntecedents().count -
                    currentLine.justification.arity

            guard aDifference != 0 else {
                return false
            }

            if aDifference < 0 {
                return true
            } else {
                return false
            }

        }

        func checkAntecedentsTooMany() -> Bool {

            let aDifference =
                currentLine.getAntecedents().count -
                    currentLine.justification.arity

            guard aDifference != 0 else {
                return false
            }

            if aDifference > 0 {
                return true
            } else {
                return false
            }

        }

        func checkAntecedentsComeEarlier() -> Bool {

            for aLineNumber in antecedents {

                if aLineNumber >= currentLineNumber {
                    return false
                }

            }

            return true
        }

        func checkAntecedentsHaveDuplicates() -> Bool {

            guard antecedents.count > 1 else {
                return false
            }

            // We will create a set of all antecedents
            // The set must contain only unique elements,
            // so if its size is less than the number of
            // antecedents, it must contain duplication

            var allAntecedents = [Int]()

            for aLineNumber in antecedents {

                allAntecedents.append(aLineNumber)

            }

            let setOfAntecedents = Set(allAntecedents)

            if setOfAntecedents.count < allAntecedents.count {
                return true
            } else {
                return false
            }

        }

        func checkAntecedentProven()
            -> Bool {

                for aLineNumber in antecedents {

                    let aLine = proof.getLineFromNumber(aLineNumber)

                    guard aLine is Theorem || aLine is Justified else {
                        return false
                    }

                    if aLine is Theorem {

                        let line = aLine as! Theorem

                        if line.getProven() == false {
                            return false
                        }
                    }

                    if aLine is Justified {
                        let line = aLine as! Justified
                        if line.getProven() == false {
                            return false
                        }
                    }

                }

                return true

        }

        func checkAntecedentsAreJustified() -> Bool {

            var allLinesJustified = true

            for a in antecedents {
                let aLine = ii.getAntecedentAsLine(forAntecedentLineNum: a)
                if aLine.lineType != .justified {
                    allLinesJustified = false
                }
            }

            return allLinesJustified

        }

        func checkAntecedentIsTheorem() -> Bool {

            let tLine = ii.getAntecedentAsLine(forAntecedentLineNum: antecedents[0])
            if tLine.lineType == .theorem {
                return true

            } else {

                return false

            }

        }


        func checkHasTopLevelOperator(_ tree: Tree, _ op: OperatorType) -> Bool {

            if tree.getToken().operatorToken?.description == op.description {
                return true
            } else {
                return false
            }

        }

        func checkMyTopLevelOperator(isOperator op: OperatorType) -> Bool {

            if checkHasTopLevelOperator(ii.getMyTree(), op) {

                return true

            } else {

                return false
            }

        }

        func checkAntecedentTopLevelOperator(
            forAntecedentLineNum antecedent: Int,
            isOperator op: OperatorType) -> Bool {

            if checkHasTopLevelOperator(
                ii.getAntecedentAsTree(forAntecedentLineNum: antecedent),
                op
                ) == true {

                return true

            } else {

                return false
            }

        }

        func checkAntecedentIsParent (forAntecedentLineNum antecedent: Int) -> Bool {

            let antecedentTree = ii.getAntecedentAsTree(forAntecedentLineNum: antecedent)

            if checkIsTopLevelChild(forParent: antecedentTree,
                                    withChild: ii.getMyTree()) {
                return true

            } else {

                return false

            }

        }

        func checkAntecedentIsChild (forAntecedentLineNum antecedent: Int) -> Bool {

            let antecedentTree = ii.getAntecedentAsTree(forAntecedentLineNum:
                antecedent)

            if checkIsTopLevelChild(forParent: ii.getMyTree(),
                                    withChild: antecedentTree) {
                return true

            } else {

                return false

            }

        }

        func checkGeneralConstraintsSatisfied(
            isInference: Bool = true
        ) -> Bool {

            // The number of antecedents should match the arity
            // of the inference rule
            if checkAntecedentsTooFew() == true {
                advise(AdviceType.invalidParemeterCountLowForJustification,
                       longDescription: "Placeholder: Too few antecedents")
                return false
            }

            if checkAntecedentsTooMany() == true {
                advise(AdviceType.invalidParemeterCountHighForJustification,
                       longDescription: "Placeholder: Too many antecedents")
                return false
            }

            // Any antecedent must come earlier in the proof
            // than the current line
            if checkAntecedentsComeEarlier() == false {
                advise(AdviceType.invalidParameterPositionEarly,
                       longDescription: "Placeholder: any antecedent must come earlier in the proof than the current line")
                return false
            }

            // Multiple antecedents must refer to different lines
            if checkAntecedentsHaveDuplicates() == true {
                advise(AdviceType.inferenceFailure,
                       longDescription: "Placeholder: Multiple antecedents must refer to different lines")
                return false
            }

            // Any antecedent should be proven for all inference
            // rules, but not assumptions
            if checkAntecedentProven() == false && isInference == true {
                advise(AdviceType.inferenceRefersToUnprovenLine)
                return false
            }

            return true

        }

}

