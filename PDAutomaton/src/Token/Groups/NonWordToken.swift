import Foundation

class NonWordToken:CharExclusionGroupToken {
    override init() {
        super.init()
        addExcludedToken(WordToken())
    }
}
