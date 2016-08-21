import Foundation

protocol StackRecord {
    var pushChar:CharToken? {get set}
    var popChar:CharToken? {get set}
    var data:AnyObject? {get set}
}
struct GenericStackRecord:StackRecord {
    var pushChar:CharToken?
    var popChar:CharToken?
    var data:AnyObject?
    init(data:AnyObject?, pushChar:CharToken, popChar:CharToken) {
        self.pushChar = pushChar
        self.popChar  = popChar
        self.data     = data
    }
}
struct SquareStackRecord:StackRecord {
    var pushChar:CharToken?
    var popChar:CharToken?
    var data:AnyObject?
    init() {
        pushChar = CharToken(char: "[")
        popChar  = CharToken(char: "]")
    }
}
class BraceStackRecord:StackRecord {
    var pushChar:CharToken?
    var popChar:CharToken?
    var data:AnyObject?
    init() {
        pushChar = CharToken(char: "(")
        popChar  = CharToken(char: ")")
    }
}
class CurlyStackRecord:StackRecord {
    var pushChar:CharToken?
    var popChar:CharToken?
    var data:AnyObject?
    init() {
        pushChar = CharToken(char: "{")
        popChar  = CharToken(char: "}")
    }
}
