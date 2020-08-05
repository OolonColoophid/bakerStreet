//
//  Comment.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Foundation

public class Comment: BKLine, BKInspectable {

    var identifier = UUID()
    var lineType = LineType.comment
    var inspectableText = ""
    var text = ""
    var scopeLevel: Int


    public init(_ myText: String, atScopeLevel scopeLevel: Int) {

        text = myText

        self.scopeLevel = scopeLevel


        // setInspectionText()

    }

    public func getWindowText() -> String {
        return self.text
    }

    func setLineType() {
        self.lineType = .inactive
    }

    func getLineType() -> LineType {
        return self.lineType
    }

    func setInspectionText() {
        var s = String(scopeLevel)

        s += self.text

        s = s.padding(toLength: 30, withPad: " ", startingAt: 0)

        s += inspectableTextAppend(property: "Type", value: getLineType().description)

        self.inspectableText = s

        return
    }

    func getInspectionText() -> String {
        return self.inspectableText
    }

    func inspectableTextAppend(property: String, value: String) -> String {
        return "\t[ \(property): \(value) ]"
    }

    func getIdentifier() -> UUID {
        return self.identifier
    }

}
