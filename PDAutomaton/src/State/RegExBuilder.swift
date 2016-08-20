import Foundation

class RegExBuilder {
    typealias ActionFunction = () -> Void
    
    var machine:NPDAutomaton!
    var regExString:String = ""
    init(regExString:String) {
        self.regExString = regExString
    }
    private var originState:State!
    private var targetState:State!
    private var linkStates = true
    private var minTransitionCount = 1
    private var maxTransitionCount = 1
    private var _currentTriggers:[Acceptable] = []
    private var _actions:[Character:ActionFunction] = [:]
    private var _createEpsilon = false
}
extension RegExBuilder: StateBuilder {
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
}
private extension RegExBuilder {
    func _initSquareOrAction() {
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
    func _finishSquareOrAction() {
        let _      = machine.pop()
        linkStates = true
    }
    func _commitPreviousTransactions() {
        guard linkStates else {return}
        guard _currentTriggers.count > 0 else {return}
        _setTargetState()
        for trigger in _currentTriggers {
            originState.append(transition: NTransition(targetState: targetState, trigger:trigger, withMax: maxTransitionCount))
        }
        if originState !== targetState {
            machine.append(state: originState)
        }
        if _createEpsilon {
            _epsilonTransitionToNewState()
        }
        originState      = targetState
        _currentTriggers = []
    }
    func _setTargetState() {
        if !_createEpsilon {
            targetState = State()
        }
    }
    func _epsilonTransitionToNewState() {
        targetState = State()
        let epsilonTransition = EpsilonTransition(targetState: targetState, withMin: minTransitionCount)
        originState.append(transition: epsilonTransition)
        machine.append(state: originState)
        _resetTransitionCounts()
    }
    func _stageTransition(char:Character) {
        _currentTriggers.append(CharToken(char: char))
    }
    func _setAcceptingStates() {
        targetState.accepting = true
    }
    func _isSpecialSymbol(char: Character) -> Bool {
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
    
    
    
    func _resetTransitionCounts() {
        maxTransitionCount = 1
        minTransitionCount = 1
        _createEpsilon = false
    }
    
    func _zeroOrMoreAction() {
        maxTransitionCount = Int.max
        minTransitionCount = 0
        _createEpsilon = true
    }
    func _oneOrMoreAction() {
        maxTransitionCount = Int.max
        minTransitionCount = 1
        _createEpsilon = true
    }
    func _optionalAction() {
        maxTransitionCount = 1
        minTransitionCount = 0
        _createEpsilon = true
    }
    func _initRepetitionAction() {
        
    }
    func _finishRepetitionAction() {
        
    }
    
    func _initiate(machine:NPDAutomaton) {
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
        
        _resetTransitionCounts()
    }
}
