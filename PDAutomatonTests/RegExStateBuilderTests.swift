import XCTest
@testable import PDAutomaton

class RegExStateBuilderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    func testRegExStateBuilderEntireStringMatches() {
        let reg     = RegExBuilder(withPattern: "abcd")
        let tape    = StringTape(string: "abcd")
        let machine = NPDAutomaton(withTape: tape)
        let compiled = reg.compile(machine: machine)
        machine.reset()
        XCTAssertEqual(compiled, true)
        let accepting = machine.run()
        XCTAssertEqual(accepting, true)
        XCTAssertEqual(tape.position, 4)
        XCTAssertEqual(machine.matchPos, 0)
    }
    func testRegExStateBuilder() {
        let reg     = RegExBuilder(withPattern: "abcd")
        let tape    = StringTape(string: "abcdefg")
        let machine = NPDAutomaton(withTape: tape)
        let compiled = reg.compile(machine: machine)
        XCTAssertEqual(compiled, true)
        let accepting = machine.run()
        XCTAssertEqual(accepting, true)
        XCTAssertEqual(tape.position, 4)
        XCTAssertEqual(machine.matchPos, 0)
    }
    func testRegExStateBuilderRunTwice() {
        let reg     = RegExBuilder(withPattern: "abcd")
        let tape    = StringTape(string: "abcdabcd")
        let machine = NPDAutomaton(withTape: tape)
        let compiled = reg.compile(machine: machine)
        XCTAssert(compiled)
        var accepting = machine.run()
        XCTAssert(machine.accepting == true)
        XCTAssert(tape.position == 4)
        XCTAssertEqual(machine.matchPos, 0)
        tape.position = 4
        accepting = machine.run()
        XCTAssertEqual(accepting, true)
        XCTAssertEqual(tape.position, 8)
        XCTAssertEqual(machine.matchPos, 4)
    }
    func testRegExStateBuilder_resetWhenNotMatching() {
        let reg     = RegExBuilder(withPattern: "abcd")
        let tape    = StringTape(string: "abcefg")
        let machine = NPDAutomaton(withTape: tape)
        let compiled = reg.compile(machine: machine)
        XCTAssert(compiled)
        let accepting = machine.run()
        XCTAssertEqual(accepting, false)
        XCTAssertEqual(tape.position, 0)
        XCTAssertEqual(machine.matchPos, nil)
    }
    
    func testRegExStateBuilderTapeNotAtBeginning_resetWhenNotMatching() {
        let reg     = RegExBuilder(withPattern: "abcd")
        let tape    = StringTape(string: "ababce")
        tape.position = 2
        let machine = NPDAutomaton(withTape: tape)
        let compiled = reg.compile(machine: machine)
        XCTAssert(compiled)
        let accepting = machine.run()
        XCTAssertEqual(accepting, false)
        XCTAssertEqual(tape.position, 2)
        XCTAssertEqual(machine.matchPos, nil)
    }
    func testRegExStateBuilder_testOrWithExplicitCharacters() {
        let reg     = RegExBuilder(withPattern: "a[bc]d")
        let tape    = StringTape(string: "abdefg")
        let machine = NPDAutomaton(withTape: tape)
        let compiled = reg.compile(machine: machine)
        XCTAssert(compiled)
        let accepting = machine.run()
        XCTAssertEqual(accepting, true)
        XCTAssertEqual(tape.position, 3)
        XCTAssertEqual(machine.matchPos, 0)
    }
    
    func testRegExStateBuilder_testOrWithExplicitCharacters_failing() {
        let reg     = RegExBuilder(withPattern: "a[bc]d")
        let tape    = StringTape(string: "addefg")
        let machine = NPDAutomaton(withTape: tape)
        let compiled = reg.compile(machine: machine)
        XCTAssert(compiled)
        let accepting = machine.run()
        XCTAssertEqual(accepting, false)
        XCTAssertEqual(tape.position, 0)
        XCTAssertEqual(machine.matchPos, nil)
    }
}
