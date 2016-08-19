import Foundation

protocol Automaton {
    func run() -> Bool
    func reset()
    var accepting:Bool {get}
    var tape:Tape! {get}
    var matchBeginning:Bool {get set}
    var matchPos:Int? {get}
    func append(state: State)
}
