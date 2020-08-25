//
//  errorDescriptions.swift
//  Baker Street
//
//  Created by Ian Hocking on 01/07/2020.
//  Copyright © 2020 Ian Hocking. MIT Licence.
//

import Cocoa

import Foundation

// MARK: Proof Texts
public enum Examples {

    case tutorial
    case subProof

    case andElimination
    case andIntroduction
    case orIntroduction
    case orElimination
    case ifIntroduction
    case iffIntroduction
    case iffElimination
    case ifElimination
    case ifIntroduction3
    case ifIntroduction4
    case ifIntroduction5
    case notElimination
    case notIntroduction
    case falseElimination

    var text: String {
        switch self {

            case .tutorial:
            return """
            // Baker Street Tutorial
            //
            // Welcome! Baker Street is designed to help you find natural
            //   deduction proofs in propositional logic

            // Access this page at any time from the Help menu

            // This line is a comment (note that it starts //)

            // Let’s begin with an overall proof statement. The first theorem
            //   that appears in a file will be the overall proof statement.
            //   Ours is on line 23, below

            // The proof statement is written using Baker Street markdown. This
            //   avoids having to write special characters like the syntactic
            //   turnstile. Click 'Markdown' in the toolbar or the menu to see all
            //   markdown commands.

            // The green dot at the bottom of this window tells us that our
            //   proof is correct. Each correct theorem receives a green tick

            // Let's try an example.
            //   We'll create a proof for:
            p AND q |- q AND p

            // This line is indented because we’re now in the scope of the above theorem.

            // Let’s write our first assertion, for p and q:
            p AND q : Assumption (23)

            // As we continue, note that the formula p is on the left of the line:
            p : AND Elimination (28)

            // To get q, we use the AND Elimination justification:
            q : AND Elimination (28)

            // Any justification needs to have have its antecedent lines included.
            q AND p : AND Introduction (31, 34)

            // Some things to try:
            // - Validate the proof using the toolbar button or the menu
            //  - Nothing should change yet! The proof is just the same
            //  - Click 'Preview' in the toolbar to see a styled proof
            //    - You can export and copy to the clipboard in different formats
            // - Now change the proof:
            //  - Make a formula syntactically incorrect
            //  - You’ll see a warning triangle in the advice pane
            //    - The advice will always point to a line number
            //    - Sometimes, there’s a hyperlink ‘more’ with tailored help
            //
            // Completion:
            // - You can use the toolbar or the menu to insert logical
            //     operators and justifications
            //
            // Extra help:
            // - In the Help menu, you'll see example proofs for each
            //     inference rule
            // - In the toolbar, and in the Help menu, can also see:
            //   - 'Rules Overview' for a summary of inference rules
            //   - 'Rules in Full' for a more detailed view
            //   - 'Definitions' for important terms
            // - Most common commands, like Validate, have keyboard shortcuts

            """

            case .andElimination:
                return """
            // Example: AND Elimination, AND Introduction
            // From UKC C0884 Logic and Logic Programming handout 2020 p 14

            p AND (q AND r) |- (p AND q) AND r

            p AND (q AND r)                          : Assumption (3)
            p                                   : AND Elimination (5)
            q AND r                             : AND Elimination (5)
            q                                   : AND Elimination (7)
            r                                   : AND Elimination (7)
            p AND q                         : AND Introduction (6, 8)
            (p AND q) AND r                : AND Introduction (10, 9)

            """

            case .andIntroduction:
                return  """
            // Example: AND Elimination, AND Introduction
            // From UKC C0884 Logic and Logic Programming handout 2020 p 14

            p AND q |- q AND p

            p AND q : Assumption (3)
            q : AND Elimination (5)
            p : AND Elimination (5)
            q and p: AND Introduction (6, 7)

            """

            case .orIntroduction:
                return  """
            // Example: AND Elimination, OR Introduction, AND Introduction
            // From UKC C0884 Logic and Logic Programming handout 2020 p 15

            p AND q |- p AND (r OR q)

            p AND q                                  : Assumption (3)
            p                                   : AND Elimination (5)
            q                                   : AND Elimination (5)
            r OR q                              : OR Introduction (7)
            p AND (r OR q)                  : AND Introduction (6, 8)
            """

            case .orElimination:
                return """
            // Example: OR Elimination, OR Introduction
            // From UKC C0884 Logic and Logic Programming handout 2020 p 15

            p OR (q AND r), p -> s, (q AND r) -> s |- s OR p

            p OR (q AND r)                           : Assumption (3)
            p -> s                                   : Assumption (3)
            (q AND r) -> s                           : Assumption (3)
            s                              : OR Elimination (5, 6, 7)
            s OR p                              : OR Introduction (8)
            """

            case .ifIntroduction:
                return """
            // Example: IF Elimination, AND Elimination, IF Introduction
            // From UKC C0884 Logic and Logic Pogramming handout 2020 p 17

            p -> (q AND r) |- p -> q
            p -> (q AND r)                            : Assumption (3)
            p |- q
            p                                     : Assumption (5)
            q AND r                        : -> Elimination (4, 6)
            q                                : AND Elimination (7)
            p -> q                               : -> Introduction (5)

            """

            case .iffIntroduction, .iffElimination:
                return """
            // Example: IFF Elimination, IFF Introduction
            // From UKC C0884 Logic and Logic Pogramming handout 2020 p 16

            p <-> q |- q <-> p
            p <-> q                                    : Assumption (3)
            p -> q                                : <-> Elimination (4)
            q -> p                                : <-> Elimination (4)
            q <-> p                           : <-> Introduction (5, 6)

            """

            case .ifElimination:
                return """
            // Example: AND Elimination, IF Elimination, AND Introduction
            // From UKC C0884 Logic and Logic Pogramming handout 2020 p 16

            p AND q, p -> r |- r AND q
            p AND q                                    : Assumption (3)
            p -> r                                     : Assumption (3)
            p                                     : AND Elimination (4)
            q                                     : AND Elimination (4)
            r                                   : -> Elimination (5, 6)
            r AND q                           : AND Introduction (8, 7)

            """

            case .subProof:
                return """
            // Example: Subproof
            // From UKC C0884 Logic and Logic Pogramming handout 2020 p 17

            p -> (q AND r) |- p -> q
            p -> (q AND r)                            : Assumption (3)
            p |- q
            p                                     : Assumption (5)
            q AND r                        : -> Elimination (4, 6)
            q                                : AND Elimination (7)
            p -> q                               : -> Introduction (5)


            """

            case .ifIntroduction3:
                return """
            // Example: IF Elimination, OR Introduction, IF Introduction
            // From UKC C0884 Logic and Logic Pogramming handout 2020 p 18

            p -> q |- p -> (q OR r)
            p -> q                                    : Assumption (3)
            p |- q OR r
            p                                     : Assumption (5)
            q                              : -> Elimination (4, 6)
            q OR r                           : OR Introduction (7)
            p -> (q OR r)                        : -> Introduction (5)


            """

            case .ifIntroduction4:
                return """
            // Example: IF Elimination, IF Introduction, IF Introduction
            // From UKC C0884 Logic and Logic Pogramming handout 2020 p 18

            p -> q |- (q -> r) -> (p -> r)
            p -> q                                    : Assumption (3)
            q -> r |- p -> r
            q -> r                                : Assumption (5)
            p |- r
            p                                 : Assumption (7)
            q                          : -> Elimination (4, 8)
            r                          : -> Elimination (6, 9)
            p -> r                           : -> Introduction (7)
            (q -> r) -> (p -> r)                 : -> Introduction (5)


            """

            case .ifIntroduction5:
                return """
            // Example: AND Elimination, IF Elimination, IF Introduction
            // From UKC C0884 Logic and Logic Pogramming handout 2020 p 18

            p -> (q -> r) |- (p AND q) -> r
            p -> (q -> r)                             : Assumption (3)
            p AND q |- r
            p AND q                               : Assumption (5)
            p                                : AND Elimination (6)
            q -> r                         : -> Elimination (4, 7)
            q                                : AND Elimination (6)
            r                              : -> Elimination (8, 9)
            (p AND q) -> r                       : -> Introduction (5)


            """

            case .notElimination:
                return """
            // Example: AND Introduction, NOT Elimination
            // From UKC C0884 Logic and Logic Pogramming handout 2020 p 19

            ~~p |- p
            ~~p                                       : Assumption (3)
            ~p |- ~p AND ~~p
            ~p                                    : Assumption (5)
            ~p AND ~~p                   : AND Introduction (6, 4)
            p                                      : ~ Elimination (5)


            """

            case .notIntroduction:
                return """
            // Example: OR Introduction, AND Introduction, NOT Introduction,
            //          IF Introduction
            // - One half of de Morgan's Laws
            // From UKC C0884 Logic and Logic Pogramming handout 2020 p 19

            |- ~(p OR q) -> ~p AND ~q
            ~(p OR q) |- ~p AND ~q
            ~(p OR q) : Assumption (6)
            p |- (p OR q) AND ~(p OR q)
            p : Assumption (8)
            p OR q : OR Introduction (9)
            (p OR q) AND ~(p OR q) : AND Introduction (10, 7)
            ~p : ~ Introduction (8)
            q |- (p OR q) AND ~(p OR q)
            q : Assumption (13)
            p OR q : OR Introduction (14)
            (p OR q) AND ~(p OR q) : AND Introduction (15, 7)
            ~q : ~ Introduction (13)
            ~p AND ~q : AND Introduction (12, 17)
            ~(p OR q) -> ~p AND ~q : -> Introduction (6)



            """

            case .falseElimination:
                return """
            // Example: False Elimination
            // From UKC C0884 Logic and Logic Pogramming handout 2020 p 20

            |- false -> p
            false |- p
            false                                              : Assumption (4)
            p                                           : false Elimination (5)
            false -> p                                    : -> Introduction (4)

            """

        }
    }

}

// MARK: Proofs

public enum ExampleProofs {

    public static var simpleProof: Proof {

        let exampleProof = Examples.andElimination

        let p = Proof(exampleProof.text,isPedagogic: true)

        return p

    }

    public static var orIntroductionProof: Proof {

        let exampleProof = Examples.orIntroduction

        let p = Proof(exampleProof.text,isPedagogic: true)

        return p

    }

    public static var orEliminationProof: Proof {

        let exampleProof = Examples.orElimination

        let p = Proof(exampleProof.text,isPedagogic: true)

        return p

    }

    public static var ifIntroductionProof: Proof {

        let exampleProof = Examples.ifIntroduction

        let p = Proof(exampleProof.text,isPedagogic: true)

        return p

    }

    public static var iffIntroductionProof: Proof {

        let exampleProof = Examples.iffIntroduction

        let p = Proof(exampleProof.text,isPedagogic: true)

        return p

    }

    public static var ifEliminationProof: Proof {

        let exampleProof = Examples.ifElimination

        let p = Proof(exampleProof.text,isPedagogic: true)

        return p

    }

    public static var subProofProof: Proof {

        let exampleProof = Examples.subProof

        let p = Proof(exampleProof.text,isPedagogic: true)

        return p

    }

    public static var ifIntroduction3Proof: Proof {

        let exampleProof = Examples.ifIntroduction3

        let p = Proof(exampleProof.text,isPedagogic: true)

        return p

    }

    public static var ifIntroduction4Proof: Proof {

        let exampleProof = Examples.ifIntroduction4

        let p = Proof(exampleProof.text,isPedagogic: true)

        return p

    }

    public static var ifIntroduction5Proof: Proof {

        let exampleProof = Examples.ifIntroduction5

        let p = Proof(exampleProof.text,isPedagogic: true)

        return p

    }

    public static var notEliminationProof: Proof {

        let exampleProof = Examples.notElimination

        let p = Proof(exampleProof.text,isPedagogic: true)

      return p

    }

    public static var notIntroductionProof: Proof {

        let exampleProof = Examples.notIntroduction

        let p = Proof(exampleProof.text,isPedagogic: true)

        return p

    }

    public static var falseEliminationProof: Proof {

        let exampleProof = Examples.falseElimination

        let p = Proof(exampleProof.text,isPedagogic: true)

        return p

    }

}

// MARK: Document Information
// This contains the information that appears in the panels
// Markdown, Definitions, and Rules
enum DocumentContent {

    enum markdown {

        static var windowTitle: String {
            return "Baker Street Markdown Commands"
        }

        static var body: String {

            let lAnd = OperatorType.lAnd.htmlEntity
            let lOr = OperatorType.lOr.htmlEntity
            let lNot = OperatorType.lNot.htmlEntity
            let lIf = OperatorType.lIf.htmlEntity
            let lIff = OperatorType.lIff.htmlEntity
            let ts = MetaType.turnStile.htmlEntity

            // Add styling
            let style = DocumentStyles.baseStyle

            // Header text coloring
            let hColor = BKColors.auburn.color.hexString

            // Line coloring
            let lColor = BKColors.deepSpaceSparkle.color.hexString


            let table = """

            <table style = "font-size: 1em; width: 100%; padding: 1em;">
            <thead style = "text-align: left;">

            <tr>

            <th style = "padding: 0.5em; color: \(hColor)">
            Markdown
            </th>

            <th style = "padding: 0.5em; color: \(hColor)">
            Meaning
            </th>

            <th style = "padding: 0.5em; color: \(hColor)">
            Example
            </th>

            <th style = "padding: 0.5em; color: \(hColor)">
            Renders
            </th>

            </tr>

            </thead>

            <tbody>
            <tr><td style="border-top:1px solid \(lColor);" colspan="4"></td></tr>

            <tr  >

            <td style = "padding: 0.5em;">
            AND
            </td>


            <td style = "padding: 0.5em;">
            Logical AND
            </td>


            <td style = "padding: 0.5em;">
            p AND q
            </td>


            <td style = "padding: 0.5em;">
            <em>p</em> \(lAnd) <em>q</em>
            </td>


            </tr>

            <tr>

            <td style = "padding: 0.5em;">
            OR
            </td>


            <td style = "padding: 0.5em;">
            Logical OR
            </td>


            <td style = "padding: 0.5em;">
            p OR q
            </td>


            <td style = "padding: 0.5em;">
            <em>p</em> \(lOr) <em>q</em>
            </td>


            </tr>


            <tr>

            <td style = "padding: 0.5em;">
            NOT
            </td>


            <td style = "padding: 0.5em;">
            Logical NOT
            </td>


            <td style = "padding: 0.5em;">
            ~p
            </td>


            <td style = "padding: 0.5em;">
            \(lNot) <em>p</em>
            </td>


            </tr>

            <tr>

            <td style = "padding: 0.5em;">
            IF
            </td>


            <td style = "padding: 0.5em;">
            Logical IF
            </td>


            <td style = "padding: 0.5em;">
            p -> q
            </td>


            <td style = "padding: 0.5em;">
            <em>p</em> \(lIf) <em>q</em>
            </td>

            </tr>


            <tr>

            <td style = "padding: 0.5em;">
            IFF
            </td>


            <td style = "padding: 0.5em;">
            Logical bi-dir IF
            </td>


            <td style = "padding: 0.5em;">
            p <-> q
            </td>


            <td style = "padding: 0.5em;">
            <em>p</em> \(lIff) <em>q</em>
            </td>


            </tr>

            <tr>

            <td style = "padding: 0.5em;">
            true
            </td>


            <td style = "padding: 0.5em;">
            Constant <em>true</em>
            </td>


            <td style = "padding: 0.5em;">
            true
            </td>


            <td style = "padding: 0.5em;">
            <em>true</em>
            </td>


            </tr>

            <tr>

            <td style = "padding: 0.5em;">
            false
            </td>


            <td style = "padding: 0.5em;">
            Constant <em>false</em>
            </td>


            <td style = "padding: 0.5em;">
            false
            </td>


            <td style = "padding: 0.5em;">
            <em>false</em>
            </td>


            </tr>

            <tr>

            <td style = "padding: 0.5em;">
            <em>Any lower case letter</em>
            </td>


            <td style = "padding: 0.5em;">
            Variable
            </td>


            <td style = "padding: 0.5em;">
            p
            </td>


            <td style = "padding: 0.5em;">
            <em>p</em>
            </td>

            </tr>

            <tr>

            <td style = "padding: 0.5em;">
            |-
            </td>

            <td style = "padding: 0.5em;">
            Syntactic turnstile
            </td>

            <td style = "padding: 0.5em;">
            p AND q |- q AND p
            </td>

            <td style = "padding: 0.5em;">
            <em>p</em> \(lAnd) <em>q</em> \(ts) <em>q</em> \(lAnd) <em>p</em>
            </td>


            </tr>

            <tr>

            <td style = "padding: 0.5em;">
            (
            </td>


            <td style = "padding: 0.5em;">
            Open parenthesis
            </td>

            <td style = "padding: 0.5em;">
            ~(p AND q)
            </td>

            <td style = "padding: 0.5em;">
            \(lNot) (<em>p</em> \(lAnd) <em>q</em>)
            </td>

            </tr>


            <tr>

            <td style = "padding: 0.5em;">
            )
            </td>


            <td style = "padding: 0.5em;">
            Close parenthesis
            </td>

            <td style = "padding: 0.5em;">
            (p OR q)
            </td>

            <td style = "padding: 0.5em;">
            (<em>p</em> \(lOr) <em>q</em>)
            </td>

            </tr>


            <tr>

            <td style = "padding: 0.5em;">
            :
            </td>


            <td style = "padding: 0.5em;">
            <em>Introduce justification</em>
            </td>


            <td style = "padding: 0.5em;">
            : OR Introduction (2)
            </td>


            <td style = "padding: 0.5em;">
            : OR Introduction (2)
            </td>


            </tr>


            </tbody>

            </table>
            """



            return style + table

        }
    }

    enum definitions {


        static var windowTitle: String {
            return "Baker Street Definitions"
        }



        static var body: String {

            // Add styling
            let style = DocumentStyles.baseStyle

            // Header text coloring
            let hColor =  BKColors.auburn.color.hexString

            // Contents of the definitions
            let definitions = HtmlDefinitions.allCases.sorted()

            // Our function to produce a definition
            func makeDefinition(for definition: HtmlDefinitions) -> String {

                let heading = definition.text.toUpperFirstLetter.w(
                    "h2", withAttr: """
                    style = "color: \(hColor);"
                    """
                )

                let explanation = definition.explanation.p

                return heading + explanation
            }

            let body = definitions.reduce("") {
                x, y in x + makeDefinition(for: y) }

            return style + body

        }

    }

    enum rules {

        static var windowTitle: String {
            return "Baker Street Rules"
        }

        static var body: String {

            // Add styling
            let style = DocumentStyles.baseStyle

            // Header text coloring
            let hColor = BKColors.deepSpaceSparkle.color.hexString

            // Contents of the rules
            let rules = Justification.allCases.sorted(by: <)

            // Our function to produce a rule
            func makeRule(for rule: Justification) -> String {

                var inferenceText = ""

                let heading = rule.description.w(
                    "h2", withAttr: """
                    style = "color: \(hColor);"
                    """
                )

                inferenceText += ("Given: " + rule.antecedents).p
                    + ("We can prove: " + rule.consequent).p

                // Some rules have alternative antecedents, which we
                // can show
                if rule.alternativeAntecedents != "" {
                    inferenceText += ("Alternatively, given: " + rule.alternativeAntecedents).p
                        + ("We can prove: " + rule.alternativeConsequents).p
                }

                // If we have a stored example, show it here
                if rule.example != "" {
                    inferenceText += "For example, see below (\(rule.htmlEntityShortDescription)):"
                    inferenceText += rule.example

                }

                return heading + inferenceText

            }

            let body = rules.filter {
                ($0 != .empty) &&             // ignore the 'empty' justification
                    ($0 != .assumption)       // ignore 'assumption'
            }.reduce("") {
                x, y in x + makeRule(for: y)
            }

            return style + body

        }

    }
}




    // MARK: Document Styles

    enum DocumentStyles {

        static var baseStyle: String {

            let tColor = BKColors.rosewood.color.hexString
            let bColor = NSColor.textColor.hexString
            let fontSize = UserPrefVariables.globalFont

            // WARNING: Table font cannot be set as a style in the header
            // This has been set as 1em (i.e. relative to body) in
            // the string extension (currently .t) that creates tables

            let s =
            """
            <style>

            body {
            font-family: '-apple-system', 'HelveticaNeue';
            font-size: \(fontSize);
            color: \(bColor)
            }

            h1, h2, h3, h4, h5, h6 {
            font-weight: bold;
            }

            h1 {
            font-size: 2em;
            }

            h2 {
            font-size: 1.2em;
            }

            h3 {
            font-size: 1em;


            .left {
            text-align: left;
            }

            #centered {
            text-align: center;
            }

            table {
            width: 40%;
            }

            td {
            padding: 4em;
            }

            thead {
            text-align: center;
            }

            .header {
            border-bottom: 1px solid \(tColor);
            }

            .inferenceHeader {
            text-decoration: underline;
            }

            .number {
            border-right: 1px solid;
            text-align: right;
            }

            </style>
            """

            return s

        }

    }

    // MARK: Advice Descriptions

    enum HtmlLongDesc {

        static var theoremNotProven: String {

            let s = "A theorem is proven when each assertion in its scope is proven. Right now, one or more of the assertions in this scope are not proven.".p

            return s.asStyledHTML()

        }

        static var assumptionMustReferToParentTheorem: String {

            let s = "An assumption needs to be a formula present in the left hand side of a theorem, and that theorem needs to be the parent theorem of this part of the proof.".p

            return s.asStyledHTML()
        }



    }

    // MARK: Definitions
    // CaseIterable allows us to iterate over cases
    enum HtmlDefinitions: CaseIterable, Hashable, Comparable {
        static func < (lhs: HtmlDefinitions, rhs: HtmlDefinitions) -> Bool {

            var a = [String]()
            a.append(lhs.text)
            a.append(rhs.text)
            a.sort()

            return a[0] == lhs.text
        }


        case proof
        case theorem
        case entailment
        case antecedent
        case justification
        case assertion
        case subproof
        case scope
        case formula
        case assumption
        case inference
        case turnstile

        var text: String {
            switch self {
                case .proof:
                    return "proof"
                case .theorem:
                    return "theorem"
                case .entailment:
                    return "entailment"
                case .antecedent:
                    return "antecedent"
                case .justification:
                    return "justification"
                case .assertion:
                    return "assertion"
                case .subproof:
                    return "subproof"
                case .scope:
                    return "scope"
                case .formula:
                    return "formula"
                case .assumption:
                    return "assumption"
                case .inference:
                    return "inference"
                case .turnstile:
                    return "turnstile"
            }

        }

        var explanation: String {

            let ts = " " + MetaType.turnStile.description + " "

            switch self {

                case .proof:

                    let tP = ExampleProofs.notEliminationProof
                    let s = "A structured set of supporting axioms, assumptions, or inference rules. In the proof below, our axiom (overall proof statement) is the caption for the table, which is followed by an assumption and several inference rules." +
                        tP.htmlVLN

                    return s

                case .theorem:

                    let tP = Proof("p AND q |- q AND p", isPedagogic: true)
                    let lhs = "p AND q".formulaToHTML
                    let rhs = "q AND p".formulaToHTML
                    let t = tP.htmlVLN

                    let s = "A statement of the form 'Given one formula or formulae, we can prove another formula'. For example, we might wish to claim that, given " +
                        lhs +
                        " we can claim " +
                        rhs + ". We would write it like this:"
                        + t

                    return s

                case .entailment:

                    let proof = ExampleProofs.subProofProof
                    let proofHTML = proof.htmlVLN
                    let lhs = "(p -> (q AND r)) AND p".formulaToHTML
                    let rhs = "q".formulaToHTML


                    let s = "The left hand side of a theorem (which includes the left hand side of all theorems in scope) must entail the right hand side. Entailment is present when, for all interpretations of variables on the left hand side that make a formula true, the right hand side formula is true for the same interpretations. You can check this by producing a truth table for the theorem. \nHere, the theorem at line two is considered provable because where " + lhs + " is true, " + rhs + " is true:" + proofHTML

                    return s

                case .antecedent:

                    let tP = ExampleProofs.orIntroductionProof
                    let s = "Any line that a justification makes reference to. In the example below, the justification AND Introduction on line 5 has two antecedents (2, 4)." +
                        tP.htmlVLN

                    return s

                case .justification:

                    let tP = ExampleProofs.orEliminationProof
                    let s = "Either an inference rule like AND Elimination or an assumption. In the example below, the first list has the justificaton 'Assumption'." +
                        tP.htmlVLN

                    return s

                case .assertion:

                    let tP = ExampleProofs.ifIntroduction3Proof
                    let s = "Any line of a proof that makes a claim. In the proof below, all lines are assertions or assumptions." +
                        tP.htmlVLN

                    return s

                case .subproof:

                    let tP = ExampleProofs.ifIntroductionProof
                    let s = "A theorem of the form 'Given A, we can formally prove B', but one introduced within a proof in order to satisfy an inference rule. " +
                        tP.htmlVLN

                    return s

                case .scope:

                    let tP = ExampleProofs.subProofProof
                    let f = "p".formulaToHTML
                    let s = "Every assumption has a scope. It runs from the line in which the assumption is introduced to the line preceding the one in which it is discharged (i.e., we step out of this scope and into the surrounding one). In the example below, the scope of the formula " + f +
                        " is lines 2 to 2.3 inclusive:" +
                        tP.htmlVLN
                    return s

                case .formula:

                    let s = "A logical statement such as "
                        + "p AND q".formulaToHTML + " or " + "p".formulaToHTML

                    return s

                case .assumption:

                    let s = "Something we can assume, given our theorem. For example, from "
                        + "p AND q".formulaToHTML + ts + "q AND p ".formulaToHTML
                        + " we can assume " + "p AND q".formulaToHTML

                    return s

                case .inference:

                    let tP = ExampleProofs.ifIntroduction3Proof
                    let f = "q OR r".formulaToHTML
                    let s = "Something that follows from the preceding proof sentences by a rule of inference. For instance, in the proof below, we can justify " + f +
                        " with the 'OR Introduction' inference rule:" + tP.htmlVLN

                    return s

                case .turnstile:
                    let s = "A separator between what we are given and what we can formally prove. For example, using the theorem "
                        + "p AND q".formulaToHTML + ts + "q AND p".formulaToHTML
                        + " we can say that we are given "
                        + "p AND q".formulaToHTML
                        + " and must formally prove "
                        + "q AND p".formulaToHTML
                    + ". If we can provide this proof, we can say that the right hand side of the theorem is the entailment of the left."

                    return s
            }
        }


    }

    // MARK: HTML tagging
    extension String {

        // Given "hello world" and "p" return "<p>hello world</p>"
        // Any attribute should take the form "class="number""
        func wrap(_ text: String,
                  withTag tag: String,
                  withAttr attribute: String = "",
                  withNewLine: Bool = true) -> String {

            var newLine = ""
            if withNewLine == true {
                newLine = "\n"
            } else {
                newLine = ""
            }

            guard attribute != "" else {

                return "<" + tag + ">" +
                    text
                    + "</" + tag + ">" +
                    newLine

            }

            return "<" + tag + " " + attribute + ">" +
                text
                + "</" + tag + ">" +
                newLine

        }

        // For "hello world".h("p") return "<p>hello world</p>"
        func w(_ tag: String,
               withAttr attribute: String = "",
               withNewLine: Bool = true) -> String {

            guard attribute != "" else {
                return self.wrap(self, withTag: tag,
                                 withNewLine: withNewLine)
            }

            return self.wrap(self, withTag: tag,
                             withAttr: attribute,
                             withNewLine: withNewLine)

        }

        // Common tags
        var h1: String {
            return self.w("h1")
        }

        var h2: String {
            return self.w("h2")
        }

        var h3: String {
            return self.w("h3")
        }

        var p: String {
            return self.w("p")
        }

        // Paragraph, centred
        var pc: String {
            return self.w("p", withAttr: "class=\"centered\"")
        }

        var em: String {
            return self.w("em", withNewLine: false)
        }

        var li: String {
            return self.w("li")
        }

        var ul: String {
            return self.w("ul")
        }

        var tbody: String {
            return self.w("tbody")
        }


        var td: String {
            return self.w("td")
        }

        var th: String {
            return self.w("th")
        }

        var thead: String {
            return self.w("thead")
        }

        var tr: String {
            return self.w("tr")
        }

        func t(withCaption caption: String = "") -> String {

            return ("<caption>" + caption + "</caption>" + self)
                .w("table")

        }

        func asStyledHTML() -> String {

            // Special format (e.g. italic) for definitiions in text
            var body = emphasiseDefinitions(inString: self)
            body = emphasiseJustifications(inString: body)

            // Add styling
            let style = DocumentStyles.baseStyle

            let completeHTML = style
                + body

            return completeHTML

        }


        // Given a text with a definition, emphasise
        // Unusually, this function has similar code to findDefinitions
        func emphasiseDefinitions(inString text: String) -> String {

            var body = ""

            var foundDefinitions = Set<HtmlDefinitions>()

            let hColor = BKColors.auburn.color.hexString

            let lines = text.split(separator: "\n")

            // Scan string for any words that can be defined
            // according to HtmlDefinitions; also mark first
            // occurrence as emphasised
            for l in lines {

                let words = l.split(separator: " ")

                for w in words {

                    var myWord = String(w)

                    // Iterate over contents of our enum
                    // i.e. look for what we can define
                    let definitions = HtmlDefinitions.allCases

                    for d in definitions {

                        // We only want to emphasise the first
                        // occurrence, so continue if we've seen
                        // this before
                        guard !foundDefinitions.contains(d) else {
                            continue
                        }

                        // Note that this check to see if e.g.
                        // "assumption," contains "assumption".
                        if w.lowercased().contains(d.text.lowercased()) {

                            myWord = myWord.w("span", withAttr:
                                """
                                style = "color: \(hColor);"
                                """)

                            foundDefinitions.insert(d)

                        }

                    }

                    body = body + myWord + " "
                }

            }

            return body

        }

        // This function is essentially a duplicate of
        // emphasiseDefinitions
          func emphasiseJustifications(inString text: String) -> String {

            var body = ""

            var foundJustifications = Set<Justification>()

            let hColor = BKColors.deepSpaceSparkle.color.hexString

            let lines = text.split(separator: "\n")

            for l in lines {

                let words = l.split(separator: " ")

                for w in words {

                    var myWord = String(w)

                    // Iterate over contents of our enum
                    // i.e. look for what we can define
                    let definitions = Justification.allCases

                    for d in definitions {

                        // We only want to emphasise the first
                        // occurrence, so continue if we've seen
                        // this before
                        guard !foundJustifications.contains(d) else {
                            continue
                        }

                        // Note that this check to see if e.g.
                        // "assumption," contains "assumption".
                        if w.contains(d.htmlEntityDescription) {

                            myWord = myWord.w("span", withAttr:
                                """
                                style = "color: \(hColor);"
                                """
                            )

                            foundJustifications.insert(d)

                        }

                    }

                    body = body + myWord + " "
                }

            }

            return body

        }

        // Prettify formulae for HTML
        var formulaToHTML: String {
            let f = Formula(self)

            guard f.isWellFormed == true else {
                return self
            }

            return f.tokenStringHTMLWithGlyphs

        }

        // Prettify formulae for HTML
        var formulaToHTMLRespectingCase: String {
            let f = Formula(self, respectCase: true)

            guard f.isWellFormed == true else {
                return self
            }

            return f.tokenStringHTMLWithGlyphs

        }

}
