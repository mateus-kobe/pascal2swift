//
//  SemanticalAnalyzer.swift
//  Pascal2Swift
//
//  Created by Mateus Kamoei on 16/05/20.
//  Copyright © 2020 Kobethon. All rights reserved.
//

import Foundation

enum SymbolType {
    case integer
    case string
    case function
}

struct Symbol {
    let name: String
    let type: SymbolType
    let value: Any?
}

class SemanticalAnalyzer {
    
    enum SemanticalAnalyzerError: Error {
        case undeclaredVariable
        case typeMismatch
    }
    
    var table = [Symbol]()
    var error: SemanticalAnalyzerError?
    
    init(program: Program) {
        let writeFunction = Symbol(name: "write", type: .function, value: nil)
        let readFunction = Symbol(name: "read", type: .function, value: nil)
        
        table.append(writeFunction)
        table.append(readFunction)
        
        if let declaration = program.declaration {
            for string in declaration.stringVariables {
                table.append(Symbol(name: string.value, type: .string, value: nil))
            }
            
            for integer in declaration.integerVariables {
                table.append(Symbol(name: integer.value, type: .integer, value: nil))
            }
        }
        
        for instruction in program.block.instructions {
            if let assignment = instruction.assignment {
                checkExistenceInTable(token: assignment.receiver)
                
                let expression = assignment.expression
                checkExpression(expression)
            } else if let function = instruction.function {
                checkExistenceInTable(token: function.name)
                if let expression = function.parameter {
                    checkExpression(expression)
                }
            }
        }
    }
    
    func checkExpression(_ expression: Expression) {
        if case .identifier = expression.leftSide.type {
            checkExistenceInTable(token: expression.leftSide)
        }
        
        if let rightSide = expression.rightSide, case .identifier = rightSide.type {
            checkExistenceInTable(token: rightSide)
        }
    }
    
    func checkExistenceInTable(token: Token) {
        if !table.map({ $0.name }).contains(token.value) {
            error = .undeclaredVariable
        }
    }
    
    func typeCheck(token1: Token, token2: Token) {
        
    }
}
