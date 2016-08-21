import XCTest
@testable import PDAutomaton

class NFAutomatonTest: XCTestCase {
    var nfa:NFAutomaton!
    
    override func setUp() {
        super.setUp()
        nfa = NFAutomaton()
    }
    
    func test_followOneEpsilonFromInitialState() {
        let s1 = State()
        let s2 = State()
        let epsilon = EpsilonTransition(targetState: s2)
        s1.append(transition: epsilon)
        nfa.append(state: s1)
        nfa.append(state: s2)
        nfa.reset()
        XCTAssertEqual(nfa.currentStates.count, 2)
        XCTAssert(nfa.currentStates["\(s1.id)_0"]?.state === s1)
        XCTAssert(nfa.currentStates["\(s2.id)_0"]?.state === s2)
    }
    func test_followCircularEpsilonTransitionsFromInitialState() {
        let s1 = State()
        let s2 = State()
        let s3 = State()
        let e1_2 = EpsilonTransition(targetState: s2)
        let e2_3 = EpsilonTransition(targetState: s3)
        let e3_2 = EpsilonTransition(targetState: s2)
        s1.append(transition: e1_2)
        s2.append(transition: e2_3)
        s3.append(transition: e3_2)
        nfa.append(state: s1)
        nfa.append(state: s2)
        nfa.append(state: s3)
        nfa.reset()
        XCTAssertEqual(nfa.currentStates.count, 3)
        XCTAssert(nfa.currentStates["\(s1.id)_0"]?.state === s1)
        XCTAssert(nfa.currentStates["\(s2.id)_0"]?.state === s2)
        XCTAssert(nfa.currentStates["\(s3.id)_0"]?.state === s3)
    }
    
    func test_followCircularEpsilonTransitionsFromInitialState_withBranching() {
        let s1 = State()
        let s2 = State()
        let s3 = State()
        let s4 = State()
        let s5 = State()
        let e1_2 = EpsilonTransition(targetState: s2)
        let e2_3 = EpsilonTransition(targetState: s3)
        let e3_2 = EpsilonTransition(targetState: s2)
        let e2_4 = EpsilonTransition(targetState: s4)
        let e4_5 = EpsilonTransition(targetState: s5)
        s1.append(transition: e1_2)
        s2.append(transition: e2_3)
        s3.append(transition: e3_2)
        s2.append(transition: e2_4)
        s4.append(transition: e4_5)
        nfa.append(state: s1)
        nfa.append(state: s2)
        nfa.append(state: s3)
        nfa.append(state: s4)
        nfa.append(state: s5)
        nfa.reset()
        XCTAssertEqual(nfa.currentStates.count, 5)
        XCTAssert(nfa.currentStates["\(s1.id)_0"]?.state === s1)
        XCTAssert(nfa.currentStates["\(s2.id)_0"]?.state === s2)
        XCTAssert(nfa.currentStates["\(s3.id)_0"]?.state === s3)
        XCTAssert(nfa.currentStates["\(s4.id)_0"]?.state === s4)
        XCTAssert(nfa.currentStates["\(s5.id)_0"]?.state === s5)
    }
    
    func test_regularAndEpsilonTransitons() {
        let tape = StringTape(string: "aba")
        nfa.tape = tape
        
        let s1 = State()
        let s2 = State()
        let s3 = State()
        let s4 = State(accepting: true)
        
        let a = CharToken(char: "a")
        let b = CharToken(char: "b")
        
        let t_to2_withA = NTransition(targetState: s2, trigger: a)
        let t_to2_withB = NTransition(targetState: s2, trigger: b, withMax: Int.max)
        let t_epsilon   = EpsilonTransition(targetState: s3)
        let t_to4_withB = NTransition(targetState: s4, trigger: b)
        
        s1.append(transition: t_to2_withA)
        s2.append(transition: t_to2_withB)
        s2.append(transition: t_epsilon)
        s3.append(transition: t_to4_withB)
        
        nfa.append(state: s1)
        nfa.append(state: s2)
        nfa.append(state: s3)
        nfa.append(state: s4)
        
        XCTAssertEqual(nfa.states.count, 4)
        
        nfa.reset()
        XCTAssertEqual(nfa.currentStates.count, 1)
        XCTAssert(nfa.currentStates["\(s1.id)_0"]?.state === s1)
        
        var stepSuccess = nfa.step()
    
        XCTAssert(stepSuccess)
        XCTAssertEqual(nfa.tape.position, 1)
        XCTAssertEqual(nfa.currentStates.count, 2)
        XCTAssert(nfa.currentStates["\(s2.id)_0"]?.state === s2)
        XCTAssert(nfa.currentStates["\(s3.id)_0"]?.state === s3)
        
        stepSuccess = nfa.step()
        
        XCTAssert(stepSuccess)
        XCTAssertEqual(nfa.tape.position, 2)
        XCTAssertEqual(nfa.currentStates.count, 3)
        XCTAssert(nfa.currentStates["\(s2.id)_1"]?.state === s2)
        XCTAssert(nfa.currentStates["\(s3.id)_0"]?.state === s3)
        XCTAssert(nfa.currentStates["\(s4.id)_0"]?.state === s4)
        
        stepSuccess = nfa.step()
        
        XCTAssertEqual(stepSuccess, false)
        XCTAssertEqual(nfa.tape.position, 2)
        XCTAssertEqual(nfa.currentStates.count, 0)
        XCTAssertEqual(nfa.accepting, false)
        
        nfa.reset()
        nfa.tape.position = 0
        
        let runSuccess = nfa.run()
        XCTAssert(runSuccess)
        XCTAssertEqual(nfa.matchPos, 0)
        XCTAssertEqual(nfa.tape.position, 2)
    }
    
    func test_epsilonWithMin() {
        let tape = StringTape(string: "abbc")
        nfa.tape = tape
        
        let s1 = State()
        let s2 = State()
        let s3 = State()
        let s4 = State(accepting: true)
        
        let a = CharToken(char: "a")
        let b = CharToken(char: "b")
        
        let t_to2_withA = NTransition(targetState: s2, trigger: a)
        let t_to2_withB = NTransition(targetState: s2, trigger: b, withMax: Int.max)
        let t_epsilon   = EpsilonTransition(targetState: s3, withMin: 1)
        let t_to4_withB = NTransition(targetState: s4, trigger: b)
        
        s1.append(transition: t_to2_withA)
        s2.append(transition: t_to2_withB)
        s2.append(transition: t_epsilon)
        s3.append(transition: t_to4_withB)
        
        nfa.append(state: s1)
        nfa.append(state: s2)
        nfa.append(state: s3)
        nfa.append(state: s4)
        
        XCTAssertEqual(nfa.states.count, 4)
        
        nfa.reset()
        XCTAssertEqual(nfa.currentStates.count, 1)
        XCTAssert(nfa.currentStates["\(s1.id)_0"]?.state === s1)
        
        var stepSuccess = nfa.step()
        
        XCTAssert(stepSuccess)
        XCTAssertEqual(nfa.tape.position, 1)
        XCTAssertEqual(nfa.currentStates.count, 1)
        XCTAssert(nfa.currentStates["\(s2.id)_0"]?.state === s2)
        
        stepSuccess = nfa.step()
        
        XCTAssert(stepSuccess)
        XCTAssertEqual(nfa.tape.position, 2)
        XCTAssertEqual(nfa.currentStates.count, 2)
        XCTAssert(nfa.currentStates["\(s2.id)_1"]?.state === s2)
        XCTAssert(nfa.currentStates["\(s3.id)_0"]?.state === s3)
        
        stepSuccess = nfa.step()
        
        XCTAssert(stepSuccess)
        XCTAssertEqual(nfa.tape.position, 3)
        XCTAssertEqual(nfa.currentStates.count, 3)
        XCTAssert(nfa.currentStates["\(s2.id)_2"]?.state === s2)
        XCTAssert(nfa.currentStates["\(s3.id)_0"]?.state === s3)
        XCTAssert(nfa.currentStates["\(s4.id)_0"]?.state === s4)
        
        stepSuccess = nfa.step()
        
        XCTAssertEqual(stepSuccess, false)
        XCTAssertEqual(nfa.tape.position, 3)
        
        nfa.reset()
        nfa.tape.position = 0
        
        let runSuccess = nfa.run()
        XCTAssert(runSuccess)
        XCTAssertEqual(nfa.matchPos, 0)
        XCTAssertEqual(nfa.tape.position, 3)
    }
    
    func test_zeroOrOne() {
        let tape = StringTape(string: "abcxxx")
        nfa.tape = tape
        
        let s1 = State()
        let s2 = State()
        let s3 = State()
        let s4 = State(accepting: true)
        
        let a = CharToken(char: "a")
        let b = CharToken(char: "b")
        let c = CharToken(char: "c")
        
        let t_to2_withA = NTransition(targetState: s2, trigger: a)
        let t_to2_withB = NTransition(targetState: s2, trigger: b, withMax: 1)
        let t_epsilon   = EpsilonTransition(targetState: s3, withMin: 0)
        let t_to4_withC = NTransition(targetState: s4, trigger: c)
        
        s1.append(transition: t_to2_withA)
        s2.append(transition: t_to2_withB)
        s2.append(transition: t_epsilon)
        s3.append(transition: t_to4_withC)
        
        nfa.append(state: s1)
        nfa.append(state: s2)
        nfa.append(state: s3)
        nfa.append(state: s4)
        
        XCTAssertEqual(nfa.states.count, 4)
        
        nfa.reset()
        XCTAssertEqual(nfa.currentStates.count, 1)
        XCTAssert(nfa.currentStates["\(s1.id)_0"]?.state === s1)
        
        var stepSuccess = nfa.step()
        
        XCTAssert(stepSuccess)
        XCTAssertEqual(nfa.tape.position, 1)
        XCTAssertEqual(nfa.currentStates.count, 2)
        XCTAssert(nfa.currentStates["\(s2.id)_0"]?.state === s2)
        XCTAssert(nfa.currentStates["\(s3.id)_0"]?.state === s3)
        
        stepSuccess = nfa.step()
        
        XCTAssert(stepSuccess)
        XCTAssertEqual(nfa.tape.position, 2)
        XCTAssertEqual(nfa.currentStates.count, 2)
        XCTAssert(nfa.currentStates["\(s2.id)_1"]?.state === s2)
        XCTAssert(nfa.currentStates["\(s3.id)_0"]?.state === s3)
        
        stepSuccess = nfa.step()
        
        XCTAssert(stepSuccess)
        XCTAssertEqual(nfa.tape.position, 3)
        XCTAssertEqual(nfa.currentStates.count, 1)
        XCTAssert(nfa.currentStates["\(s4.id)_0"]?.state === s4)
        
        
        stepSuccess = nfa.step()
        
        XCTAssertEqual(stepSuccess, false)
        XCTAssertEqual(nfa.tape.position, 3)
        XCTAssertEqual(nfa.currentStates.count, 0)
        
        nfa.reset()
        nfa.tape.position = 0
        
        var runSuccess = nfa.run()
        XCTAssertEqual(runSuccess, true)
        XCTAssertEqual(nfa.matchPos, 0)
        XCTAssertEqual(nfa.tape.position, 3)
        
        nfa.tape = StringTape(string: "abbcxxx")
        
        // failure
        XCTAssertEqual(nfa.currentStates.count, 1)
        XCTAssert(nfa.currentStates["\(s1.id)_0"]?.state === s1)
        
        stepSuccess = nfa.step()
        
        XCTAssert(stepSuccess)
        XCTAssertEqual(nfa.tape.position, 1)
        XCTAssertEqual(nfa.currentStates.count, 2)
        XCTAssert(nfa.currentStates["\(s2.id)_0"]?.state === s2)
        XCTAssert(nfa.currentStates["\(s3.id)_0"]?.state === s3)
        
        stepSuccess = nfa.step()
        
        XCTAssert(stepSuccess)
        XCTAssertEqual(nfa.tape.position, 2)
        XCTAssertEqual(nfa.currentStates.count, 2)
        XCTAssert(nfa.currentStates["\(s2.id)_1"]?.state === s2)
        XCTAssert(nfa.currentStates["\(s3.id)_0"]?.state === s3)
        
        stepSuccess = nfa.step()
        
        XCTAssertEqual(stepSuccess, false)
        XCTAssertEqual(nfa.tape.position, 2)
        XCTAssertEqual(nfa.currentStates.count, 0)
        
        nfa.reset()
        nfa.tape.position = 0
        
        runSuccess = nfa.run()
        XCTAssertEqual(runSuccess, false)
        XCTAssertEqual(nfa.matchPos, nil)
        XCTAssertEqual(nfa.tape.position, 0)
        
        nfa.tape = StringTape(string: "acxx")
        runSuccess = nfa.run()
        XCTAssertEqual(runSuccess, true)
        XCTAssertEqual(nfa.matchPos, 0)
        XCTAssertEqual(nfa.tape.position, 2)
    }

}
