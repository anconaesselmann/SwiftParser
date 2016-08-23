//
//  ViewController.swift
//  PDAutomaton
//
//  Created by Axel Ancona Esselmann on 8/10/16.
//  Copyright © 2016 Axel Ancona Esselmann. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var regExPattern: NSTextField!
    @IBOutlet weak var result: NSTextField!
    @IBOutlet weak var matchLabel: NSTextField!
    @IBOutlet weak var matchStatus: NSTextField!
    
    var currentExpressionMatchingFunction:((String,String) -> String?)!

    
    var re = RegEx()

    override func viewDidLoad() {
        super.viewDidLoad()
        matchLabel.stringValue = ""
        matchStatus.stringValue = ""
        currentExpressionMatchingFunction = matchUsingMyRegExEngine
        textView.textStorage?.append(NSAttributedString(string:"Phone: (626) 344-9785"))
    }

    @IBAction func search(_ sender: AnyObject) {
        let content = (textView.textStorage as NSAttributedString!).string
        
        let startTime = CFAbsoluteTimeGetCurrent()
        if let match = currentExpressionMatchingFunction(regExPattern.stringValue, content) {
            result.stringValue = match
            matchStatus.stringValue = "match found"
        } else {
            result.stringValue = ""
            matchStatus.stringValue = "no match"
        }
        let timeElapsed = round((CFAbsoluteTimeGetCurrent() - startTime) * 1000) / 1000
        matchLabel.stringValue = "Time: \(timeElapsed) seconds"
    }
    
    func matchUsingMyRegExEngine(expression:String, content: String) -> String? {
        re.pattern = expression
        if let match = re.match(subject: content) {
            let startIndex = content.index(content.startIndex, offsetBy: match)
            let endIndex   = content.index(startIndex, offsetBy: re.matchLength)
            let subString  = content.substring(with: startIndex..<endIndex)
            print(subString)
            return subString
        }
        return nil
    }

}

