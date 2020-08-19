//
//  Proof.swift
//  NaturalDeductionP1
//
//  Created by Ian Hocking on 29/05/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Foundation

struct deprecatedProof: Codable {
    var isSolved: Bool          // Proof is complete
    var components: [Component] // List of components, i.e. lines of proof
    
    init() {
        isSolved = false
        components = []
    }
    
    func getFormula() -> String {
        return getComponentTextByID(id: 0)
    }
    
    func getComponentTextByID(id: Int) -> String {
        
        if components.isEmpty {
            return "None"
        }
        
        if let component = components[safe: id] {
            return component.text
        } else {
            return ""
        }
    }
    
    func getComponentJustificationByID(id: Int) -> String {
           
           if components.isEmpty {
               return "None"
           }
           
           if let component = components[safe: id] {
            return component.category.rawValue
           } else {
               return ""
           }
       }
    
    func getComponentCount() -> Int {
        if components.isEmpty {
            return -1
        } else {
            return components.count
        }
    }
    
    func exportJSON() -> String {
        
        let jsonProofData = try! JSONEncoder().encode(self)
        let jsonProofString = String(data: jsonProofData, encoding: .utf8)!
        return jsonProofString // "isSolved":true,"components":[ ...
        
    }
    
    func dumpProof() {
                
        if components.isEmpty {} else {
            print("No components")
            for component in self.components {
                print("Formula: \(self.components[0].text)")
                print("id: \(component.id)")
                print(" component: \(component.text)")
                print(" category: \(component.category)")
                print(" category antecedents: \(component.antecedents)")
            }
        }
    }
}

struct Component: Codable {
    
    enum Category: String, Codable {
        case assumption, proof, subproof, inferenceElimAnd, inferenceElimOr, inferenceElimIff, inferenceElimIf, inferenceElimNot, inferenceIntrAnd, inferenceIntrOr, inferenceIntrIff, inferenceIntrIf, inferenceIntrNot
    }
    
    let id: Int             // Identifier
    var text: String        // e.g. p → q, q → r ⊢ (r → p) ∨ (p → r)
    var isWellFormed: Bool  // Parsed successfully
    var category: Category  // e.g. inferenceElimAnd
    var antecedents: [Int]      // e.g. [2,3]
    
}
