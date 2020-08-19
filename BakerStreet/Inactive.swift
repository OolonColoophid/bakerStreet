//
//  Inactive.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Foundation

public class Inactive: BKLine {

    // BKLine
    var lineType = LineType.inactive
    var scopeLevel: Int
    var userText: String

    // BKIdentifiable
    var identifier = UUID()

    // BKInspectable
    var inspectableText = ""



    public init(_ text: String, atScopeLevel scopeLevel: Int) {

        self.userText = text
        self.scopeLevel = scopeLevel

        if BKPrefConstants.debugMode == true { setInspectionText() }

    }

    public func getWindowText() -> String {
        return self.userText
    }


    func setInspectionText() {

        var s = String(scopeLevel)

        s += "\(self.userText)"

        s = s.padding(toLength: 30, withPad: " ", startingAt: 0)

        s += inspectableTextAppend(property: "Type", value: lineType.description)

        self.inspectableText = s
    }

    func inspectableTextAppend(property: String, value: String) -> String {
        return "\t[ \(property): \(value) ]"
    }

    func getInspectionText() -> String {
        return self.inspectableText
    }



}
