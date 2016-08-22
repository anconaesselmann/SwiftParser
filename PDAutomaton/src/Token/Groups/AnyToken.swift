import Foundation

class AnyToken {

}
extension AnyToken:Acceptable {
    func accepts(_ input:AnyObject) -> Bool {
        return true
    }
}
extension AnyToken:CustomStringConvertible {
    var description: String {
        return "."
    }
}
