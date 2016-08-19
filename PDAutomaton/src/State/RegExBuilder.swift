import Foundation

class RegExBuilder {
    typealias ActionFunction = () -> Void
    
    var machine:NPDAutomaton!
    var regExString:String = ""
    init(regExString:String) {
        self.regExString = regExString
    }
    private func _initiate(machine:NPDAutomaton) {
        self.machine = machine
        let initial = State();
        machine.addStackSymbol(
            record: StackRecord(
                data: nil,
                pushChar: CharToken(char: "["),
                popChar:  CharToken(char: "]")
            )
        )
        machine.addStackSymbol(
            record: StackRecord(
                data: nil,
                pushChar: CharToken(char: "("),
                popChar:  CharToken(char: ")")
            )
        )
        originState = initial
        targetState = initial
        if regExString[regExString.startIndex] == "^" {
            let secondChar = regExString.index(regExString.startIndex, offsetBy: 1)
            regExString = regExString.substring(from: secondChar)
        } else {
            machine.matchBeginning = false
        }
        _actions["["] = _initSquareOrAction
        _actions["]"] = _finishSquareOrAction
        _actions["*"] = _zeroOrMoreAction
        _actions["+"] = _oneOrMoreAction
        _actions["?"] = _optionalAction
        _actions["{"] = _initRepetitionAction
        _actions["}"] = _finishRepetitionAction
    }
    private var originState:State!
    private var targetState:State!
    private var linkStates = true
    private var zeroOrMore = false
    private var _currentTriggers:[Acceptable] = []
    private var _actions:[Character:ActionFunction] = [:]
}
extension RegExBuilder: StateBuilder {
    private func _initSquareOrAction() {
        _commitPreviousTransactions()
        machine.push(record:
            StackRecord(
                data: nil,
                pushChar: CharToken(char:"["),
                popChar: CharToken(char:"]")
            )
        )
        linkStates = false
    }
    private func _finishSquareOrAction() {
        let _      = machine.pop()
        linkStates = true
    }
    private func _commitPreviousTransactions() {
        guard linkStates else {return}
        guard _currentTriggers.count > 0 else {return}
        _setTargetState()
        for trigger in _currentTriggers {
            originState.append(transition: NTransition(targetState: targetState, trigger:trigger))
        }
        if originState !== targetState {
             machine.append(state: originState)
        }
        originState      = targetState
        _currentTriggers = []
    }
    private func _setTargetState() {
        if zeroOrMore {
            zeroOrMore = false
        } else {
            targetState = State()
        }
        
    }
    private func _stageTransition(char:Character) {
        _currentTriggers.append(CharToken(char: char))
    }
    func compile(machine:Automaton) -> Bool {
        guard let machine = machine as? NPDAutomaton else {return false}
        _initiate(machine: machine)
        for char in regExString.characters {
            if _isSpecialSymbol(char: char) {
                guard let actionFunction = _actions[char] else {return false}
                actionFunction()
            } else {
                _commitPreviousTransactions()
                _stageTransition(char: char)
            }
        }
        _commitPreviousTransactions()
        _setAcceptingStates()
        machine.append(state: targetState)
        machine.reset()
        return true
    }
    
    
    
    
    
    
    private func _setAcceptingStates() {
        targetState.accepting = true
    }
    private func _isSpecialSymbol(char: Character) -> Bool {
        for stackSymbol in machine.stackSymbols {
            if char == stackSymbol.pushChar?.char ||
                char == stackSymbol.popChar?.char
            {
                return true
            }
        }
        switch char {
        case "*":
            return true
        case "+":
            return true
        case "?":
            return true
        default:
            return false
        }
    }
    
    
    private func _zeroOrMoreAction() {
        zeroOrMore = true
    }
    private func _oneOrMoreAction() {
        
    }
    private func _optionalAction() {
        
    }
    private func _initRepetitionAction() {
        
    }
    private func _finishRepetitionAction() {
        
    }
}
