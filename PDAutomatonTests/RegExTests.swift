import XCTest
@testable import PDAutomaton

class RegExTests: XCTestCase {
    var re:RegEx!
    override func setUp() {
        super.setUp()
        re = RegEx()
    }
    
    func test_simpleOr() {
        let expected:Int? = 0
        let match         = re.match(pattern: "a[bc]d", subject: "acdefg")
        XCTAssertEqual(match, expected)
    }
    func test_simpleOr_noMatch() {
        let expected:Int? = nil
        let match         = re.match(pattern: "a[bc]d", subject: "addefg")
        XCTAssertEqual(match, expected)
    }
    func test_simpleOr_notInFront() {
        let expected:Int? = 3
        let match         = re.match(pattern: "a[bc]d", subject: "aaaacdefg")
        XCTAssertEqual(match, expected)
    }
    func test_simpleOr_partialMatchFollowedByMatch() {
        let expected:Int? = 3
        let match         = re.match(pattern: "a[bc]d", subject: "aacacdefg")
        XCTAssertEqual(match, expected)
    }
    func test_matchBeginningOfString_success() {
        let expected:Int? = 0
        let match         = re.match(pattern: "^a[bc]d", subject: "acdefg")
        XCTAssertEqual(match, expected)
    }
    func test_matchBeginningOfString_noMatch() {
        let expected:Int? = nil
        let match         = re.match(pattern: "^a[bc]d", subject: "acacdefg")
        XCTAssertEqual(match, expected)
    }
    func test_combiningRegexesByStringConcatination() {
        let re1 = RegEx(pattern: "a")
        let re2 = RegEx(pattern: "[bc]")
        re = RegEx(pattern: "\(re1)\(re2)d")
        
        let expected:Int? = 2
        let match         = re.match(subject: "acacdefg")
        XCTAssertEqual(match, expected)
    }
    func test_combiningRegexesByStringConcatination_withOverloadedConcatenationOperators() {
        var re1 = RegEx(pattern: "a")
        let re2 = RegEx(pattern: "[bc]")
        re1 += re2
        re1 += "d"
        re = re1
        
        let expected:Int? = 2
        let match         = re.match(subject: "acacdefg")
        XCTAssertEqual(match, expected)
    }
    
    func test_combiningRegexesByStringConcatination_withOverloadedAdditionOperators() {
        let re1 = RegEx(pattern: "[bc]")
        re = "a" + re1 + "d"
        
        let expected:Int? = 2
        let match         = re.match(subject: "acacdefg")
        XCTAssertEqual(match, expected)
    }

    
}
