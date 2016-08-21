import XCTest
@testable import PDAutomaton

class PDAutomatonTests: XCTestCase {
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
        initial.append(transition: transition)
        
        let machine = FSMachine(withTape: tape)
        machine.append(state: initial)
        machine.append(state: final)
        let accepting = machine.run()
        XCTAssert(accepting == true)
    }
    func testTransitionMultipleChars() {
        let input = "abcde"
        let tape = StringTape(string: input)
        let machine = FSMachine(withTape: tape)
        
        let a = CharToken(char: "a")
        let b = CharToken(char: "b")
        let c = CharToken(char: "c")
        let d = CharToken(char: "d")
        
        let initial = State();
        let s1 = State();
        let s2 = State(accepting: true);
        let s3 = State();
        let final = State(accepting: true);
        initial.append(transition: Transition(targetState: s1, trigger:a))
        
        s1.append(transition: Transition(targetState: s2, trigger:b))
        s2.append(transition: Transition(targetState: s3, trigger:c))
        
        s3.append(transition: Transition(targetState: final, trigger:d))
        
        machine.append(state: initial)
        machine.append(state: s1)
        machine.append(state: s2)
        machine.append(state: s3)
        machine.append(state: final)
        
        XCTAssert(machine.step())
        XCTAssert(machine.currentState!.accepting == false)
        XCTAssert(machine.step())
        XCTAssert(machine.currentState!.accepting == true)
        XCTAssert(machine.step())
        XCTAssert(machine.currentState!.accepting == false)
        XCTAssert(machine.step())
        XCTAssert(machine.currentState!.accepting == true)
        XCTAssertEqual(machine.step(), false)
        XCTAssert(machine.accepting == true)
    }
    
    func testNestedMachines() {
        let tape    = StringTape(string: "abcdefg")
        let machineB = PDAutomaton(withTape: tape)
        
        let initialB = State();
        let s1B = State();
        let s2B = State();
        let finalB = State(accepting: true);
        
        let machineA = PDAutomaton(withTape: tape)
        
        let c = CharToken(char: "c")
        let d = CharToken(char: "d")
        let e = CharToken(char: "e")
        
        initialB.append(transition: Transition(targetState: s1B, trigger:c))
        s1B.append(transition: Transition(targetState: s2B, trigger:d))
        s2B.append(transition: Transition(targetState: finalB, trigger:e))
        
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
        
        initialA.append(transition: Transition(targetState: s1A, trigger:a))
        
        s1A.append(transition: Transition(targetState: s2A, trigger:b))
        s2A.append(transition: Transition(targetState: s3A, trigger:machineB))
        s3A.append(transition: Transition(targetState: s4A, trigger:f))
        s4A.append(transition: Transition(targetState: finalA, trigger:g))
        
        machineA.append(state: initialA)
        machineA.append(state: s1A)
        machineA.append(state: s2A)
        machineA.append(state: s3A)
        machineA.append(state: s4A)
        machineA.append(state: finalA)
        
        XCTAssert(machineA.step())
        XCTAssert(machineA.currentState!.accepting == false)
        XCTAssert(machineA.step())
        XCTAssert(machineA.currentState!.accepting == false)
        XCTAssert(machineA.step())
        XCTAssert(machineA.currentState!.accepting == false)
        XCTAssert(machineA.step())
        XCTAssert(machineA.currentState!.accepting == false)
        XCTAssert(machineA.step())
        XCTAssert(machineA.currentState!.accepting == true)
        XCTAssert(machineA.step() == false)
        
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
}
