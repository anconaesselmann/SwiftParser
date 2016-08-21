import Foundation

class RegExBuilder {
    typealias ActionFunction = () -> RegExState
    
    var machine:NPDAutomaton!
    var regExString:String = ""
    init(withPattern pattern:String) {regExString = pattern}
    private var linking:LinkingProperties!
    private var transitioning = TransitionProperties()
    private var currentTriggers:[Acceptable]       = []
    private var actions:[Character:ActionFunction] = [:]
    private var state:RegExState = .Default
}
extension RegExBuilder: StateBuilder {
    func compile(machine:Automaton) -> Bool {
        guard let machine = machine as? NPDAutomaton else {return false}
        initiate(machine: machine)
        for char in regExString.characters {
            if isSpecialSymbol(char: char) {
                guard let actionFunction = actions[char] else {return false}
                state = actionFunction()
            } else {
                commitPreviousTransactions()
                stageTransition(char: char)
            }
        }
        commitPreviousTransactions()
        setAcceptingStates()
        machine.append(state: linking.target)
        machine.reset()
        return true
    }
}
private extension RegExBuilder {
    func commitPreviousTransactions() {
        guard state != .ReadOrBracket else {return}
        guard currentTriggers.count > 0 else {return}
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
    func stageTransition(char:Character) {
        currentTriggers.append(CharToken(char: char))
    }
    func setAcceptingStates() {
        linking.target.accepting = true
    }
    func isSpecialSymbol(char: Character) -> Bool {
        if isStackSymbol(char) {return true}
        switch char {
            case "*","+","?",",": return true
            default: return false
        }
    }
    func isStackSymbol(_ char: Character) -> Bool {
        for stackSymbol in machine.stackSymbols {
            if char == stackSymbol.pushChar?.char ||
               char == stackSymbol.popChar?.char
            {
                return true
            }
        }
        return false
    }
    func resetTransitionCounts() {
        transitioning = TransitionProperties()
        state         = .Default
    }
    func setAction(_ char: Character, action:()->RegExState) {
        actions[char] = action
    }
    func initiate(machine:NPDAutomaton) {
        self.machine = machine
        machine.addStackSymbol(record: SquareStackRecord())
        machine.addStackSymbol(record: BraceStackRecord())
        machine.addStackSymbol(record: CurlyStackRecord())
        linking = LinkingProperties()
        if regExString[regExString.startIndex] == "^" {
            let secondChar = regExString.index(regExString.startIndex, offsetBy: 1)
            regExString = regExString.substring(from: secondChar)
        } else {
            machine.matchBeginning = false
        }
        setAction("[") { [unowned self] in
            self.commitPreviousTransactions()
            machine.push(record: SquareStackRecord())
            return .ReadOrBracket
        }
        setAction("]") {
            _ = machine.pop()
            return .Default
        }
        setAction("*") { [unowned self] in
            self.transitioning = TransitionProperties(min: 0, max: Int.max)
            return .CreateEpsilon
        }
        setAction("+") { [unowned self] in
            self.transitioning = TransitionProperties(min: 1, max: Int.max)
            return .CreateEpsilon
        }
        setAction("?") { [unowned self] in
            self.transitioning = TransitionProperties(min: 0, max: 1)
            return .CreateEpsilon
        }
        setAction("{") {.ReadFirstRepetitionValue}
        setAction("}") {.ReadSecondRepetitionValue}
        setAction(",") {.FinishingRepetition}
        resetTransitionCounts()
    }
}
