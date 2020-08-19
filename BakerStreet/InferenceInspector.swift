//
//  Inference.swift
//
//  This is a suite of useful functions for analysing aspects of
//  a proof (e.g. what is the formula tree for a given line)?
//
//  Created by Ian Hocking on 02/07/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Foundation

// Will typically be used by InferenceController

// This struct provides inference processing functions to support
// the InferenceController

public struct InferenceInspector {

    var proof: Proof

    private var myLine: Justified
    private var myLineNumber: Int

    private var parentThereom: Theorem
    private var antecedents: [Int]

    init (line: Justified,
          proof: Proof) {

        self.proof = proof
        self.myLine = line
        self.parentThereom = line.getParentTheorem()
        self.myLineNumber = proof.getLineNumberFromIdentifier(
            line.identifier)
        self.antecedents = myLine.antecedents

    }

    func getAntecedentAsLine(forAntecedentLineNum antecedentNum: Int)
        -> BKLine {

            let lineNumber = antecedentNum

            return self.proof.getLineFromNumber(lineNumber)

    }

    func getAntecedentLineAsTheorem(forLine antecedent: BKLine)
        -> Theorem {

            return antecedent as! Theorem

    }

    func getAntecedentLineAsJustified(forLine antecedent: BKLine)
        -> Justified {

            return antecedent as! Justified

    }

    func getAntecedentAsTree(
        forAntecedentLineNum antecedentNum: Int) -> Tree {

      let line = getAntecedentAsLine(forAntecedentLineNum: antecedentNum)

        if line.lineType == .theorem {

            let tLine = line as! Theorem

            return tLine.rhsFormula.tree

        } else {

            let jLine = line as! Justified

            return jLine.formula.tree

        }

    }

    func getMyTree() -> Tree {
        return self.myLine.formula.tree
    }

    func getMyParent() -> Theorem {
        return self.parentThereom
    }

    func getMyTopLevelTokenAsString() -> String {
        return getMyTree()
            .getToken()
            .self.description
    }

    func getMyTopLevelToken() -> Token {
        return getMyTree()
            .getToken()
    }

    func getAntecedentTopLevelElementAsString(
        forAntecedentLineNum antecedentNum: Int) -> String {

        return getAntecedentAsTree(
            forAntecedentLineNum: antecedentNum)
            .getToken()
            .self.description

    }

    func getAntecedentTopLevelElement(
        forAntecedentLineNum antecedentNum: Int) -> Token {

        return getAntecedentAsTree(
            forAntecedentLineNum: antecedentNum)
            .getToken()

    }

    func getAntecedentFirstChild(
        forAntecedentLineNum line: Int)
        -> Tree {
            return getAntecedentAsTree(forAntecedentLineNum: line).getFirstChild()
    }

    func getAntecedentSecondChild(
        forAntecedentLineNum line: Int)
        -> Tree {
            return getAntecedentAsTree(forAntecedentLineNum: line).getSecondChild()
    }

    func getMyFirstChild() -> Tree {
        return getMyTree().getFirstChild()
    }

    func getMySecondChild() -> Tree {
        return getMyTree().getSecondChild()
    }

    func getOperatorAsString(_ op: OperatorType) -> String {
        return OperatorToken(operatorType: op).description
    }

    func getTheoremRHS(forAntecedentLineNum line: Int) -> Formula {
        let antecedentLine = getAntecedentAsLine(forAntecedentLineNum: line)

        let tLine = antecedentLine as! Theorem

        return tLine.rhsFormula
    }

    func getTheoremLHS(forAntecedentLineNum line: Int) -> [Formula] {

        let antecedentLine = getAntecedentAsLine(forAntecedentLineNum: line)

        let tLine = antecedentLine as! Theorem

        return tLine.lhsFormula

    }

    func getAntecedentTreeGraph(forAntecedentLineNum line: Int) -> String {

        return getAntecedentAsTree(forAntecedentLineNum: line).getTreeGraph()

    }


}
