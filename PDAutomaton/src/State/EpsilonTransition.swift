//
//  EpsylonTransition.swift
//  PDAutomaton
//
//  Created by Axel Ancona Esselmann on 8/18/16.
//  Copyright © 2016 Axel Ancona Esselmann. All rights reserved.
//

import Foundation

class EpsilonTransition:TransitionProtocol {
    var targetState:State!
    init(targetState state:NState) {
        targetState = state
    }
}
extension EpsilonTransition:CustomStringConvertible {
    var description: String {
        return "Trigger 'Epsylon' -> State '\(targetState.id!)'"
    }
}
