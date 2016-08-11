import Foundation

struct StackRecord {
    var pushChar:CharToken?
    var popChar:CharToken?
    var data:AnyObject?
    init(data:AnyObject?, pushChar:CharToken, popChar:CharToken) {
        self.pushChar = pushChar
        self.popChar  = popChar
        self.data     = data
    }
}
