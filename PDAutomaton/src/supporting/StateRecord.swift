import Foundation

struct StateRecord {
    init(state:State) {
        self.state = state
        counter = Counter()
    }
    var state:State
    var counter:Counter
}
extension StateRecord:CustomStringConvertible {
    var description: String {
        return "\(state.id!)_\(counter.count)"
    }
}
