import Foundation

extension RegExBuilder {
    class TransitionProperties {
        var minTransitionCount:Int
        var maxTransitionCount:Int
        init() {
            minTransitionCount = 1
            maxTransitionCount = 1
        }
        init(min:Int, max:Int) {
            minTransitionCount = min
            maxTransitionCount = max
        }
        func appendMaxCount(withChar char:Character) -> Bool {
            guard let newInt = Int("\(char)") else {return false}
            maxTransitionCount = maxTransitionCount * 10 + newInt
            return true
        }
    }
}
