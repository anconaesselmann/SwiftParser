import Foundation

class CharToken {
    var char:Character
    init(char: Character) {
        self.char = char
    }
}

extension CharToken:Acceptable {
    func accepts(input:AnyObject) -> Bool {
        switch input {
        case is CharToken:
            return (input as! CharToken).char == char
        case is Character:
            return (input as! Character) == char
        case is String:
            return (input as! String) == "\(char)"
        default:
            return false
        }
    }
}

extension CharToken:Comparable {
    static func ==(left: CharToken, right: CharToken) -> Bool {
        return left.char == right.char
    }
    static func <(left: CharToken, right: CharToken) -> Bool { return false }
}

extension CharToken:CustomStringConvertible {
    var description: String {
        return "\(char)"
    }
}
