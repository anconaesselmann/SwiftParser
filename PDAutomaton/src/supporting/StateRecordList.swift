import Foundation

class StateRecordList {
    var count:Int {
        get {return _elements.count}
    }
    func insert(state:State) -> Bool {
        return insert(state: state, withCount: 0)
    }
    func insert(state:State, withCount count:Int) -> Bool {
        return insert(record: StateRecord(state: state, withCount: count))
    }
    func insert(record:StateRecord) -> Bool {
        let hash = "\(record.state.id)_\(record.counter.count)"
        return _insert(hash: hash, record: record)
    }
    subscript(index: String) -> StateRecord? {
        get {return _elements[index] ?? nil}
    }
    
    private var _elements = [String:StateRecord]()
    private func _insert(hash:String, record:StateRecord) -> Bool {
        if let _ = _elements[hash] {return false}
        else {
            _elements[hash] = record
            return true
        }
    }
}
extension StateRecordList: Sequence {
    func makeIterator() -> DictionaryIterator<String, StateRecord> {
        return _elements.makeIterator()
    }
}
extension StateRecordList:CustomStringConvertible {
    var description: String {
        var result = ""
        for (_, element) in _elements {
            result += "\t\(element)\n"
        }
        return "RecordList:\n\(result)"
    }
}
