//
//  DocumentStyler.swift
//  Baker Street
//
//  Created by Ian Hocking on 24/07/2020.
//  Copyright © 2020 Ian. MIT Licence.
//

import Foundation


import Foundation

public struct DocumentStyler: Styling {


    public func style(_ text: String,
                      with attributes: [NSAttributedString.Key : Any])
        -> NSMutableAttributedString {

            let s = Styler(text, with: attributes)
            return s.getFormatted()
    }

    public func styleNSAString(_ text: NSMutableAttributedString,
                               with attributes: [NSAttributedString.Key : Any])
        -> NSMutableAttributedString {

            let s = Styler(text, with: attributes)
            return s.getFormatted()
    }

}
