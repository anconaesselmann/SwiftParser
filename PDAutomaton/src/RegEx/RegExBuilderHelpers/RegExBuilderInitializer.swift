import Foundation

extension RegExBuilder {
    class RegExBuilderInitializer {
        func initialize(builder:RegExBuilder, machine:NPDAutomaton) {
            builder.machine = machine
            machine.addStackSymbol(record: SquareStackRecord())
            machine.addStackSymbol(record: BraceStackRecord())
            machine.addStackSymbol(record: CurlyStackRecord())
            if builder.regExString.characters.count > 1 &&  builder.regExString[builder.regExString.startIndex] == "^" {
                let secondChar = builder.regExString.index(builder.regExString.startIndex, offsetBy: 1)
                builder.regExString = builder.regExString.substring(from: secondChar)
            } else {
                machine.matchBeginning = false
            }
            builder.setAction("[") {
                builder.commitPreviousTransactions()
                machine.push(record: SquareStackRecord())
                builder.state = .ReadOrBracket
            }
            builder.setAction("]") {
                _ = machine.pop()
                builder.state = .Default
            }
            builder.setAction("*") {
                builder.transitioner.willTransitionZeroOrMoreTimes()
                builder.state = .CreateEpsilon
            }
            builder.setAction("+") {
                builder.transitioner.willTransitionOneOrMoreTimes()
                builder.state = .CreateEpsilon
            }
            builder.setAction("?") {
                builder.transitioner.willTransitionOptionally()
                builder.state = .CreateEpsilon
            }
            builder.setAction("{") {
                builder.transitioner.willTransition(withMin: 0, andMax: 0)
                builder.state = .ReadRepetitionValue
            }
            builder.setAction(",") {
                builder.transitioner.swapMaxToMinTransitionTimes()
                builder.state = .ReadRepetitionValue
            }
            builder.setAction("}") {
                builder.transitioner.setExactTransitionTimes()
                builder.state = .CreateEpsilon
            }
            builder.setAction(builder.escapeChar) {
                builder.commitPreviousTransactions()
                builder.state = .ReadEscapedChar
            }
            builder.setAction(".") {
                builder.commitPreviousTransactions()
                builder.stageTransiton(forToken: AnyToken())
            }
            builder.setAction("(") {
                builder.commitPreviousTransactions()
                builder.state = .AtomicGroupStart
                builder.atomicGroupCreator = RegExBuilder(withPattern: "", andEscapeChar: builder.escapeChar)
                let machine = NPDAutomaton()
                machine.tape = builder.machine.tape
                guard builder.atomicGroupCreator!.compileSetup(machine: machine) else {
                    // TODO: set error state
                    print("error")
                    return
                }
                builder.state = .AtomicGroupPassThrough
            }
            builder.setAction(")") {
                builder.state = .Default
                builder.finishCompilation()
                builder.state = .AtomicGroupFinished
            }
            builder.set(specialChar: DigitToken(),      forChar: "d")
            builder.set(specialChar: LowerCaseToken(),  forChar: "l")
            builder.set(specialChar: UpperCaseToken(),  forChar: "u")
            builder.set(specialChar: WordToken(),       forChar: "w")
            builder.set(specialChar: WhiteSpaceToken(), forChar: "s")
//            builder.set(specialChar: HexToken(), forChar: "x")
        }
    }
}
