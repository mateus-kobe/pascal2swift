//
//  Interpreter.swift
//  Pascal2Swift
//
//  Created by Mateus Kamoei on 16/05/20.
//  Copyright © 2020 Kobethon. All rights reserved.
//

import Foundation
import UIKit

class Interpreter {
    
    let console: UITextView
    
    var integers = [String: Int?]()
    var strings = [String: String?]()
    
    init(table: [Symbol], program: Program, console: UITextView) {
        self.console = console
        
        for symbol in table {
            if case .integer = symbol.type {
                integers[symbol.name] = nil
            }
            
            if case .string = symbol.type {
                strings[symbol.name] = nil
            }
        }
        print("\(integers.description)")
        
        for instruction in program.block.instructions {
            if let assignment = instruction.assignment {
                let expression = assignment.expression
                if let result = resolveExpression(expression) as? Int {
                    integers[assignment.receiver.value] = result
                }
                print("\(integers)")
            } else if let function = instruction.function {
                if function.name.value == "write" {
                    if let expression = function.parameter {
                        let result = resolveExpression(expression)
                        console.text += "\(result ?? "")\n"
                    }
                }
            }
        }
    }
    
    func resolveExpression(_ expression: Expression) -> Any? {
        var result: Any?
        result = resolveToken(expression.leftSide)
        
        if let operation = expression.operation, let rightSide = expression.rightSide {
            let right = resolveToken(rightSide)
            
            if result is String && right is String && operation.value == "+" {
                return "\(result!)\(right!)"
            } else if result is Int && right is Int {
                let int1 = result as! Int
                let int2 = right as! Int
                if operation.value == "+" {
                     return int1 + int2
                } else if operation.value == "-" {
                    return int1 - int2
                } else if operation.value == "*" {
                    return int1 * int2
                } else if operation.value == "/" {
                    return int1 / int2
                }
            }
        }
        
        return result
    }
    
    func resolveToken(_ token: Token) -> Any? {
        var result: Any?
        if case .identifier = token.type {
            if let integer = integers[token.value] {
                result = integer
            } else if let string = strings[token.value] {
                result = string
            }
        } else if case let .literal(type) = token.type {
            if type == .integer {
                result = Int(token.value)
            } else {
                result = token.value
            }
        }
        return result
    }
}
