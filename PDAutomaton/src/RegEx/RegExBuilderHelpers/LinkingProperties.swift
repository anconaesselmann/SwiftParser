import Foundation

extension RegExBuilder {
    struct TransitionBuilder {
        private var transProps = TransitionProperties()
        var origin:State
        var target:State
        init(origin:State, target:State) {
            self.origin = origin
            self.target = target
        }
        init() {
            origin = State();
            target = origin
        }
        func statesAreEqual() -> Bool {
            return origin === target
        }
        mutating func appendTransitionMaxCount(withChar char: Character) -> Bool {
            return transProps.appendMaxCount(withChar: char)
        }
        mutating func targetBecomesOrigin() {
            origin = target
        }
        mutating func newTarget() {
            target = State()
        }
        mutating func setTarget(forState state:RegExState) {
            if state == .Default {newTarget()}
        }
        mutating func append(withTrigger trigger:Acceptable) {
            origin.append(
                transition: NTransition(
                    targetState: target,
                    trigger:     trigger,
                    withMax:     transProps.maxTransitionCount
                )
            )
        }
        mutating func markTargetAccepting() {
            target.accepting = true
        }
        mutating func createEpsilon() {
            newTarget()
            let epsilonTransition = EpsilonTransition(
                targetState: target,
                withMin: transProps.minTransitionCount
            )
            origin.append(transition: epsilonTransition)
            transProps = TransitionProperties()
        }
        mutating func willTransition(withMin min:Int, andMax max:Int) {
            transProps = TransitionProperties(min: min, max: max)
        }
        mutating func willTransitionZeroOrMoreTimes() {
            willTransition(withMin: 0, andMax: Int.max)
        }
        mutating func willTransitionOneOrMoreTimes() {
            willTransition(withMin: 1, andMax: Int.max)
        }
        mutating func willTransitionOptionally() {
            willTransition(withMin: 0, andMax: 1)
        }
        mutating func swapMaxToMinTransitionTimes() {
            transProps.minTransitionCount = transProps.maxTransitionCount
           transProps.maxTransitionCount = 0
        }
        mutating func setExactTransitionTimes() {
            if transProps.minTransitionCount < 1 {
                transProps.minTransitionCount = transProps.maxTransitionCount
            }
        }
    }
}
