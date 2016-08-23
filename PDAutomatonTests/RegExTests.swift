import XCTest
@testable import PDAutomaton

class RegExTests: XCTestCase {
    var re:RegEx!
    var match:Int?
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
    
    
    func test_oneOrMore() {
        re.pattern = "ab+"
        var match:Int?
        match = re.match(subject: "cabd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 2)
        
        match = re.match(subject: "cad")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.matchLength, 0)
        
        match = re.match(subject: "cabbbbbd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 6)
        
        re.pattern = "ab+c"
        match = re.match(subject: "cabcd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 3)
        
        match = re.match(subject: "cacd")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.matchLength, 0)
        
        match = re.match(subject: "cabbbcd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 5)
    }
    
    func test_zeroOrOne() {
        re.pattern = "ab?c"
        var match:Int?
        match = re.match(subject: "cabcd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 3)
        
        match = re.match(subject: "cacd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 2)
        
        match = re.match(subject: "cabbcd")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.matchLength, 0)
    }

    func test_repetition() {
        re.pattern = "ab{13}c"
        var match:Int?
        match = re.match(subject: "cabbbbbbbbbbbbbcd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 15)
        
        match = re.match(subject: "cabbbbbbbbbbbbbbcd")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.matchLength, 0)
        
        match = re.match(subject: "cabbbbbbbbbbbbcd")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.matchLength, 0)
    }

    func test_range() {
        re.pattern = "ab{2,4}c"
        var match:Int?
        match = re.match(subject: "cabcd")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.matchLength, 0)
        
        match = re.match(subject: "cabbcd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 4)
        
        match = re.match(subject: "cabbbcd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 5)
        
        match = re.match(subject: "cabbbbcd")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 6)
        
        match = re.match(subject: "cabbbbbcd")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.matchLength, 0)
    }
    
    func test_matchEscapedSpecialSymbols() {
        re.pattern = "\\[\\]\\(\\)\\{\\}\\*\\+\\?\\,"
        var match:Int?
        
        match = re.match(subject: "][)(}{*+?,")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.matchLength, 0)
        
        match = re.match(subject: "[](){}*+?,")
        XCTAssertEqual(match, 0)
        XCTAssertEqual(re.matchLength, 10)
        
        re.pattern = "\\[[52431]*\\]"
        print(re.machine)
        match = re.match(subject: "a[12345]a")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 7)
    }
    
    func test_characterGroups() {
        re.pattern = "\\(\\s\\d*\\s\\)"
        match = re.match(subject: "testing( 123 )testing")
        XCTAssertEqual(match, 7)
        XCTAssertEqual(re.matchLength, 7)
    }
    func test_alternateEscapeChar() {
        re.escapeChar = "/"
        re.pattern = "/(/s/d*/s/)"
        match = re.match(subject: "testing( 123 )testing")
        XCTAssertEqual(match, 7)
        XCTAssertEqual(re.matchLength, 7)
    }
    func test_phoneNumber() {
        re.escapeChar = "/"
        re.pattern = "/(/d{3}/)/s?/d{3}/s?-/s?/d{4}"
        print(re.machine)
        match = re.match(subject: "Phone: (626) 344-9785 some other stuff")
        XCTAssertEqual(match, 7)
        XCTAssertEqual(re.matchLength, 14)
    }
    func test_dotOperator() {
        re.pattern = "a.a"
        print(re.machine)
        
        match = re.match(subject: "bacab")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 3)
        
        match = re.match(subject: "baccb")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.matchLength, 0)
    }
    func test_repeatedDotOperator() {
        re.pattern = "a.+a"
        print(re.machine)
        
        match = re.match(subject: "baab")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.matchLength, 0)
        
        match = re.match(subject: "bacabb")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 3)
        
        match = re.match(subject: "bacdefgabb")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 7)
    }
    func test_atomicGroups() {
        re.pattern = "a(bcc)d"
        print(re.machine)
        
        match = re.match(subject: "xabccdx")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 5)
        match = re.match(subject: "xabcdx")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.matchLength, 0)
    }
    func test_atomicGroupsRepeatedZeroOrMore() {
        re.pattern = "a(bcc)*d"
        print(re.machine)
        
        match = re.match(subject: "xadx")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 2)
        
        match = re.match(subject: "xabccdx")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 5)
        
        match = re.match(subject: "xabccbccdx")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 8)
        
        match = re.match(subject: "xabccbcdx")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.matchLength, 0)
    }
    
    
    func test_atomicGroupsRepeatedOneOrMore() {
        re.pattern = "a(bcc)+d"
        print(re.machine)
        
        match = re.match(subject: "xadx")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.matchLength, 0)
        
        match = re.match(subject: "xabccdx")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 5)
        
        match = re.match(subject: "xabccbccdx")
        XCTAssertEqual(match, 1)
        XCTAssertEqual(re.matchLength, 8)
        
        match = re.match(subject: "xabccbcdx")
        XCTAssertEqual(match, nil)
        XCTAssertEqual(re.matchLength, 0)
    }
//    func test_atomicGrouping_catastrophicBacktrackingExample() {
//        re.pattern = "a(.*.*)*b"
//        print(re.machine)
//        
//        match = re.match(subject: "baaaaaab")
//        XCTAssertEqual(match, 1)
//        XCTAssertEqual(re.matchLength, 7)
//    }
}
