//
//  RudimentaryProof.swift
//  Baker Street
//
//  Created by Ian Hocking on 30/07/2020.
//  Copyright © 2020 Ian. MIT Licence.
//

import Foundation

import Cocoa

public class ExportedProof {

    // The proof in its 'rudimentary' (i.e. portable/universal) form
    var lines = [RudimentaryProofLine]()

    // The proof statement
    var proofStatement: BKLine

    // All lines in the scope of the proof. Note that this includes
    // the proof statement (at element [0])
    var scope: [BKLine]

    // A Dictionary containing each scope level together with
    // a tally of how many lines we have at that scope. Used when
    // creating visual line numbers.
    var scopeTally = Dictionary<Int,Int>()

    // These variables contain exported versions of the proof
    var latex: String = ""
    var html: String = ""
    var htmlVLN: String = ""
    var markdown: String = ""

    // var pdf: Pdf

    // var image: (array of images))

    func dump() -> String {

        return lines.reduce("") { x, y in x + y.debugDescription }

    }

    // Create an array of standardised data that can be used
    // to easily export the proof
    init(withProofLines lines: [BKLine] = [BKLine](),
         withProofStatement pStatement: BKLine,
         giveHtml: Bool = false,
         giveHtmlVLN: Bool = false,
         giveLatex: Bool = false,
         giveMarkdown: Bool = false) {

        proofStatement = pStatement

        // Set scope
        scope = lines

        // Set lines
        setLines()

        // Set the visual line numbers
        setVisualLineNumbers()

        // Before we export, we want to remove the proof statement (this
        // will be include above the exported rows in a table, i.e. not as
        // a row line)
        removeProofStatementFromLines()

        // Formats

        // HTML
        if giveHtml == true { html = makeHtml() }
        if giveHtmlVLN == true {
            htmlVLN = makeHtml(withVisualLineNumbers: true)
        }

        // Latex
        if giveLatex == true { latex = makeLatex() }

        // Markdown
            if giveMarkdown == true { markdown = makeMarkdown() }

        // Note: PDF and images are requested directly using
        // public methods. It's expected that these are called
        // asynchronously

    }

}

// MARK: Setup
extension ExportedProof {

    func setLines() {

        var i = 0

        for l in scope {

            var thisRow = RudimentaryProofLine(withLineNumberUUID: l.identifier)
            thisRow.intLineNumber = i

            if l.lineType == .inactive || l.lineType == .comment {
                continue
            }

            if l.lineType == .theorem {

                let t = l as! Theorem

                thisRow.scopeLevel = t.scopeLevel

                // A theorem can have only one LHS formula in a proof
                // unless the theorem is the overal proof statement
                guard !t.lhsFormula.isEmpty else {
                    continue
                }

                // Build the HTML version
                thisRow.statementHTMLWithGlyphs = t.lhsFormula[0].tokenStringHTMLWithGlyphs
                thisRow.statementHTMLWithGlyphs += MetaType.turnStile.htmlEntity
                thisRow.statementHTMLWithGlyphs += t.rhsFormula.tokenStringHTMLWithGlyphs

                thisRow.theoremProven = t.proven

            }

            if l.lineType == .justified {

                let j = l as! Justified

                thisRow.scopeLevel = j.scopeLevel

                thisRow.statementHTMLWithGlyphs = j.formula.tokenStringHTMLWithGlyphs

                guard j.justification != .empty else {
                    continue
                }

                thisRow.justification = j.justification

                guard j.antecedents.count > 0 else {
                    continue
                }

                for a in j.antecedents {

                    let thisUUID = getIdentifierFromLineNumber(a)

                    if thisUUID != nil { thisRow.antecedentsUUIDs.append(thisUUID!)
                    }
                }

            }

            self.append(thisRow)
            i = i + 1

        }

    }

    func setVisualLineNumbers() {

        scopeTally = createEmptyScopeTally()

        self.lines = self.lines.map {
            getScopeText(forLine: $0) }


        self.lines = self.lines.map {
                insertAntecedentVLN(for: $0) }

    }

    func createEmptyScopeTally() -> Dictionary<Int,Int> {

        // Create dictionary with all scope levels, counters at 0
        var scopeTally = Dictionary<Int,Int>()
        self.lines.forEach { r in
            scopeTally[r.scopeLevel] = 0
        }

        return scopeTally
    }

    func getScopeText(forLine line: RudimentaryProofLine) -> RudimentaryProofLine {

        var scopeText = ""
        var myLine = line

        let thisScope = line.scopeLevel

        // Is this the parent theorem? Then it gets scope 0
        guard thisScope != 0 else {
            myLine.visuaLineNumberSelf = "0"
            return myLine
        }

        scopeTally[thisScope]! += 1

        // Add any scope numbers higher than the current scope
        // e.g. at scope level 3, pick up counts for levels 1 and 2
        var i = 1

        while i < thisScope {

            scopeText.append(String(scopeTally[i]!) + ".")

            i = i + 1
        }

        // Pick up RHS
        scopeText.append(String(scopeTally[thisScope]!))

        // Copy line
        myLine.visuaLineNumberSelf = scopeText

        return myLine

    }

    func insertAntecedentVLN(for line: RudimentaryProofLine) ->
        RudimentaryProofLine {

            var myLine = line

            // No antecdents? Make no changes
            guard line.antecedentsUUIDs.count > 0 else { return myLine }

            var myVisualLines = [String]()

            for a in line.antecedentsUUIDs {

                let visLineNumber = getVisualLineNumberForUUID(for: a)
                myVisualLines.append(visLineNumber)

            }

            myLine.visualLineNumbersAntecedents = myVisualLines.commaList(onlyCommas: true)

            return myLine

    }

    func getVisualLineNumberForUUID(for uuid: UUID) -> String {

        let line = self.lines.filter { $0.lineNumberUUID == uuid }

        // If the UUID is not found, it must be the proof statement
        // i.e. visual line 0
        guard line.count == 1 else { return "0" }

        return line[0].visuaLineNumberSelf

    }

    func removeProofStatementFromLines() {

        var newLines = [RudimentaryProofLine]()
        for l in self.lines {
            if l.lineNumberUUID != proofStatement.identifier {
                newLines.append(l)
            }
        }

        self.lines = newLines
    }

}

// MARK: Async Export

// Some things will take longer to produce, like a PDF. The class
// that creates this ExportedProof will trigger functions in this
// section and then notify any delegates once they are complete
extension ExportedProof {

    func makePdf() {

    }

    func makeImage() {


    }

}

// MARK: Latex

// Example Latex export
//
// Note the use of Latex entities for glyphs
// Visual line numbers are used
// We will need to think a minimal document structure to go around it
//
//  \documentclass{article}
//  \usepackage[T1]{fontenc}
//
//  \begin{document}
//
//
//  \begin{center}
//  \begin{tabular}{r|ll}
//
//  \multicolumn{3}{c}{\(p  \land  q, p  \Rightarrow  r  \vdash  r  \land  q\)} \\
//
//  \hline
//
//  1 & \(p  \land  q\) & ass 0\\
//  2 & \(p  \Rightarrow  r\) & ass 0\\
//  3 & \(p\) & \(\land\)-E 1\\
//  4 & \(q\) & \(\land\)-E 1\\
//  5 & \(r\) & \(\Rightarrow\)-E 2, 3\\
//  6 & \(r  \land  q\) & \(\land\)-I 4, 5\\
//  \end{tabular}
//  \end{center}
//
//  \end{document}

extension ExportedProof {

    func makeLatex() -> String {

        // No proof, no markdown
        guard scope.count > 0 else {
            return ""
        }

        var latex = ""

        let latexTheorem = getTheoremLatex(proofStatement)

        latex = latex + "\\documentclass{article}\n        \\usepackage[T1]{fontenc}\n\\begin{document}\n\\begin{center}\n \\begin{tabular}{r|ll}\n\\multicolumn{3}{c}{\(latexTheorem)}\\\\\n \\hline\n"

        for l in lines {

            latex += l.visuaLineNumberSelf + " & "
            latex += l.statementLatex

            if l.justification != .empty {

                latex += " & " + l.justification.latexEntityShortDescription
                latex += " " + l.visualLineNumbersAntecedents + "\\\\\n"

            } else {

                latex += "\\\\\n"

            }

        }

        latex = latex + "\\end{tabular} \n\\end{center} \n\n\\end{document}"

        // Comment
        let comment = """

            % Exported by Baker Street
            % ------------------------

            % This LaTeX is presented as a minimal, complete document.

            """ + "\n"

        return comment + latex

    }

    // Given a theorem line, return it as Latex
    func getTheoremLatex (_ line: BKLine ) -> String {

        guard line.lineType == .theorem else {
            return ""
        }

        let t = line as! Theorem

        // LHS
        var lhs = ""
        for f in t.lhsFormula {

            lhs.append(f.tokenStringLatex + ", ")

        }

        // Trim trailing ", "
        lhs = String(lhs.dropLast(2))

        // RHS
        var rhs = t.rhsFormula.tokenStringLatex

        // Latex maths environment start and end
        let mStart = "\\("
        let mEnd = "\\)"

        // Both the LHS and RHS already contain Latex maths commands
        // We need to remove them so that single commands can be used
        // at the start and end of the whole general proof statement
        lhs = lhs.replacingOccurrences(of: mStart, with: "")
        lhs = lhs.replacingOccurrences(of: mEnd, with: "")
        rhs = rhs.replacingOccurrences(of: mStart, with: "")
        rhs = rhs.replacingOccurrences(of: mEnd, with: "")


        return mStart + lhs + " " + MetaType.turnStile.latexEntity + " "
            + rhs + mEnd

    }

}

// MARK: Markdown

extension ExportedProof {

    // Example Markdown export
    //
    // 1. Note that connectives etc. should be prettified
    // 2. Scope level 1 has 1 tab
    // 3. We use visual line numbers
    //
    // p AND q |- p AND (r OR q)
    //
    //    - p AND q : Assumption (0)
    //
    //    - p : AND Elimination (1)
    //
    //    - q : AND Elimination (1)
    //
    //    - r OR q : OR Introduction (3)
    //
    //    - p AND (r OR q) : AND Introduction (2, 4)

    func makeMarkdown() -> String {

        // No proof, no markdown
        guard scope.count > 0 else {
            return ""
        }

        var markdown = ""

        let markdownTheorem = getTheoremHTML(proofStatement).htmlToNSMAS().string

        if markdownTheorem.trim.count > 0 {
        markdown += markdownTheorem + "\n\n"
        }

        for l in lines {

            let myScopeBullets = String(repeating: "\t", count: l.scopeLevel)
            markdown += myScopeBullets + "* "
            markdown += l.visuaLineNumberSelf + " "
            markdown += l.statementWithGlyphs

            if l.justification != .empty {

                markdown += " : " + l.justification.description + " ("
                markdown += l.visualLineNumbersAntecedents + ") " + "\n\n"

            } else {

                markdown += "\n\n"

            }

        }

        // Comment
        let comment = """
             <!--
             Exported by Baker Street
             ------------------------
             -->

            """ + "\n"

        return comment + markdown

    }

}

// MARK: Html

extension ExportedProof {

    func makeHtml(withVisualLineNumbers: Bool = false) -> String {

        // No proof, no html
        guard scope.count > 0 else {
            return ""
        }

        // Header text coloring
        let hColor = NSColor(named: "auburn")!.hexString

        // Line beneath header text
        let hlColor = NSColor(named: "deepSpaceSparkle")!.hexString

        // Line coloring
        let lColor = NSColor.textColor.hexString

        let proofTheoremHTML = getTheoremHTML(proofStatement)

        // Only one line? Export as single line
        guard scope.count > 1 else {

            let h = getTheoremHTML(scope[0])

            return h.w("p", withAttr: """
                style = "text-align: center;
                color: \(hColor);
                font-size: 1.1em;
                padding: 0.5em;"
                """)
        }


        let myTable = makeHTMLtable()


        // Finalise table body (i.e. the lines of the proof)

        // Workaround 1 (because padding is not reliable)
        let tableBottomPadding = "<tr><td></td></tr>"

        // Workaround 2 (because borders are not reliable)
        let myHline = "<tr><td style=\"border-top:1px solid \(hlColor);\" colspan=\"4\"></td></tr>"
        let myTableBody = (myHline + myTable + tableBottomPadding).w("tbody")


        // Finalise table head (i.e. the overal proof statement)
        let myTableHead =
            (proofTheoremHTML.w("td", withAttr: "style = \"padding: 1em; text-align: center;\" colspan = \"4\""))
                .w("tr")
                .w("thead", withAttr: "style = \"color: \(hColor); font-size: 1.1em;\"")

        // Combine the head and body
        let myTableHeadAndBody = myTableHead + myTableBody

        // Finalise table and place in body
        let myTableComplete = myTableHeadAndBody.w("table", withAttr: "style = \"font-size: 1em; color: \(lColor); width: 100%; padding: 1em;\"")
            .w("body")

        // Comment
            let comment = """
            <!--
            Exported by Baker Street
            ------------------------

            This HTML is not indented for improved readability. It is recommended that you use a
            a free online HTML formatter.

            This HTML is presented in a minimal, complete document.
            -->

            """ + "\n"

        // Head
        let head = "<head></head>\n"

        return (comment + head + myTableComplete).w("html")

    }

    func makeHTMLtable () -> String {

        var myTable = ""

        for r in self {

            // Line column
            let myLineNumber = r.visuaLineNumberSelf

            // Assertion column
            let myStatement = r.statementHTMLWithGlyphs


            // Justification column
            var myJustification = ""
            if r.theoremProven == true {
                myJustification = "&#10003" // tick!
            } else {
                myJustification = r.justification.htmlEntityShortDescription
            }

            // Antecedent Lines
            let myAntecedents = r.visualLineNumbersAntecedents

            myTable = myTable +
                (
                    myLineNumber.td +
                        myStatement.td +
                        (
                            myJustification + " " +
                            myAntecedents
                            ).td
                    ).tr
        }

        return myTable

    }

    // Given a theorem line, return it as HTML
    func getTheoremHTML (_ line: BKLine ) -> String {

        guard line.lineType == .theorem else {
            return ""
        }

        let t = line as! Theorem

        // LHS
        var lhs = ""
        for f in t.lhsFormula {

            lhs.append(f.tokenStringHTMLWithGlyphs + ", ")

        }

        // Trim trailing ", "
        lhs = String(lhs.dropLast(2))


        // RHS
        let rhs = t.rhsFormula.tokenStringHTMLWithGlyphs

        return lhs + " " + MetaType.turnStile.htmlEntity + " " + rhs

    }


}

// MARK: Line Processing

extension ExportedProof {

    func getIdentifierFromLineNumber(_ line: Int) -> UUID? {

        let l = getLineFromNumber(line)
        return l?.identifier

    }

    func getLineFromNumber(_ number: Int) -> BKLine? {
        var i = 0
        for l in scope {
            if i == number {
                return l

            }
            i = i + 1

        }

        return nil

    }
}

// Learning note: I created this custom iterator based on
// code here: https://developer.apple.com/documentation/swift/iteratorprotocol
extension ExportedProof: Sequence {

    public func makeIterator() -> LineIterator {
        return LineIterator(self)
    }

}


public struct LineIterator: IteratorProtocol {
    let eProof: ExportedProof
    var count = 0

    init(_ rudimentaryProof: ExportedProof) {
        self.eProof = rudimentaryProof
    }

    mutating public func next() -> RudimentaryProofLine? {

        guard eProof.lines.count != 0  else { return nil }

        guard count < eProof.lines.count else { return nil }

        let nextLine = eProof.lines[count]

        count += 1
        return nextLine
    }
}

// MARK: Append
extension ExportedProof {

    func append(_ pLine: RudimentaryProofLine ) {
        lines.append(pLine)
    }

}





