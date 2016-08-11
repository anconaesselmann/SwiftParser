import Foundation

class Transition {
    var trigger:Acceptable!
    var targetState:State!
    
    init(targetState: State, trigger: Acceptable) {
        self.trigger     = trigger;
        self.targetState = targetState
    }
}
extension Transition:CustomStringConvertible {
    var description: String {
        return "Trigger '\(trigger!)' -> State '\(targetState.id!)'"
    }
}
