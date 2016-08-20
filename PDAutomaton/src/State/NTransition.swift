import Foundation


class NTransition:TransitionProtocol {
    /* 
     * Maximum number of consecutive visits to the same state
     */
    var max = 1
    var trigger:Acceptable!
    var targetState:State!
    
    init(targetState: State, trigger: Acceptable) {
        self.trigger     = trigger;
        self.targetState = targetState
    }
    init(targetState state: State, trigger: Acceptable, withMax max:Int) {
        self.trigger     = trigger;
        self.targetState = state
        self.max         = max
    }
}
extension NTransition:CustomStringConvertible {
    var description: String {
        let repetiton = (max != 1) ? " \(max)" : ""
        return "Trigger '\(trigger!)' -> State '\(targetState.id!)'\(repetiton)"
    }
}



