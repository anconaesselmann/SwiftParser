import Foundation

class StringTape {
    var string:String {
        didSet { position = 0 }
    }
    init(string: String) {
        self.string = string
    }
    init() {
        self.string = ""
    }
    
    private var _pos = 0
    private var _eof:Bool = false
}

extension StringTape:Tape {
    var position:Int {
        get { return _pos }
        set {
            if newValue < string.characters.count {
                _pos = newValue
                _eof = false
            } else {
                _pos = string.characters.count
                _eof = true
            }
        }
    }
    var eof:Bool {
        get { return _eof }
    }
    func get() -> Acceptable? {
        guard !eof else { return nil }
        let index = string.index(string.startIndex, offsetBy: position)
        return CharToken(char: string[index])
    }
    func advance() {
        position += 1
    }
    func back() {
        position -= 1
    }
}
