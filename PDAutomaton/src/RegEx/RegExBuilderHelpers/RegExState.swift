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
        case AtomicGroupStart
        case AtomicGroupPassThrough
        case AtomicGroupFinished
        var shouldCommit:Bool {
            switch self {
            case .ReadOrBracket, .ReadRepetitionValue, .ReadEscapedChar: return false
            default: return true
            }
        }
    }
}
