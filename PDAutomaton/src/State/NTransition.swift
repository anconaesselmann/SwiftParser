import Foundation


class NTransition:TransitionProtocol {
    var min = 1
    var max = 1
    
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



