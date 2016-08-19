import Foundation

class State {
    var accepting:Bool
    var transitions:[TransitionProtocol] = []
    
    init(accepting:Bool) {
        self.accepting = accepting
        _setId()
    }
    init() {
        accepting = false
        _setId()
    }
    func append(transition: TransitionProtocol) {
        transitions.append(transition)
    }
    var id:Int!
    
    private static var counter = 0
    private func _setId() {
        State.counter += 1
        id = State.counter
    }
}

extension State:CustomStringConvertible {
    var description: String {
        let acceptingString = accepting ? "Accepting" : ""
        var transitionString = ""
        for transition in transitions {
            transitionString += "\n\t\(transition)"
        }
        return "\(acceptingString) State \(id!):\(transitionString)"
    }
}
