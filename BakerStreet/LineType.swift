//
//  LineType.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Foundation

public enum LineType {

    case theorem
    case justified
    case comment
    case inactive

    public var description: String {
        switch self {
        case .theorem:
            return "theorem"
        case .justified:
            return "justified"
        case .comment:
            return "comment"
        case .inactive:
            return "inactive"
        }
    }
}
