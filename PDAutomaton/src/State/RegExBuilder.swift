import Foundation

class RegExBuilder {
    var regExString:String = ""
    init(regExString:String) {
        self.regExString = regExString
    }
    private func _initiate(machine:PDAutomaton) {
        let initial = State();
        machine.addStackSymbol(
            record: StackRecord(
                data: nil,
                pushChar: CharToken(char: "["),
                popChar: CharToken(char: "]")
            )
        )
        machine.addStackSymbol(
            record: StackRecord(
                data: nil,
                pushChar: CharToken(char: "("),
                popChar: CharToken(char: ")")
            )
        )
        machine.addState(state: initial)
        originState = initial;
    }
    private var originState:State!
    private var linkStates = true
    private var targetState:State!
}
extension RegExBuilder: StateBuilder {
    func compile(machine:FSMachine) {
        guard let machine = machine as? PDAutomaton else {return}
        _initiate(machine: machine)
        
        for char in regExString.characters {
            var state:State
            if linkStates {
                state = State();
            } else {
                state = targetState
            }
            let token = CharToken(char: char)
            if let stackRecord = machine.isPushSymbol(token: token) {
                machine.push(record: stackRecord)
                if stackRecord.pushChar!.char == "[" {
                    linkStates = false
                    targetState = state
                }
            } else if let stackRecord = machine.isPopSymbol(token: token) {
                let _ = machine.pop()
                if stackRecord.popChar!.char == "]" {
                    linkStates = true
                    machine.addState(state: targetState)
                    originState = targetState
                }
            } else {
                originState.addTransition(transition: Transition(targetState: state, trigger:token))
                if linkStates {
                    machine.addState(state: state)
                    originState = state
                }
            }
            
        }
        originState.accepting = true
    }
}
