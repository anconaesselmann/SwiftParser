import Foundation

protocol Acceptable:AnyObject {
    func accepts(input:AnyObject) -> Bool
}
