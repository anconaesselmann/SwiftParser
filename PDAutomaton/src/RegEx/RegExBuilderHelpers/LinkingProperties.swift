import Foundation

extension RegExBuilder {
    struct LinkingProperties {
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
        mutating func targetBecomesOrigin() {
            origin = target
        }
        mutating func newTarget() {
            target = State()
        }
        mutating func setTarget(forState state:RegExState) {
            if state == .Default {newTarget()}
        }
        mutating func appendToOrigin(transition:TransitionProtocol) {
            origin.append(transition: transition)
        }
        mutating func markTargetAccepting() {
            target.accepting = true
        }
    }
}
