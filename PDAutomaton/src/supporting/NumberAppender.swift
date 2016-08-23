import Foundation

class NumberAppender {
    var temp = 0
    func append(withChar char:Character) -> Bool {
        guard let newInt = Int("\(char)") else {return false}
        temp = temp * 10 + newInt
        return true
    }
    func reset() {
        temp = 0
    }
    func getInteger() -> Int {
        return temp
    }
}
