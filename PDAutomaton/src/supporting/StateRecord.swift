import Foundation

class StateRecord {
    init(state:State) {
        self.state = state
        counter = Counter()
    }
    var state:State
    var counter:Counter
}
