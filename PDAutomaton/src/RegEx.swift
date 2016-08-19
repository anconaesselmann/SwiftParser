import Foundation

class RegEx {
    var tape:StringTape!
    var machine:NPDAutomaton!
    var regExBuilder:RegExBuilder!
    var position:Int {
        get {
            return tape.position
        }
        set {
            tape.position = newValue
        }
    }
    private var _pattern = ""
    var pattern:String {
        set {
            _pattern = newValue
            let _ = _compile(pattern: pattern) // TODO: Deal with this
        }
        get {
            return self._pattern
        }
    }
    init() {}
    init(pattern:String) {
        self.pattern = pattern
    }
    private func _compile(pattern:String) -> Bool {
        tape         = StringTape()
        machine      = NPDAutomaton()
        regExBuilder = RegExBuilder(regExString: pattern)
        machine.tape = tape
        return regExBuilder.compile(machine: machine)
    }
    private func _match(subject:String) -> Int? {
        tape.string = subject
        var _ = machine.run()
        return machine.matchPos
    }
    func match(subject:String) -> Int? {
        guard machine != nil else { return nil }
        return _match(subject: subject)
    }
    func match(pattern:String, subject:String) -> Int? {
        self.pattern = pattern
        return _match(subject: subject)
    }
    
    // TODO: Instead of recompiling, combine the atomata instead to save compilation time. Then this can probably be moved to parent class too.
    static func +=(lhs: RegEx, rhs: RegEx) {
        lhs.pattern = "\(lhs.pattern)\(rhs.pattern)"
    }
    static func +=(lhs: RegEx, rhs: String) {
        lhs.pattern = "\(lhs.pattern)\(rhs)"
    }
    static func +(lhs: RegEx, rhs: RegEx) -> RegEx {
        return RegEx(pattern: "\(lhs.pattern)\(rhs.pattern)")
    }
    static func +(lhs: RegEx, rhs: String) -> RegEx {
        return RegEx(pattern: "\(lhs.pattern)\(rhs)")
    }
    static func +(lhs: String, rhs: RegEx) -> RegEx {
        return RegEx(pattern: "\(lhs)\(rhs.pattern)")
    }
}

extension RegEx:CustomStringConvertible {
    var description: String {
        return pattern
    }
}
