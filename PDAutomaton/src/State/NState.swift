import Foundation

// Nondeterministic Sate
class NState: State {
    var upperBound:Int? // Should this go into the transition????
    var lowerBound:Int?
//    var counter:Counter?  // Counter doesn't belong here. current states keep track of their counter

    
}
