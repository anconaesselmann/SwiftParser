import Foundation

class Counter {
    init() {
        count = 0
    }
    init(withCount count:Int) {
        self.count = count
    }
    var count = 0
    func inc() {
        count += 1
    }
    func dec() {
        count -= 1
    }
}
