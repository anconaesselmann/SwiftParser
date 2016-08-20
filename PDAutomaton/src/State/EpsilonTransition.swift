import Foundation

class EpsilonTransition:TransitionProtocol {
    var targetState:State!
    
    /* 
     * Minimum number of consecutive visits to the previous state
     * before transitioning is permitted
     */
    var min = 0
    init(targetState state:State) {
        targetState = state
    }
    init(targetState state:State, withMin minimum:Int) {
        targetState = state
        min         = minimum
    }
}
extension EpsilonTransition:CustomStringConvertible {
    var description: String {
        return "Trigger 'Epsylon' -> State '\(targetState.id!)'"
    }
}
