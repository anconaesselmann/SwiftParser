import Foundation

// Nondeterministic Sate
class NState: State {
    var upperBound:Int? // Should this go into the transition????
    var lowerBound:Int?
}
