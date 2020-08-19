//
//  ProtocolsAppearance.swift
//  Baker Street
//
//  Created by Ian Hocking on 30/06/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Foundation

// Can style something
protocol Styling {

    func style(_ text: String,
               with attributes: [NSAttributedString.Key : Any])
        -> NSMutableAttributedString
}
