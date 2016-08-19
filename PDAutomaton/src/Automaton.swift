import Foundation

protocol Automaton {
    var accepting:Bool {get}
    var tape:Tape! {get}
    var matchBeginning:Bool {get set}
    var matchPos:Int? {get}
    
    func step() -> Bool
    func run() -> Bool
    func reset()
    func append(state: State)
    
    init(withTape t: Tape)
}
