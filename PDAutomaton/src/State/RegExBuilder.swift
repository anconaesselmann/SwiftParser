import Foundation

class RegExBuilder {
    typealias ActionFunction = () -> Void
    
    var machine:NPDAutomaton! {
        didSet {
            linking = LinkingProperties()
            resetTransitionCounts()
        }
    }
    var regExString:String = ""
    init(withPattern pattern:String) {regExString = pattern}
    init(withPattern pattern:String, andEscapeChar char:Character) {
        escapeChar  = char
        regExString = pattern
    }
    var linking:LinkingProperties!
    var transitioning = TransitionProperties()
    var state:RegExState = .Default
    var escapeChar:Character = "\\"
    private var currentTriggers:[Acceptable]        = []
    private var actions:[Character:ActionFunction]  = [:]
    private var specialChars:[Character:Acceptable] = [:]
    private let initializer = RegExBuilderInitializer()
    
    var atomicGroupCreator:RegExBuilder?
    
    func commitPreviousTransactions() {
        guard shouldCommitTransaction() else {return}
        setTargetState()
        for trigger in currentTriggers {
            linking.origin.append(
                transition: NTransition(
                    targetState: linking.target,
                    trigger:     trigger,
                    withMax:     transitioning.maxTransitionCount
                )
            )
        }
        if !linking.statesAreEqual() {
            machine.append(state: linking.origin)
        }
        if state == .CreateEpsilon {
            epsilonTransitionToNewState()
        }
        linking.targetBecomesOrigin()
        currentTriggers = []
    }
    func setAction(_ char: Character, action:()->Void) {
        actions[char] = action
    }
    func set(specialChar:Acceptable, forChar char: Character) {
        specialChars[char] = specialChar
    }
    func stageTransiton(token:Acceptable) {
        currentTriggers.append(token)
    }
    func stageTransition(char:Character) {
        guard state != .ReadRepetitionValue else {
            updateTransitionCount(char)
            return
        }
        currentTriggers.append(CharToken(char: char))
    }
}
extension RegExBuilder: StateBuilder {
    func compile(machine:Automaton) -> Bool {
        guard compileSetup(machine: machine) else {return false}
        for char in regExString.characters {
            guard processChar(char: char) else {return false}
        }
        compileFinish()
        return true
    }
    
    
    func compileSetup(machine:Automaton) -> Bool {
        guard let machine = machine as? NPDAutomaton else {return false}
        self.machine = machine
        initializer.initialize(builder: self, machine: machine)
        return true
    }
    func compileFinish() {
        commitPreviousTransactions()
        setAcceptingStates()
        machine.append(state: linking.target)
        machine.reset()
    }
}
private extension RegExBuilder {
    func processAtomicGropuPassThrough(char:Character) -> Bool {
        if state == .AtomicGroupPassThrough {
            if atomicGroupCreator!.processChar(char: char) {
                if atomicGroupCreator!.state == .AtomicGroupFinished {
                    stageTransiton(token: atomicGroupCreator!.machine)
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
    func processChar(char: Character) -> Bool {
        guard !processAtomicGropuPassThrough(char: char) else {return true}
        if isSpecialSymbol(char: char) {
            guard let actionFunction = actions[char] else {
                guard let specialChar = specialChars[char] else {return false}
                commitPreviousTransactions()
                stageTransiton(token: specialChar)
                return true
            }
            actionFunction()
        } else {
            print(char)
            commitPreviousTransactions()
            stageTransition(char: char)
        }
        return true
    }
    
    func shouldCommitTransaction() -> Bool {
        // TODO: Split state into two, one governing committing, one governing other behaviour
        guard state != .ReadOrBracket       else {return false}
        guard state != .ReadRepetitionValue else {return false}
        guard state != .ReadEscapedChar     else {return false}
        guard currentTriggers.count > 0     else {return false}
        return true
    }
    func setTargetState() {
        if state == .Default {
            linking.newTarget()
        }
    }
    func epsilonTransitionToNewState() {
        linking.newTarget()
        let epsilonTransition = EpsilonTransition(
            targetState: linking.target,
            withMin:     transitioning.minTransitionCount
        )
        linking.origin.append(transition: epsilonTransition)
        machine.append(state: linking.origin)
        resetTransitionCounts()
    }
    func updateTransitionCount(_ char:Character) {
        guard let newInt = Int("\(char)") else {return}
        transitioning.maxTransitionCount = transitioning.maxTransitionCount * 10 + newInt
    }
    func setAcceptingStates() {
        linking.target.accepting = true
    }
    func isSpecialSymbol(char: Character) -> Bool {
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
    func resetTransitionCounts() {
        transitioning = TransitionProperties()
        state         = .Default
    }
}
