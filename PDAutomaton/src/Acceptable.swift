import Foundation

protocol Acceptable:AnyObject {
    func accepts(_ input:AnyObject) -> Bool
}
