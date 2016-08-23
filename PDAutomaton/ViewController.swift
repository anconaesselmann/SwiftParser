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
    @IBOutlet weak var nsRegExButton: NSButton!
    @IBOutlet weak var nfaButton: NSButton!
    
    var currentExpressionMatchingFunction:((String,String) -> String?)!

    @IBAction func selectRegexAction(_ sender: NSButton) {
        if nsRegExButton.state == 1 {
            currentExpressionMatchingFunction = matchUsingNSRegularExpression
        } else if nfaButton.state == 1 {
            currentExpressionMatchingFunction = matchUsingMyRegExEngine
        }
    }
    
    var re = RegEx()

    override func viewDidLoad() {
        super.viewDidLoad()
        matchLabel.stringValue = ""
        matchStatus.stringValue = ""
        
        currentExpressionMatchingFunction = matchUsingMyRegExEngine
        nfaButton.state = 1
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
        let timeElapsed = round((CFAbsoluteTimeGetCurrent() - startTime) * 10000) / 10000
        matchLabel.stringValue = "Time: \(timeElapsed) seconds"
    }
    
    func matchUsingMyRegExEngine(expression:String, content: String) -> String? {
        print("Using Automatons")
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
    func matchUsingNSRegularExpression(expression: String, content: String) -> String? {
        do {
            print("Using NSRegularExpression")
            let regex = try NSRegularExpression(pattern: expression, options: [])
            let nsString = content as NSString
            let results = regex.matches(in: content, range: NSMakeRange(0, nsString.length))
            for match in results {
                let range = match.rangeAt(0)
                let startIndex = content.index(content.startIndex, offsetBy: range.location)
                let endIndex = content.index(startIndex, offsetBy: range.length)
                return content.substring(with: startIndex..<endIndex)
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return nil
        }
        return nil
    }

}

