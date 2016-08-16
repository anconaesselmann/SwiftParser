import Foundation

class RegEx {
    var tape:StringTape!
    var machine:PDAutomaton!
    var regExBuilder:RegExBuilder!
    private var _pattern = ""
    var pattern:String {
        set {
            print(pattern)
            _pattern = newValue
            _compile(pattern: pattern)
        }
        get {
            return self._pattern
        }
    }
    init() {}
    init(pattern:String) {
        self.pattern = pattern
    }
    private func _compile(pattern:String) {
        tape         = StringTape()
        machine      = PDAutomaton()
        regExBuilder = RegExBuilder(regExString: pattern)
        machine.tape = tape
        regExBuilder.compile(machine: machine)
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
    
    // TODO: Instead of recompiling, combine the atomata instead to save compilation time
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
