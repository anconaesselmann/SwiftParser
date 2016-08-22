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
    
    var re = RegEx()

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.textStorage?.append(NSAttributedString(string:"Phone: (626) 344-9785"))

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func search(_ sender: AnyObject) {
        let content = (textView.textStorage as NSAttributedString!).string
        
        re.pattern = regExPattern.stringValue
        if let match = re.match(subject: content) {
            let startIndex = content.index(content.startIndex, offsetBy: match)
            let endIndex   = content.index(startIndex, offsetBy: re.matchLength)
            let subString = content.substring(with: startIndex..<endIndex)
            print(subString)
            result.stringValue = subString
        }
        
    }

}

