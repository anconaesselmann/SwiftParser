import Foundation

class PDAutomaton: FSMachine {
    var stack = Stack<StackRecord>()
    
    var stackSymbols:[StackRecord] = []
    
    func addStackSymbol(record: StackRecord) {
        stackSymbols.append(record)
    }
    func push(record: StackRecord) {
        stack.push(item: record)
    }
    func pop() -> StackRecord {
        return stack.pop()
    }
}
// NondeterministicPushDownAutomaton
class NPDAutomaton: PDAutomaton {
    
}
