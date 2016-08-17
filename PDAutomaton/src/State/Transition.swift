import Foundation

class Transition {
    var trigger:Acceptable!
    var targetState:State!
    
    init(targetState: State, trigger: Acceptable) {
        self.trigger     = trigger;
        self.targetState = targetState
    }
    init(targetState: State) {
        // TODO: THis is wrong
        self.trigger     = nil;
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
