//
//  Comment.swift
//  Baker Street
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Foundation

public class Comment: BKLine, BKInspectable {

    // BKLine
    var lineType = LineType.comment
    var scopeLevel: Int
    var userText: String

    // BKIdentifiable
    var identifier = UUID()

    // BKInspectable
    var inspectableText = ""



    public init(_ myText: String, atScopeLevel scopeLevel: Int) {

        userText = myText

        self.scopeLevel = scopeLevel

        if BKPrefConstants.debugMode == true { setInspectionText() }

    }

    public func getWindowText() -> String {
        return self.userText
    }

    func setInspectionText() {
        var s = String(scopeLevel)

        s += self.userText

        s = s.padding(toLength: 30, withPad: " ", startingAt: 0)

        s += inspectableTextAppend(property: "Type", value: lineType.description)

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
