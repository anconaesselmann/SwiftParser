import Foundation

extension RegExBuilder {
    enum RegExState {
        case Default
        case CreateEpsilon
        case ReadOrBracket
        case ReadRepetitionValue
        case ReadEscapedChar
        case CreateNewState
        case MatchAnything
    }
}
