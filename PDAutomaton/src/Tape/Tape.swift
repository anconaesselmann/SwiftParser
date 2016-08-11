import Foundation


protocol Tape {
    var position:Int {get set}
    var eof:Bool {get}
    func get() -> Acceptable?
    func advance()
    func back()
}
