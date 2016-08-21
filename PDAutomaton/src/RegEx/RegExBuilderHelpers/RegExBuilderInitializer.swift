import Foundation

extension RegExBuilder {
    class RegExBuilderInitializer {
        func initialize(builder:RegExBuilder, machine:NPDAutomaton) {
            builder.machine = machine
            machine.addStackSymbol(record: SquareStackRecord())
            machine.addStackSymbol(record: BraceStackRecord())
            machine.addStackSymbol(record: CurlyStackRecord())
            if builder.regExString[builder.regExString.startIndex] == "^" {
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
                builder.transitioning = TransitionProperties(min: 0, max: Int.max)
                builder.state = .CreateEpsilon
            }
            builder.setAction("+") {
                builder.transitioning = TransitionProperties(min: 1, max: Int.max)
                builder.state = .CreateEpsilon
            }
            builder.setAction("?") {
                builder.transitioning = TransitionProperties(min: 0, max: 1)
                builder.state = .CreateEpsilon
            }
            builder.setAction("{") {
                builder.transitioning = TransitionProperties(min: 0, max: 0)
                builder.state = .ReadRepetitionValue
            }
            builder.setAction(",") {
                builder.transitioning.minTransitionCount = builder.transitioning.maxTransitionCount
                builder.transitioning.maxTransitionCount = 0
                builder.state = .ReadRepetitionValue
            }
            builder.setAction("}") {
                if builder.transitioning.minTransitionCount < 1 {
                    builder.transitioning.minTransitionCount = builder.transitioning.maxTransitionCount
                }
                builder.state = .CreateEpsilon
            }
            builder.setAction(builder.escapeChar) {
                builder.commitPreviousTransactions()
                builder.state = .ReadEscapedChar
            }
        }
    }
}
