//
//  Interpreter.swift
//  Pascal2Swift
//
//  Created by Mateus Kamoei on 16/05/20.
//  Copyright © 2020 Kobethon. All rights reserved.
//

import Foundation

class Interpreter {
    
    var integers = [String: Int?]()
    var strings = [String: String?]()
    
    init(table: [Symbol], program: Program) {
        
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
                var result = 0
                if case .identifier = expression.leftSide.type, let value = integers[expression.leftSide.value] {
                    result = value ?? 0
                } else {
                    result = Int(expression.leftSide.value) ?? 0
                }
                if let operation = expression.operation, let rightSide = expression.rightSide {
                    var right = 0
                    if case .identifier = rightSide.type, let value = integers[rightSide.value] {
                        right = value ?? 0
                    } else {
                        right = Int(rightSide.value) ?? 0
                    }
                    
                    if operation.value == "+" {
                        result += right
                    } else if operation.value == "-" {
                        result -= right
                    } else if operation.value == "*" {
                        result *= right
                    } else if operation.value == "/" {
                        result /= right
                    }
                }
                integers[assignment.receiver.value] = result
                print("\(integers)")
            }
        }
    }
}
