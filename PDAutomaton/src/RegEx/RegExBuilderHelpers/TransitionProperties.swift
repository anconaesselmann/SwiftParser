import Foundation

extension RegExBuilder {
    class TransitionProperties {
        var minTransitionCount:Int
        var maxTransitionCount:Int
        var hasExplicitMin = false
        var hasExplicitMax = false
        init() {
            minTransitionCount = 1
            maxTransitionCount = 1
        }
        init(min:Int, max:Int) {
            minTransitionCount = min
            maxTransitionCount = max
            hasExplicitMin = true
            hasExplicitMax = true
        }
        func appendMaxCount(withChar char:Character) -> Bool {
            guard let newInt = Int("\(char)") else {return false}
            maxTransitionCount = maxTransitionCount * 10 + newInt
            return true
        }
        func setLimitsSequentiallyMaxThenMin(_ val:Int) {
            if hasExplicitMax {
                minTransitionCount = val
                hasExplicitMin = true
            } else {
                maxTransitionCount = val
                hasExplicitMax = true
            }
        }
        func setLimitsSequentiallyMinThenMax(_ val:Int) {
            if hasExplicitMin {
                maxTransitionCount = val
                hasExplicitMax = true
            } else {
                minTransitionCount = val
                hasExplicitMin = true
            }
        }
        func complementMissingExplicitLimit() -> Bool {
            if hasExplicitMax && !hasExplicitMin {
                minTransitionCount = maxTransitionCount
                hasExplicitMin = true
                return true
            } else if hasExplicitMin && !hasExplicitMax {
                maxTransitionCount = minTransitionCount
                hasExplicitMax = true
                return true
            }
            return false
        }
    }
}
