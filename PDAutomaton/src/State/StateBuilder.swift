import Foundation

protocol StateBuilder {
    func compile(machine:Automaton) -> Bool
}
