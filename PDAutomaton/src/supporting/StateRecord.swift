import Foundation

struct StateRecord {
    init(state:State) {
        self.state = state
        counter = Counter()
    }
    init(state:State, withCount count:Int) {
        self.state = state
        counter = Counter(withCount: count)
    }
    var state:State
    var counter:Counter
}
extension StateRecord:CustomStringConvertible {
    var description: String {
        return "\(state.id!)_\(counter.count)"
    }
}
