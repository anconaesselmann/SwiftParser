import Foundation

class CharGroupToken {
    private var elements = [Acceptable]()
    func add(token:Acceptable) {
        elements.append(token)
    }
}
extension CharGroupToken:Acceptable {
    func accepts(_ input:AnyObject) -> Bool {
        for item in elements {
            if item.accepts(input) {return true}
        }
        return false
    }
}
extension CharGroupToken:CustomStringConvertible {
    var description: String {
        var result = ""
        for item in elements {result += "\(item)"}
        return result
    }
}
