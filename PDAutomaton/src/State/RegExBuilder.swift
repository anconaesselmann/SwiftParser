import Foundation

// TODO: Decouple from StringTape, Character... and move generic nfa builder class
class RegExBuilder {
    typealias ActionFunction = () -> Void
    
    var machine:NPDAutomaton! {didSet {transitionBuilder = TransitionBuilder()}}
    var regExString:String = ""
    var transitionBuilder:TransitionBuilder!

    var state:RegExState = .Default
    var escapeChar:Character = "\\"
    private var currentTriggers:[Acceptable]        = []
    private var actions:[Character:ActionFunction]  = [:]
    private var specialChars:[Character:Acceptable] = [:]
    private let initializer = RegExBuilderInitializer()
    var atomicGroupCreator:RegExBuilder?
    private var tempNumber:NumberAppender?
    
    init(withPattern pattern:String) {regExString = pattern}
    init(withPattern pattern:String, andEscapeChar char:Character) {
        escapeChar  = char
        regExString = pattern
    }
    
    func commitPreviousTransactions() {
        guard shouldCommitTransaction() else {return}
        transitionBuilder.setTarget(forState: state)
        for trigger in currentTriggers {
            transitionBuilder.append(withTrigger: trigger)
        }
        if state == .CreateEpsilon {
            transitionBuilder.createEpsilon()
        }
        machine.append(state: transitionBuilder.getCurrentState())
        transitionBuilder.targetBecomesOrigin()
        currentTriggers = []
    }
    func setAction(_ char: Character, action:()->Void) {
        actions[char] = action
    }
    func set(specialChar:Acceptable, forChar char: Character) {
        specialChars[char] = specialChar
    }
    func stageTransiton(forToken token:Acceptable) {
        currentTriggers.append(token)
    }
    func stageTransition(forChar char:Character) {
        guard state != .ReadRangeValue else {
            _ = tempNumber!.append(withChar: char)
            return
        }
        currentTriggers.append(CharToken(char: char))
    }
    func initTempNumber() {
        tempNumber = NumberAppender()
    }
    func getTempNumber() -> Int {
        return tempNumber!.getInteger()
    }
}
extension RegExBuilder: StateBuilder {
    func compile(machine:Automaton) -> Bool {
        guard compileSetup(machine: machine) else {return false}
        for char in regExString.characters {
            guard process(char: char) else {return false}
        }
        finishCompilation()
        return true
    }
    func compileSetup(machine:Automaton) -> Bool {
        guard let machine = machine as? NPDAutomaton else {return false}
        self.machine = machine
        initializer.initialize(builder: self, machine: machine)
        return true
    }
    func finishCompilation() {
        commitPreviousTransactions()
        machine.append(state: transitionBuilder.getFinalState())
    }
}
private extension RegExBuilder {
    func process(char: Character) -> Bool {
        guard !processAtomicGroupPassThrough(char) else {return true}
        if isSpecialSymbol(char) {
            return processSpecialSymbol(char)
        } else {
            return processRegularCharacter(char)
        }
    }
    func processAtomicGroupPassThrough(_ char:Character) -> Bool {
        if state == .AtomicGroupPassThrough {
            if atomicGroupCreator!.process(char: char) {
                if atomicGroupCreator!.state == .AtomicGroupFinished {
                    stageTransiton(forToken: atomicGroupCreator!.machine)
                    atomicGroupCreator = nil
                    state = .Default
                }
                return true
            } else {
                // TODO: Is this an error state?
                return false
            }
        }
        if state == .AtomicGroupFinished {return true}
        return false
    }
    func processSpecialSymbol(_ char: Character) -> Bool {
        guard let actionFunction = actions[char] else {
            guard let specialChar = specialChars[char] else {return false}
            commitPreviousTransactions()
            stageTransiton(forToken: specialChar)
            return true
        }
        actionFunction()
        return true
    }
    func processRegularCharacter(_ char: Character) -> Bool {
        commitPreviousTransactions()
        stageTransition(forChar: char)
        return true
    }
    func shouldCommitTransaction() -> Bool {
        return state.shouldCommit && currentTriggers.count > 0
    }
    func isSpecialSymbol(_ char: Character) -> Bool {
        if state == .ReadEscapedChar {
            state = .Default
            for (symbol, _) in specialChars {
                if symbol == char {return true}
            }
            return false // TODO: Deal with escaped escape characters
        } else if state == .MatchAnything {
            state = .Default
            return true
        }
        for (symbol, _) in actions {
            if symbol == char {return true}
        }
        return false
    }
}
