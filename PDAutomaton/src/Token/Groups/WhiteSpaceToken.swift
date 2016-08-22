import Foundation

class WhiteSpaceToken:CharGroupToken {
    override init() {
        super.init()
        add(token: CharToken(char: " "))
        add(token: CharToken(char: "\n"))
        add(token: CharToken(char: "\r"))
        add(token: CharToken(char: "\t"))
    }
}
