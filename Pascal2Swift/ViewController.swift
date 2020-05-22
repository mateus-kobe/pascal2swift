//
//  ViewController.swift
//  Pascal2Swift
//
//  Created by Mateus Kamoei on 16/05/20.
//  Copyright © 2020 Kobethon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var programTextView: UITextView!
    @IBOutlet weak var consoleTextView: UITextView!
    
    lazy var compileButton = {
        return UIBarButtonItem(title: "Compile", style: .done, target: self, action: #selector(compile))
    }()
    
    lazy var clearButton = {
        return UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clear))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = compileButton
        navigationItem.leftBarButtonItem = clearButton
    }

    @objc func compile() {
        consoleTextView.text = ""
        programTextView.resignFirstResponder()
        
        let lexicalAnalyzer = LexicalAnalyzer(text: programTextView.text)
        if let error = lexicalAnalyzer.error {
            consoleTextView.text = "\(error)"
        } else {
            let syntacticalAnalyzer = SyntacticalAnalyzer(tokens: lexicalAnalyzer.tokens)
            if let error = syntacticalAnalyzer.error {
                consoleTextView.text = "\(error)"
            } else {
                if let program = syntacticalAnalyzer.code {
                    let semanticalAnalyzer = SemanticalAnalyzer(program: program)
                    if let error = semanticalAnalyzer.error {
                        consoleTextView.text = "\(error)"
                    } else {
                        Interpreter(table: semanticalAnalyzer.table, program: program, console: consoleTextView)
                    }
                }
            }
        }
    }
    
    @objc func clear() {
        programTextView.text = ""
    }
}

