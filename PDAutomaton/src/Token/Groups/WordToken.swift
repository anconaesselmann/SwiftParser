import Foundation

class WordToken:CharGroupToken {
    override init() {
        super.init()
        add(token: LowerCaseToken())
        add(token: UpperCaseToken())
        add(token: CharToken(char: "_"))
        add(token: DigitToken())
    }
}
