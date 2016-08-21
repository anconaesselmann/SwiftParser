import Foundation

extension RegExBuilder {
    enum RegExState {
        case Default
        case CreateEpsilon
        case ReadOrBracket
        case ReadFirstRepetitionValue
        case ReadSecondRepetitionValue
        case FinishingRepetition
    }
}
