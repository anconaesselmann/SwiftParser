import Foundation

extension RegExBuilder {
    enum RegExState {
        case Default
        case CreateEpsilon
        case ReadOrBracket
        case ReadRangeValue
        case ReadEscapedChar
        case CreateNewState
        case MatchAnything
        case AtomicGroupStart
        case AtomicGroupPassThrough
        case AtomicGroupFinished
        var shouldCommit:Bool {
            switch self {
            case .ReadOrBracket, .ReadRangeValue, .ReadEscapedChar: return false
            default: return true
            }
        }
    }
}
