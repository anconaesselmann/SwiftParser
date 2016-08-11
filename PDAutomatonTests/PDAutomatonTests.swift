import XCTest
@testable import PDAutomaton

class PDAutomatonTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testEqualityCharToken() {
        let a1 = CharToken(char: "a")
        let a2 = CharToken(char: "a")
        let b  = CharToken(char: "b")
        
        XCTAssert(a1 == a1)
        XCTAssert(a1 == a2)
        XCTAssert(a1 != b)
    }
    func testGetCharacterFromStringTape() {
        let input = "abcde"
        let tape = StringTape(string: input)
        
        let a = CharToken(char: "a")
        let b = CharToken(char: "b")
        XCTAssert(tape.get() as! CharToken == a)
        tape.advance()
        XCTAssert(tape.get() as! CharToken == b)
    }
    
    func testTransitionSingeChar() {
        let input = "abcde"
        let tape = StringTape(string: input)
        
        let a = CharToken(char: "a")
        
        let initial = State();
        let final = State(accepting: true);
        let transition = Transition(targetState: final, trigger:a)
        initial.addTransition(transition: transition)
        
        let machine = FSMachine(name: "a recognizer", tape: tape)
        machine.addState(state: initial)
        machine.addState(state: final)
        let accepting = machine.run()
        XCTAssert(accepting == true)
    }
    func testTransitionMultipleChars() {
        let input = "abcde"
        let tape = StringTape(string: input)
        let machine = FSMachine(name: "a recognizer", tape: tape)
        
        let a = CharToken(char: "a")
        let b = CharToken(char: "b")
        let c = CharToken(char: "c")
        let d = CharToken(char: "d")
        
        let initial = State();
        let s1 = State();
        let s2 = State(accepting: true);
        let s3 = State();
        let final = State(accepting: true);
        initial.addTransition(transition: Transition(targetState: s1, trigger:a))
        
        s1.addTransition(transition: Transition(targetState: s2, trigger:b))
        s2.addTransition(transition: Transition(targetState: s3, trigger:c))
        
        s3.addTransition(transition: Transition(targetState: final, trigger:d))
        
        machine.addState(state: initial)
        machine.addState(state: s1)
        machine.addState(state: s2)
        machine.addState(state: s3)
        machine.addState(state: final)
        
        XCTAssert(machine.step()!.accepting == false)
        XCTAssert(machine.step()!.accepting == true)
        XCTAssert(machine.step()!.accepting == false)
        XCTAssert(machine.step()!.accepting == true)
        
        XCTAssert(machine.accepting == true)
    }
    
    func testRegExStateBuilder() {
        let reg     = RegExBuilder(regExString: "abcd")
        let tape    = StringTape(string: "abcdefg")
        let machine = PDAutomaton(name: "abcd", tape: tape)
        reg.compile(machine: machine)
        let accepting = machine.run()
        XCTAssertEqual(accepting, true)
        XCTAssertEqual(tape.position, 4)
    }
    func testRegExStateBuilderRunTwice() {
        let reg     = RegExBuilder(regExString: "abcd")
        let tape    = StringTape(string: "abcdabcd")
        let machine = PDAutomaton(name: "abcd", tape: tape)
        reg.compile(machine: machine)
        var accepting = machine.run()
        XCTAssert(machine.accepting == true)
        XCTAssert(tape.position == 4)
        XCTAssertEqual(machine.step()!.accepting, false)
        accepting = machine.run()
        XCTAssertEqual(accepting, true)
        XCTAssertEqual(tape.position, 8)
    }
    
    func testRegExStateBuilder_resetWhenNotMatching() {
        let reg     = RegExBuilder(regExString: "abcd")
        let tape    = StringTape(string: "abcefg")
        let machine = PDAutomaton(name: "abcd", tape: tape)
        reg.compile(machine: machine)
        let accepting = machine.run()
        XCTAssertEqual(accepting, false)
        XCTAssertEqual(tape.position, 0)
    }
    
    func testRegExStateBuilderTapeNotAtBeginning_resetWhenNotMatching() {
        let reg     = RegExBuilder(regExString: "abcd")
        let tape    = StringTape(string: "ababce")
        tape.position = 2
        let machine = PDAutomaton(name: "abcd", tape: tape)
        reg.compile(machine: machine)
        let accepting = machine.run()
        XCTAssertEqual(accepting, false)
        XCTAssertEqual(tape.position, 2)
        print(machine)
    }
    
    
    func testNestedMachines() {
        let tape    = StringTape(string: "abcdefg")
        let machineB = PDAutomaton(name: "child", tape: tape)
        
        let initialB = State();
        let s1B = State();
        let s2B = State();
        let finalB = State(accepting: true);
        
        let machineA = PDAutomaton(name: "parent", tape: tape)
        
        let c = CharToken(char: "c")
        let d = CharToken(char: "d")
        let e = CharToken(char: "e")
        
        initialB.addTransition(transition: Transition(targetState: s1B, trigger:c))
        s1B.addTransition(transition: Transition(targetState: s2B, trigger:d))
        s2B.addTransition(transition: Transition(targetState: finalB, trigger:e))
        
        machineB.addState(state: initialB)
        machineB.addState(state: s1B)
        machineB.addState(state: s2B)
        machineB.addState(state: finalB)
        
        
        let initialA = State();
        let s1A = State();
        let s2A = State();
        let s3A = State();
        let s4A = State();
        let finalA = State(accepting: true);
        
        let a = CharToken(char: "a")
        let b = CharToken(char: "b")
        let f = CharToken(char: "f")
        let g = CharToken(char: "g")
        
        initialA.addTransition(transition: Transition(targetState: s1A, trigger:a))
        
        s1A.addTransition(transition: Transition(targetState: s2A, trigger:b))
        s2A.addTransition(transition: Transition(targetState: s3A, trigger:machineB))
        s3A.addTransition(transition: Transition(targetState: s4A, trigger:f))
        s4A.addTransition(transition: Transition(targetState: finalA, trigger:g))
        
        machineA.addState(state: initialA)
        machineA.addState(state: s1A)
        machineA.addState(state: s2A)
        machineA.addState(state: s3A)
        machineA.addState(state: s4A)
        machineA.addState(state: finalA)
        
        print(machineA)
        XCTAssert(machineA.step()!.accepting == false)
        XCTAssert(machineA.step()!.accepting == false)
        XCTAssert(machineA.step()!.accepting == false)
        XCTAssert(machineA.step()!.accepting == false)
        XCTAssert(machineA.step()!.accepting == true)
        
        XCTAssert(machineA.accepting == true)
        
        tape.string = "bcdefga"
        machineA.tape = tape
        XCTAssertEqual(machineA.run(), false)
        tape.string = "acdefga"
        machineA.tape = tape
        XCTAssertEqual(machineA.run(), false)
        tape.string = "abdefga"
        machineA.tape = tape
        XCTAssertEqual(machineA.run(), false)
        tape.string = "abcefga"
        machineA.tape = tape
        XCTAssertEqual(machineA.run(), false)
        tape.string = "abcdfga"
        machineA.tape = tape
        XCTAssertEqual(machineA.run(), false)
        tape.string = "abcdega"
        machineA.tape = tape
        XCTAssertEqual(machineA.run(), false)
        tape.string = "abcdefa"
        machineA.tape = tape
        XCTAssertEqual(machineA.run(), false)
        tape.string = "abcdefg"
        machineA.tape = tape
        XCTAssert(machineA.run())
        XCTAssert(machineA.accepts(input: "abcefg"))
    }
    
    func testRegExStateBuilder_testOrWithExplicitCharacters() {
        let reg     = RegExBuilder(regExString: "a[bc]d")
        let tape    = StringTape(string: "abdefg")
        let machine = PDAutomaton(name: "abd", tape: tape)
        reg.compile(machine: machine)
        print(machine)
        let accepting = machine.run()
        XCTAssertEqual(accepting, true)
        XCTAssertEqual(tape.position, 3)
    }
    
    func testRegExStateBuilder_testOrWithExplicitCharacters_failing() {
        let reg     = RegExBuilder(regExString: "a[bc]d")
        let tape    = StringTape(string: "addefg")
        let machine = PDAutomaton(name: "add", tape: tape)
        reg.compile(machine: machine)
        print(machine)
        let accepting = machine.run()
        XCTAssertEqual(accepting, false)
        XCTAssertEqual(tape.position, 0)
    }
    
    
    
    //    func testRegExStateBuilder_square_brackets_characters() {
    //        let reg     = RegExBuilder(regExString: "a[bc]d")
    //        let tape    = StringTape(string: "abdfg")
    //        let machine = FSMachine(name: "abcd", tape: tape)
    //        reg.compile(machine: machine)
    //        print(machine)
    //        var accepting = machine.run()
    //        XCTAssertEqual(accepting, true)
    //        XCTAssertEqual(tape.position, 3)
    //        tape.string = "acdfg"
    //        accepting = machine.run()
    //        XCTAssertEqual(accepting, true)
    //        XCTAssertEqual(tape.position, 3)
    //        tape.string = "addfg"
    //        accepting = machine.run()
    //        XCTAssertEqual(accepting, false)
    //        XCTAssertEqual(tape.position, 0)
    //    }
    
    
}
