//
//  Baker_StreetTests.swift
//  Baker StreetTests
//
//  Created by Ian Hocking on 23/06/2020.
//  Copyright © 2020 Hoksoft. All rights reserved.
//

import Baker_Street
import XCTest



/// The type `Tree`
class TestTree: XCTestCase {

    var token = [Token]()
    var tree = [Tree]()
    
    override func setUp() {
        super.setUp()
        token = [Token(operand: "p"),
                 Token(operand: "q"),
                 Token(operatorType: .lOr),
                 Token(operand: "true"),
                 Token(operand: "r"),
                 Token(operatorType: .lIf)]

        // Create 'p OR q' tree, stored in self.tree[0]:
        // OR
        //   q  <-- Second child
        //   p  <-- First child

        let t0 = Tree(token[2])
        let t0a = Tree(token[0])
        let t0b = Tree(token[1])
        t0.add(t0a)
        t0.add(t0b)
        tree.append(t0)

        // Create 'r -> true' tree, stored in self.tree[1]:
        // ->
        //   r
        //   true
        let t1 = Tree(token[5])
        let t1a = Tree(token[4])
        let t1b = Tree(token[3])
        t1.add(t1a)
        t1.add(t1b)
        tree.append(t1)

        // Create a third tree identical to the one above
        tree.append(t1)

    }

    func test_treesAreIdentical_withIdenticalTrees_shouldBeTrue() {

        XCTAssertTrue(tree[1] == tree[2])

    }

    func test_treesAreIdentical_withNonIdenticalTrees_shouldBeFalse() {

        XCTAssertFalse(tree[0] == tree[1])

    }

    func test_treeGivenChild_withChild_shouldHaveChild() {

        let childToken = Token(operand: "q")
        let parentToken = Token(tokenType: .empty)

        let TreeChild  = Tree(childToken) // tree "q"
        let TreeParent = Tree(parentToken) // tree ""
        TreeParent.add(TreeChild) // now has child tree "q"
        XCTAssertTrue(TreeParent.hasChild(TreeChild))

    }

    func test_tree_withFirstChild_shouldHaveFirstChild_forTree() {


        let f = Formula("p OR (q AND r)")
        let firstChild = f.tree.getFirstChild()
        XCTAssertEqual(firstChild.description,"p")
    }

    func test_tree_withSecondChild_shouldHaveFirstChild_forTree() {

        let f = Formula("p OR (q AND r)")
        let secondChild = f.tree.getSecondChild()
        XCTAssertEqual(secondChild.description,"AND")

    }


//    test first child and test second child

}
