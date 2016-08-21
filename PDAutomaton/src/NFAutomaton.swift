import Foundation

// Nondeterministic Finite State Automaton
class NFAutomaton {
    var tape:Tape! {didSet {reset()}}
    var accepting      = false
    var matchPos:Int?
    var matchBeginning = true
    
    var states         = [State]()
    var currentStates  = StateRecordList()
    var id:Int!
    
    init() {
        _setId()
        tape = nil
    }
    required init(withTape t: Tape) {
        _setId()
        tape = t
    }
    private var _tapePos:Int = 0
    private var _hadPassingState = false
}
extension NFAutomaton:Automaton {
    func append(state: State) {
        states.append(state)
        reset()
    }
    func run() -> Bool {
        let result = matchBeginning ? _runMatchBeginning() : _runMatchLeftMost()
        _resetTape()
        return result
    }
    func step() -> Bool {
        guard !tape.eof else {return false}
        accepting = false
        let token = tape.get()!
        
        let tempChar = (token as! CharToken).char
        print(tempChar)
        if _makeNonDeterministicTransitions(forToken: token) {
            _makeEpsilonTransitions()
            tape.advance()
            return true
        } else {
            return false
        }
    }
    func reset() {
        _initCurrentStates()
        matchPos  = nil
        accepting = false
        _tapePos  = tape?.position ?? 0
        _hadPassingState = false
    }
}

private extension NFAutomaton {
    static var counter = 0
    func _runMatchBeginning() -> Bool {
        var tempTapePos = _tapePos
        while step() {
            // TODO: test here if non-greedy matching (probably...)
            if accepting { tempTapePos = _tapePos }
        }
        if _hadPassingState {
            _tapePos = tempTapePos
            accepting = true
        }
        matchPos = accepting ? _tapePos : nil
        return accepting
    }
    func _runMatchLeftMost() -> Bool {
        let prevTapePos = tape.position
        var tapePos = tape.position
        while !tape.eof {
            tape.position = tapePos
            if _runMatchBeginning() { return true }
            tapePos += 1
        }
        tape.position = prevTapePos
        return false
    }
    
    func _makeNonDeterministicTransitions(forToken token:Acceptable) -> Bool {
        var transitionMade = false
        let temp           = StateRecordList()
        for (_, record) in currentStates {
            if _makeNonDeterministicTransitions(
                forRecord: record,
                withToken: token,
                notIn: temp
                ) {
                transitionMade = true
            }
        }
        currentStates = temp
        return transitionMade
    }
    func _makeNonDeterministicTransitions(forRecord record:StateRecord, withToken token:Acceptable, notIn recordList: StateRecordList) -> Bool {
        var transitionMade = false
        for transition in record.state.transitions {
            guard let transition = transition as? NTransition else {continue}
            if _acceptTransition(transition: transition, token: token) {
                let targetState = transition.targetState!
                let count = (record.state === targetState) ? record.counter.count + 1 : 0
                guard transition.max >= count else {
                    return false
                }
                if recordList.insert(state: targetState, withCount: count) {
                    transitionMade = true
                    _setAccepting(forState: targetState)
                }
            }
        }
        return transitionMade
    }
    func _acceptTransition(transition:NTransition, token: AnyObject) -> Bool {
        if let automaton = transition.trigger as? Automaton {
            automaton.reset()
        }
        return transition.trigger.accepts(input: token)
    }
    func _initCurrentStates() {
        guard states.count > 0 else { return }
        currentStates = StateRecordList()
        let _ = currentStates.insert(state: states[0])
        _makeEpsilonTransitions()
    }
    func _makeEpsilonTransitions() {
        let temp = StateRecordList()
        for (_, record) in currentStates {
            _makeEpsilonTransitions(forRecord: record, notIn: temp)
        }
        currentStates = temp
    }
    func _setAccepting(forState state:State) {
        if state.accepting {
            accepting = true
            _hadPassingState = true
        }
    }
    func _makeEpsilonTransitions(forRecord record:StateRecord, notIn recordList: StateRecordList) {
        let _ = recordList.insert(record: record)
        for transition in record.state.transitions {
            guard let targetState = (transition as? EpsilonTransition)?.targetState else {continue}
            guard (transition as! EpsilonTransition).min <= record.counter.count else {continue}
            if recordList.insert(state: targetState) {
                _setAccepting(forState: targetState)
                let newRecord = StateRecord(state: targetState)
                _makeEpsilonTransitions(forRecord: newRecord, notIn: recordList)
            }
        }
    }
    func _resetTape() {
        if !accepting {
            tape.position = _tapePos
        }
    }
    func _setId() {
        NFAutomaton.counter += 1
        id = NFAutomaton.counter
    }
}

extension NFAutomaton:Acceptable {
    func accepts(input:AnyObject) -> Bool {
        if input is Automaton {
            print("Is atomaton")
        }
        let accepting = run()
        if accepting {
            if !tape.eof {
                tape.back() // TODO: This is wrong
            }
            return accepting
        } else {
            return false
        }
    }
}

extension NFAutomaton:CustomStringConvertible {
    var description: String {
        var machineString = "FSMachine:\n"
        for state in states {
            machineString += "\(state)\n"
        }
        return machineString
    }
}
