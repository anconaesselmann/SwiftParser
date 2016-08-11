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
    func isPushSymbol(token: CharToken) -> StackRecord? {
        for symbol in stackSymbols {
            if token == symbol.pushChar {
                return symbol
            }
        }
        return nil
    }
    func isPopSymbol(token: CharToken) -> StackRecord? {
        for symbol in stackSymbols {
            if token == symbol.popChar {
                return symbol
            }
        }
        return nil
    }
}
