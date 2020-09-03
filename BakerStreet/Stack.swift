//
//  Stack.swift
//  Baker Street
//
//  Created by Ian Hocking on 20/06/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Foundation

/// A generic Stack type
public struct Stack<T> {
    fileprivate var array = [T]()

    public init() { }

    public var isEmpty: Bool {
        return array.isEmpty
    }

    public var count: Int {
        return array.count
    }

    public mutating func push(_ element: T) {
        array.append(element)
    }

    public mutating func pop() -> T? {
        return array.popLast()
    }

    /// Returns the topmost element without popping
    public var top: T? {
        return array.last
    }

    /// Returns the penultimate element without popping
    public var penultimate: T? {

        let a = array.dropLast()
        return a.last
    }

    public var description: String {
        return array.description
    }

}
