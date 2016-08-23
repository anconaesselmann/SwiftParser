import Foundation

class CharExclusionGroupToken {
    var exludedTokens = [Acceptable]() // TODO: replace with hash table
}
extension CharExclusionGroupToken:Acceptable {
    func addExcludedToken(_ token:Acceptable) {
        exludedTokens.append(token)
    }
    func accepts(_ input:AnyObject) -> Bool {
        for excludedToken in exludedTokens {
            if excludedToken.accepts(input) {return false}
        }
        return true
    }
}
extension CharExclusionGroupToken:CustomStringConvertible {
    var description: String {
        var result = "[^"
        for excludedToken in exludedTokens {
            result += "\(excludedToken)"
        }
        return result + "]"
    }
}
