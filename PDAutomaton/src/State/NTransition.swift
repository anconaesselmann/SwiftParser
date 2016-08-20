import Foundation


class NTransition:TransitionProtocol {
    var max = 1 // Maximum number of consecutive visits to the same state
    var trigger:Acceptable!
    var targetState:State!
    
    init(targetState: State, trigger: Acceptable) {
        self.trigger     = trigger;
        self.targetState = targetState
    }
}
extension NTransition:CustomStringConvertible {
    var description: String {
        return "Trigger '\(trigger!)' -> State '\(targetState.id!)'"
    }
}



