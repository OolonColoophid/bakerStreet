//
//  ExportedProof.swift
//  Baker StreetTests
//
//  Created by ian.user on 11/08/2020.
//  Copyright © 2020 Ian. All rights reserved.
//

import Baker_Street
import XCTest

class ExportedProof: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {

        let p = Proof(
            """
                (p OR q) AND r |- (p AND r) OR (q AND r)
                    (p OR q) AND r                : Assumption (0)
                    (p OR q)                      : AND Elimination (1)
                    r                             : AND Elimination (1)
                    p |- (p AND r) OR (q AND r)
                        p                             : Assumption (4)
                        p AND r                       : AND Introduction (5, 3)
                        (p AND r) OR (q AND r)        : OR Introduction (6)
                    p -> ( (p AND r) OR (q AND r)) : -> Introduction (4)
                    q |- (p AND r) OR (q AND r)
                        q                             : Assumption (9)
                        q AND r                       : AND Introduction (10, 3)
                        (p AND r) OR (q AND r)        : OR Introduction (11)
                    q -> ( (p AND r) OR (q AND r)) : -> Introduction (9)
                (p AND r) OR (q AND r)        : OR Elimination (2, 8, 13)

                """
        )


    }



}
