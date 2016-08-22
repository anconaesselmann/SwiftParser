import Foundation

class CharRangeToken {
    var charBegin:Character
    var charEnd:Character
    init(charBegin: Character, charEnd: Character) {
        self.charBegin = charBegin
        self.charEnd   = charEnd
    }
}

extension CharRangeToken:Acceptable {
    func accepts(_ input:AnyObject) -> Bool {
        var testChar:Character!
        switch input {
        case is CharToken:
            testChar = (input as! CharToken).char
            break
        case is Character:
            testChar = input as! Character
            break
        case is String:
            let inputString = (input as! String)
            testChar = inputString[inputString.characters.startIndex]
            break
        default:
            return false
        }
        return (testChar >= charBegin) && (testChar <= charEnd)
    }
}

extension CharRangeToken:CustomStringConvertible {
    var description: String {
        return "\(charBegin)-\(charEnd)"
    }
}
