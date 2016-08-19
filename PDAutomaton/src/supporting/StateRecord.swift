import Foundation

class StateRecord {
    init(state:NState) {
        self.state = state
        counter = Counter()
    }
    var state:NState
    var counter:Counter
}
