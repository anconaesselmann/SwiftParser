import XCTest
@testable import PDAutomaton

class TokenTests: XCTestCase {
    func testEqualityCharToken() {
        let a1 = CharToken(char: "a")
        let a2 = CharToken(char: "a")
        let b  = CharToken(char: "b")
        
        XCTAssert(a1 == a1)
        XCTAssert(a1 == a2)
        XCTAssert(a1 != b)
    }
    
    func testEqualityCharRangeToken() {
        let b = CharToken(char: "b")
        let c = CharToken(char: "c")
        let d = CharToken(char: "d")
        let e = CharToken(char: "e")
        let f = CharToken(char: "f")
        let g = CharToken(char: "g")
        let h = CharToken(char: "h")
        let E = CharToken(char: "E")
        
        let range = CharRangeToken(charBegin: "c", charEnd: "g")
        let range2 = CharRangeToken(charBegin: "C", charEnd: "G")
        
        XCTAssert(range.accepts(b) == false)
        XCTAssert(range.accepts(c) == true)
        XCTAssert(range.accepts(d) == true)
        XCTAssert(range.accepts(e) == true)
        XCTAssert(range.accepts(f) == true)
        XCTAssert(range.accepts(g) == true)
        XCTAssert(range.accepts(h) == false)
        XCTAssert(range.accepts(E) == false)
        XCTAssert(range2.accepts(E) == true)
    }
    func testDigitToken() {
        let d0 = CharToken(char: "0")
        let d1 = CharToken(char: "1")
        let d2 = CharToken(char: "2")
        let d3 = CharToken(char: "3")
        let d4 = CharToken(char: "4")
        let d5 = CharToken(char: "5")
        let d6 = CharToken(char: "6")
        let d7 = CharToken(char: "7")
        let d8 = CharToken(char: "8")
        let d9 = CharToken(char: "9")
        
        let b = CharToken(char: "b")
        let C = CharToken(char: "C")
        
        let range = DigitToken()
        
        XCTAssert(range.accepts(d0) == true)
        XCTAssert(range.accepts(d1) == true)
        XCTAssert(range.accepts(d2) == true)
        XCTAssert(range.accepts(d3) == true)
        XCTAssert(range.accepts(d4) == true)
        XCTAssert(range.accepts(d5) == true)
        XCTAssert(range.accepts(d6) == true)
        XCTAssert(range.accepts(d7) == true)
        XCTAssert(range.accepts(d8) == true)
        XCTAssert(range.accepts(d9) == true)
        XCTAssert(range.accepts(b) == false)
        XCTAssert(range.accepts(C) == false)
    }
    func testWordToken() {
        let digit = CharToken(char: "8")
        let b = CharToken(char: "b")
        let C = CharToken(char: "C")
        let underScore = CharToken(char: "_")
        
        let space = CharToken(char: " ")
        
        let range = WordToken()
        
        XCTAssert(range.accepts(digit) == true)
        XCTAssert(range.accepts(b) == true)
        XCTAssert(range.accepts(C) == true)
        XCTAssert(range.accepts(underScore) == true)
        
        XCTAssert(range.accepts(space) == false)
    }
    
    func testWhiteSpaceToken() {
        let digit = CharToken(char: "8")
        let space = CharToken(char: " ")
        let newLine = CharToken(char: "\n")
        let returnChar = CharToken(char: "\r")
        let tab = CharToken(char: "\t")
        
        let range = WhiteSpaceToken()
        
        XCTAssert(range.accepts(digit) == false)
        
        XCTAssert(range.accepts(space) == true)
        XCTAssert(range.accepts(newLine) == true)
        XCTAssert(range.accepts(returnChar) == true)
        XCTAssert(range.accepts(tab) == true)
    }
}
