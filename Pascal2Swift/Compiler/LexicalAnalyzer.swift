//
//  LexicalAnalyzer.swift
//  Pascal2Swift
//
//  Created by Mateus Kamoei on 16/05/20.
//  Copyright © 2020 Kobethon. All rights reserved.
//

import Foundation

class LexicalAnalyzer {
    
    enum LexicalAnalyzerError: Error {
        case invalidToken
    }
    
    static let keywords = ["program", "var", "begin", "end", "if", "then", "else", "integer", "string"]
    
    var tokens: [Token] = []
    var current: Character?
    var error: LexicalAnalyzerError?
    
    init(text: String) {
        
        var value = ""
        var isStringLiteral = false
        
        for (index, c) in text.enumerated() {
            if c == "\"" {
                if isStringLiteral {
                    value += String(c)
                    createToken(value: value)
                    value = ""
                    continue
                }
                isStringLiteral = !isStringLiteral
            } else if !isStringLiteral {
                if c.isWhitespace || c.isNewline {
                    createToken(value: value)
                    value = ""
                    continue
                } else if let char = text.characterAt(index: index + 1), c == ":" && char != "=" {
                    createToken(value: value)
                    createToken(value: String(c))
                    value = ""
                    continue
                } else if c == ";" || c == "," || c == "." {
                    createToken(value: value)
                    createToken(value: String(c))
                    value = ""
                    continue
                }
            }
            
            value += String(c)
        }
        
        if !value.isEmpty {
            createToken(value: value)
        }
    }
}

private extension LexicalAnalyzer {
    
    func createToken(value: String) {
        guard !value.isEmpty else { return }
        
        if let _ = Int(value) {
            let token = Token(type: .literal(.integer), value: value)
            tokens.append(token)
        } else if value[value.startIndex] == "\"" && value[value.index(value.endIndex, offsetBy: -1)..<value.endIndex] == "\"" {
            let startIndex = value.index(value.startIndex, offsetBy: 1)
            let token = Token(type: .literal(.string), value: String(value[startIndex..<value.endIndex]))
            tokens.append(token)
        } else if value.starts(with: "//") {
            let token = Token(type: .comment, value: value)
            tokens.append(token)
        } else if value == ";" || value == "," || value == ":" || value == "." {
            let token = Token(type: .separator, value: value)
            tokens.append(token)
        } else if LexicalAnalyzer.keywords.contains(value) {
            let token = Token(type: .keyword, value: value)
            tokens.append(token)
        } else if value == "+" || value == "-" || value == "*" || value == "/" {
            let token = Token(type: .operation, value: value)
            tokens.append(token)
        } else if value == "=" || value == "<" || value == ">" {
            let token = Token(type: .comparison, value: value)
            tokens.append(token)
        } else if value == ":=" {
            let token = Token(type: .assignment, value: value)
            tokens.append(token)
        } else if value.filter({ !$0.isLetter }).count == 0 {
            let token = Token(type: .identifier, value: value)
            tokens.append(token)
        } else {
            error = .invalidToken
        }
    }
}
