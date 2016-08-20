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
    func test_orWithMultipleChars() {
        let expected:Int? = 0
        let match         = re.match(pattern: "am[bcxyz]d", subject: "amydefg")
        XCTAssertEqual(re.machine.states.count, 5)
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
        let re1 = RegEx(pattern: "a")
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
    func test_oneOrMoreOrs() {
        re.pattern = "a[bc]*d"
        XCTAssertEqual(re.machine.states.count, 4) // one for Epsilon transitions (could be optimized to 3)
        var match:Int?
        match = re.match(subject: "dada")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.position, 3)
        match = re.match(subject: "dacda")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.position, 4)
        match = re.match(subject: "dacbbbbbbcda")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.position, 11)
        match = re.match(subject: "bdda")
        XCTAssertEqual(match, nil)
        match = re.match(subject: "daa")
        XCTAssertEqual(match, nil)
        match = re.match(subject: "ac")
        XCTAssertEqual(match, nil)
        match = re.match(subject: "acc")
        XCTAssertEqual(match, nil)
    }
    func test_backtracking_greedyUntilNextChar() {
        re.pattern = "ab*c"
        let match = re.match(subject: "cabbbbbbcd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.position, 9)
    }
    func test_backtracking_greedyUntilEndOfMatch() {
        re.pattern = "ab*"
        print(re.machine)
        var match:Int?
        
        match = re.match(subject: "a")
        XCTAssertEqual(match, 0)
        XCTAssertEqual(re.position, 1)
        XCTAssertEqual(re.matchLength, 1)
        
        match = re.match(subject: "ca")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.position, 2)
        XCTAssertEqual(re.matchLength, 1)
        
        match = re.match(subject: "cac")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.position, 2)
        XCTAssertEqual(re.matchLength, 1)
        
        match = re.match(subject: "cab")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.position, 3)
        XCTAssertEqual(re.matchLength, 2)
        
        match = re.match(subject: "cabbbbbbbbbbbbbbbb")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.position, 18)
        XCTAssertEqual(re.matchLength, 17)
        
        match = re.match(subject: "cccabbbbbbbbcd")
        XCTAssertEqual(match, 3)
        XCTAssertEqual(re.position, 12)
        XCTAssertEqual(re.matchLength, 9)
        
        match = re.match(subject: "cccbbbbbbbbcd")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.position, 0)
        XCTAssertEqual(re.matchLength, 0)
        
        match = re.match(subject: "bbbbbbbb")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.position, 0)
        XCTAssertEqual(re.matchLength, 0)
        
        match = re.match(subject: "")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.position, 0)
        XCTAssertEqual(re.matchLength, 0)
    }
    func test_backtracking2() {
        re.pattern = "ab*b"
        var match:Int?
        match = re.match(subject: "cabd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.position, 3)
        
        match = re.match(subject: "cabbbbbd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.position, 7)
    }
    
    func test_multipleSimultaneousExecutions() {
        re.pattern = "ab*b*c"
        var match:Int?
        match = re.match(subject: "cabcd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.position, 4)
        XCTAssertEqual(re.matchLength, 3)
        
        match = re.match(subject: "cabbbbbbbbbbbcd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 13)
        
        re.pattern = "ab*c*d"
        
        match = re.match(subject: "ccabcde")
        XCTAssertEqual(match, 2)
        XCTAssertEqual(re.matchLength, 4)
        
        match = re.match(subject: "ccabbbbbbbbbbbcccccccccccde")
        XCTAssertEqual(match, 2)
        XCTAssertEqual(re.matchLength, 24)
        
        match = re.match(subject: "ccade")
        XCTAssertEqual(match, 2)
        XCTAssertEqual(re.matchLength, 2)
    }
}
