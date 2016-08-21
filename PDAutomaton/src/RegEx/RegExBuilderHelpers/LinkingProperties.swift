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
    }
}
