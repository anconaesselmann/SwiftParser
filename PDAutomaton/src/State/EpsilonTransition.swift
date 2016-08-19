import Foundation

class EpsilonTransition:TransitionProtocol {
    var targetState:State!
    init(targetState state:NState) {
        targetState = state
    }
}
extension EpsilonTransition:CustomStringConvertible {
    var description: String {
        return "Trigger 'Epsylon' -> State '\(targetState.id!)'"
    }
}
