//
//  Tree.swift
//  Baker Street
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Foundation

// A Tree type, in this basic form, stores a formula
// in a recursive structure where tokenised elements
// have parent/child relationships.
public class Tree: Equatable {

    // Completely equivalent (e.g. 'p' == 'p')
    public static func == (lhs: Tree, rhs: Tree) -> Bool {

        return lhs.token.description ==
            rhs.token.description &&
            lhs.children == rhs.children

    }

    private var token: Token
    private var formulaString: String
    private var children: [Tree] = []

    var text: String {
        return formulaString
    }

    weak var parent: Tree?

    public var description: String {
        return token.description
    }

    public init(_ token: Token, formula: String = "") {
        self.token = token
        self.formulaString = formula
    }

    public func add(_ child: Tree){
        children.append(child)
        child.parent = self
    }

    func addMany(_ children: [Tree]){
        for c in children {
            add(c)
        }
    }

    public func hasChild( _ child: Tree) -> Bool {
        for c in self.children {
            if c == child { return true }
        }
        return false
    }

    func getTreeLines() -> [String] {
        return [self.token.description] +
            self.children.flatMap{$0.getTreeLines()}.map{"    "+$0}
    }

    // The tree in text-graphical format
    func getTreeGraph() -> String {
        let text = getTreeLines().joined(separator: "\n")
        return(text)
    }

    // An array of all tokens in this tree
    func getAsText() -> [String] {

        return [self.token.description] +
            self.children.flatMap{$0.getTreeLines()}.map{$0}
    }

    public func getToken() -> Token {
        return self.token
    }

    // Children are indexed as follows:
    // For infix string: "p OR (q AND r) "
    //
    // Our tree is:
    // OR
    //  AND         <--- self.children[0]
    //      r
    //      q
    //  p           <--- self.children[1]
    //
    // In other words, the linear order of children in the tree
    // itself is the reverse of the linear order of children
    // in the infix expression.
    //
    // The functions getFirstChild() and getSecondChild() use
    // their ordinals in reference to the infix expression. The
    // 'first' child of "p OR (q AND r)" will therefore be "p"

    func getChildren() -> [Tree] {
        return self.children
    }

    public func getFirstChild() -> Tree {
        return getChildren()[1]
    }

    public func getSecondChild() -> Tree {
        return getChildren()[0]
    }


}
