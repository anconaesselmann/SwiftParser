import Foundation

class EpsilonTransition:TransitionProtocol {
    var targetState:State!
    init(targetState state:State) {
        targetState = state
    }
}
extension EpsilonTransition:CustomStringConvertible {
    var description: String {
        return "Trigger 'Epsylon' -> State '\(targetState.id!)'"
    }
}
