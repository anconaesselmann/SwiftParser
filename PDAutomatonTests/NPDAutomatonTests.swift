import XCTest
@testable import PDAutomaton

class NPDAutomatonTests: XCTestCase {
    func testTransitionMultipleChars() {
        let input = "abcde"
        let tape = StringTape(string: input)
        let machine = NFAutomaton(withTape: tape)
        
        let a = CharToken(char: "a")
        let b = CharToken(char: "b")
        let c = CharToken(char: "c")
        let d = CharToken(char: "d")
        
        let initial = State();
        let s1 = State();
        let s2 = State(accepting: true);
        let s3 = State();
        let final = State(accepting: true);
        initial.append(transition: NTransition(targetState: s1, trigger:a))
        
        s1.append(transition: NTransition(targetState: s2, trigger:b))
        s2.append(transition: NTransition(targetState: s3, trigger:c))
        s3.append(transition: NTransition(targetState: final, trigger:d))
        
        machine.append(state: initial)
        machine.append(state: s1)
        machine.append(state: s2)
        machine.append(state: s3)
        machine.append(state: final)
        
        print(machine)

        XCTAssert(machine.step())
        XCTAssert(machine.accepting == false)
        XCTAssert(machine.step())
        XCTAssert(machine.accepting == true)
        XCTAssert(machine.step())
        XCTAssert(machine.accepting == false)
        XCTAssert(machine.step())
        XCTAssert(machine.accepting == true)
        XCTAssertEqual(machine.step(), false)
        
        machine.reset()
        machine.tape.position = 0
        
        XCTAssert(machine.accepting == false)
        XCTAssert(machine.run() == true)
        XCTAssert(machine.accepting == true)
    }
    
    func testRegExStateBuilder() {
        let reg     = RegExBuilder(regExString: "abcd")
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
        let reg     = RegExBuilder(regExString: "abcd")
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
        let reg     = RegExBuilder(regExString: "abcd")
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
        let reg     = RegExBuilder(regExString: "abcd")
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
    
    
    func testNestedMachines() {
        let tape    = StringTape(string: "abcdefg")
        let machineB = NPDAutomaton(withTape: tape)
        
        let initialB = State();
        let s1B = State();
        let s2B = State();
        let finalB = State(accepting: true);
        
        let machineA = NPDAutomaton(withTape: tape)
        
        let c = CharToken(char: "c")
        let d = CharToken(char: "d")
        let e = CharToken(char: "e")
        
        initialB.append(transition: NTransition(targetState: s1B, trigger:c))
        s1B.append(transition: NTransition(targetState: s2B, trigger:d))
        s2B.append(transition: NTransition(targetState: finalB, trigger:e))
        
        machineB.append(state: initialB)
        machineB.append(state: s1B)
        machineB.append(state: s2B)
        machineB.append(state: finalB)
        
        
        let initialA = State();
        let s1A = State()
        let s2A = State()
        let s3A = State()
        let s4A = State()
        let finalA = State(accepting: true)
        
        let a = CharToken(char: "a")
        let b = CharToken(char: "b")
        let f = CharToken(char: "f")
        let g = CharToken(char: "g")
        
        initialA.append(transition: NTransition(targetState: s1A, trigger:a))
        
        s1A.append(transition: NTransition(targetState: s2A, trigger:b))
        s2A.append(transition: NTransition(targetState: s3A, trigger:machineB))
        s3A.append(transition: NTransition(targetState: s4A, trigger:f))
        s4A.append(transition: NTransition(targetState: finalA, trigger:g))
        
        machineA.append(state: initialA)
        machineA.append(state: s1A)
        machineA.append(state: s2A)
        machineA.append(state: s3A)
        machineA.append(state: s4A)
        machineA.append(state: finalA)
        
        XCTAssert(machineA.step())
        XCTAssert(machineA.accepting == false)
        XCTAssert(machineA.step())
        XCTAssert(machineA.accepting == false)
        XCTAssert(machineA.step())
        XCTAssert(machineA.accepting == false)
        XCTAssert(machineA.step())
        XCTAssert(machineA.accepting == false)
        XCTAssert(machineA.step())
        XCTAssert(machineA.accepting == true)
        XCTAssertEqual(machineA.step(), false)
        XCTAssert(machineA.accepting == true)
        
        machineA.tape.position = 0
        
        XCTAssertEqual(machineA.accepting, false)
        XCTAssert(machineA.run())
        XCTAssertEqual(machineA.accepting, true)
        XCTAssertEqual(machineA.tape.position, 7)
        
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
        let machine = NPDAutomaton(withTape: tape)
        let compiled = reg.compile(machine: machine)
        XCTAssert(compiled)
        let accepting = machine.run()
        XCTAssertEqual(accepting, true)
        XCTAssertEqual(tape.position, 3)
        XCTAssertEqual(machine.matchPos, 0)
    }
    
    func testRegExStateBuilder_testOrWithExplicitCharacters_failing() {
        let reg     = RegExBuilder(regExString: "a[bc]d")
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
