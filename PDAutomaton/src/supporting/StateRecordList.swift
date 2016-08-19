import Foundation

class StateRecordList {
    var count:Int {
        get {
            return _elements.count
        }
    }
    func insert(state:State) -> Bool {
        let hash   = "\(state.id)_0"
        let record = StateRecord(state: state)
        return _insert(hash: hash, record: record)
    }
    func insert(record:StateRecord) -> Bool {
        let hash = "\(record.state.id)_\(record.counter.count)"
        return _insert(hash: hash, record: record)
    }
    subscript(index: String) -> StateRecord? {
        get {
            return _elements[index] ?? nil
        }
    }
    
    private var _elements = [String:StateRecord]()
    private func _insert(hash:String,record:StateRecord) -> Bool {
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
