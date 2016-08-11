import Foundation

class FSMachine {
    var name:String
    var states = [State]()
    var finalState:State?
    var currentState:State?
    var tape:Tape! {
        didSet {
            reset()
        }
    }
    var accepting:Bool = false
    private var _tapePos:Int = 0
    
    init(name:String) {
        self.name = name
    }
    init(name: String, tape: StringTape) {
        self.name = name
        self.tape = tape
    }
    func addState(state: State) {
        states.append(state)
    }
    
    func run() -> Bool {
        if finalState == nil {
            while let _ = step() {}
            finalState = currentState
        }
        return accepting
    }
    func step() -> State? {
        guard !tape.eof else {return nil}
        if currentState == nil {
            currentState = states[0]
            _tapePos = tape.position
        }
        let token = tape.get()!
        guard currentState != nil else {return nil}
        for transiton in currentState!.transitions {
            if _acceptTransition(transiton: transiton, token: token) {
                tape.advance()
                return currentState
            }
        }
        accepting    = currentState?.accepting ?? false
        currentState = nil
        _resetTape()
        return nil
    }
    private func _acceptTransition(transiton:Transition, token: AnyObject) -> Bool {
        if transiton.trigger.accepts(input: token) {
            currentState = transiton.targetState
            accepting    = currentState?.accepting ?? false
            return true
        }
        return false
    }
    private func _resetTape() {
        if !accepting {
            tape.position = _tapePos
        }
    }
    func reset() {
        currentState = nil
        _tapePos     = 0
        accepting    = false
    }
}

extension FSMachine: Acceptable {
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

extension FSMachine:CustomStringConvertible {
    var description: String {
        var machineString = "FSMachine:\n"
        for state in states {
            machineString += "\(state)\n"
        }
        return machineString
    }
}
