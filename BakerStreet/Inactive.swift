//
//  Inactive.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Foundation

public class Inactive: BKLine, BKInspectable {

    // BKLine
    var lineType = LineType.inactive
    var scopeLevel: Int
    var userText: String

    var identifier = UUID()
    var inspectableText = ""



    public init(_ text: String, atScopeLevel scopeLevel: Int) {

        self.userText = text
        self.scopeLevel = scopeLevel

        // setInspectionText()

    }

    public func getWindowText() -> String {
        return self.userText
    }

    func setLineType() {
        self.lineType = .inactive
    }

    func getLineType() -> LineType {
        return self.lineType
    }

    func setInspectionText() {

        var s = String(scopeLevel)

        s += "\(self.userText)"

        s = s.padding(toLength: 30, withPad: " ", startingAt: 0)

        s += inspectableTextAppend(property: "Type", value: getLineType().description)

        self.inspectableText = s
    }

    func inspectableTextAppend(property: String, value: String) -> String {
        return "\t[ \(property): \(value) ]"
    }

    func getInspectionText() -> String {
        return self.inspectableText
    }

    func getIdentifier() -> UUID {
        return self.identifier
    }

}
