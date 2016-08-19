import Foundation

// NondeterministicPushDownAutomaton
class NFAutomaton:Automaton {
    var states = [NState]()
    var currentStates  = StateRecordList()
    var matchBeginning = true
    var accepting      = false
    var tape:Tape! {didSet {reset()}}
    var matchPos:Int?
    
    func append(state: State) {
        let state = state as! NState
        states.append(state)
    }
    
    private func _runMatchBeginning() -> Bool {
        while step() {
            if accepting {
                // TODO: make this dependent on a flag that interupts execution when the first match is found before the tape is at the end
                break
            }
        }
        matchPos = accepting ? _tapePos : nil
        return accepting
    }
    private func _runMatchLeftMost() -> Bool {
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
    func run() -> Bool {
        return matchBeginning ? _runMatchBeginning() : _runMatchLeftMost()
    }
    
    func step() -> Bool {
        guard !tape.eof else {return false}
        accepting = false
        let token = tape.get()!
        if _makeNonDeterministicTransitions(forToken: token) {
            _makeEpsilonTransitions()
            tape.advance()
            return true
        } else {
            accepting = false
            _resetTape()
            return false
        }
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
            if _acceptTransition(transiton: transition, token: token) {
                let targetState = transition.targetState as! NState
                if recordList.insert(state: targetState) {
                    transitionMade = true
                    if targetState.accepting {
                        accepting = true
                    }
                }
            }
        }
        return transitionMade
    }
    private func _acceptTransition(transiton:NTransition, token: AnyObject) -> Bool {
        return transiton.trigger.accepts(input: token)
    }
    
    func reset() {
        _initCurrentStates()
        matchPos  = nil
        accepting = false
        _tapePos  = tape?.position ?? 0
    }
    
    private var _tapePos:Int = 0
    
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
    func _makeEpsilonTransitions(forRecord record:StateRecord, notIn recordList: StateRecordList) {
        let _ = recordList.insert(record: record)
        for transition in record.state.transitions {
            guard let targetState = (transition as? EpsilonTransition)?.targetState as? NState else {continue}
            if recordList.insert(state: targetState) {
                let newRecord = StateRecord(state: targetState)
                _makeEpsilonTransitions(forRecord: newRecord, notIn: recordList)
            }
        }
    }
    private func _resetTape() {
        if !accepting {
            tape.position = _tapePos
        }
    }
}
extension NFAutomaton:Acceptable {
    func accepts(input:AnyObject) -> Bool {
        let accepting = run()
        if accepting {
            if !tape.eof {
                tape.back() // This is wrong
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
