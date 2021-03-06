import Foundation

class Transition:TransitionProtocol {
    var trigger:Acceptable!
    var targetState:State!
    
    init(targetState: State, trigger: Acceptable) {
        self.trigger     = trigger;
        self.targetState = targetState
    }
}

extension Transition:CustomStringConvertible {
    var description: String {
        if trigger == nil {
            return "Trigger 'Epsylon' -> State '\(targetState.id!)'"
        }
        return "Trigger '\(trigger!)' -> State '\(targetState.id!)'"
    }
}
