//
//  SyntacticalAnalyzer.swift
//  Pascal2Swift
//
//  Created by Mateus Kamoei on 16/05/20.
//  Copyright © 2020 Kobethon. All rights reserved.
//

import Foundation

struct Program {
    let name: Token
    let declaration: Declaration?
    let block: Block
}

struct Declaration {
    let stringVariables: [Token]
    let integerVariables: [Token]
}

struct Block {
    let instructions: [Instruction]
}

struct Instruction {
    let assignment: Assignment?
    let ifClause: If?
    let function: Function?
}

struct Assignment {
    let receiver: Token
    let expression: Expression
}

struct If {
    let comparison: Comparison
    let ifBlock: Block
    let elseBlock: Block?
}

struct Comparison {
    let leftSide: Expression
    let comparison: Token
    let rightSide: Expression
}

struct Expression {
    let leftSide: Token
    let operation: Token?
    let rightSide: Token?
}

struct Function {
    let name: Token
    let parameter: Expression?
}

class SyntacticalAnalyzer {
    
    enum SyntacticalAnalyzerError: Error {
        case codeShouldStartWithProgram
        case programNeedsName
        case missingSeparator
        case wrongDeclarationSyntax
        case missingBlockBegin
        case missingVariableName
        case unknownInstruction
        case expressionError
        case missingBlockEnd
    }
    
    var tokens: [Token]
    var error: SyntacticalAnalyzerError?
    var code: Program?
    
    init(tokens: [Token]) {
        self.tokens = tokens
        self.code = program()
    }
    
    @discardableResult func nextToken() -> Token? {
        if !tokens.isEmpty {
            return tokens.removeFirst()
        }
        return nil
    }
    
    func program() -> Program? {
        if let program = nextToken(),
            case .keyword = program.type,
            program.value == "program" {
            
            if let name = nextToken(),
                case .identifier = name.type {
                
                var declarations: Declaration?
                
                if let separator = nextToken(),
                    case .separator = separator.type,
                    separator.value == ";" {
                    
                    if let nextToken = tokens.first,
                        case .keyword = nextToken.type,
                        nextToken.value == "var" {
                        declarations = declaration()
                        
                        if error == nil {
                            if let block = block() {
                                return Program(name: name, declaration: declarations, block: block)
                            }
                        }
                    } else {
                        if let block = block() {
                            return Program(name: name, declaration: declarations, block: block)
                        }
                    }
                } else {
                    error = .missingSeparator
                }
            } else {
                error = .programNeedsName
            }
        } else {
            error = .codeShouldStartWithProgram
        }
        return nil
    }
    
    func declaration() -> Declaration? {
        var variables = [Token]()
        
        nextToken() // consume var
        
        declaration(variables: &variables)
        
        if let type = nextToken(), case .keyword = type.type {
            guard let separator = nextToken(),
                case .separator = separator.type,
                separator.value == ";" else {
                    error = .wrongDeclarationSyntax
                    return nil
            }
            
            if type.value == "integer" {
                return Declaration(stringVariables: [], integerVariables: variables)
            } else if type.value == "string" {
                return Declaration(stringVariables: variables, integerVariables: [])
            }
        }
        
        error = .wrongDeclarationSyntax
        return nil
    }
    
    func declaration(variables: inout [Token]) {
        if let variable = nextToken(), case .identifier = variable.type {
            variables.append(variable)
            
            if let separator = nextToken(), case .separator = separator.type {
                if separator.value == "," {
                    declaration(variables: &variables)
                } else if separator.value != ":" {
                    error = .wrongDeclarationSyntax
                }
            } else {
                error = .wrongDeclarationSyntax
            }
        } else {
            error = .missingVariableName
        }
    }
    
    func block() -> Block? {
        var instructions = [Instruction]()
        
        if let next = nextToken(),
            case .keyword = next.type,
            next.value == "begin" {
            
            while let token = tokens.first {
                if case .keyword = token.type, token.value == "end" {
                    break
                }
                
                if let instruction = instruction() {
                    instructions.append(instruction)
                }
            }
            
            if let end = nextToken(), case .keyword = end.type, end.value == "end" {
                return Block(instructions: instructions)
            } else {
                error = .missingBlockEnd
            }
        } else {
            error = .missingBlockBegin
        }
        return nil
    }
    
    func instruction() -> Instruction? {
        if let next = nextToken() {
            if case .identifier = next.type {
                if let next2 = nextToken() {
                    if case .assignment = next2.type {
                        let assign = assignment(receiver: next)
                        return Instruction(assignment: assign, ifClause: nil, function: nil)
                    } else if case .separator = next2.type, next2.value == "(" {
                        let f = function(identifier: next)
                        return Instruction(assignment: nil, ifClause: nil, function: f)
                    }
                }
            } else if case .keyword = next.type, next.value == "if" {
                if let comparison = comparison(), let then = tokens.first, case .keyword = then.type, then.value == "then" {
                    nextToken()
                    if let ifBlock = block() {
                        var elseBlock: Block?
                        if let elseKey = tokens.first, case .keyword = elseKey.type, elseKey.value == "else" {
                            nextToken()
                            elseBlock = block()
                        }
                        
                        let ifClause = If(comparison: comparison, ifBlock: ifBlock, elseBlock: elseBlock)
                        return Instruction(assignment: nil, ifClause: ifClause, function: nil)
                    }
                }
            } else {
                error = .unknownInstruction
            }
        }
        return nil
    }
    
    func assignment(receiver: Token) -> Assignment? {
        if let expression = expression() {
            if let next = tokens.first, case .separator = next.type, next.value == ";" {
                nextToken()
                return Assignment(receiver: receiver, expression: expression)
            } else {
                error = .missingSeparator
            }
        }
        return nil
    }
    
    func expression() -> Expression? {
        
        if let leftSide = nextToken() {
            switch leftSide.type {
            case .literal, .identifier:
                break
            default:
                error = .expressionError
                break
            }
            
            if let operation = tokens.first, case .operation = operation.type {
                nextToken()
                
                if let rightSide = tokens.first {
                    switch rightSide.type {
                    case .literal, .identifier:
                        nextToken()
                        return Expression(leftSide: leftSide, operation: operation, rightSide: rightSide)
                    default:
                        error = .expressionError
                        return nil
                    }
                }
            }
            return Expression(leftSide: leftSide, operation: nil, rightSide: nil)
        }
        
        return nil
    }
    
    func function(identifier: Token) -> Function? {
        let expr = expression()
        
        if let closeParen = tokens.first, case .separator = closeParen.type, closeParen.value == ")" {
            nextToken()
            if let separator = tokens.first, case .separator = separator.type, separator.value == ";" {
                nextToken()
                return Function(name: identifier, parameter: expr)
            }
        }
        error = .missingSeparator
        return nil
    }
    
    func comparison() -> Comparison? {
        if let leftSide = expression(),
            let comparator = nextToken(),
            case .comparison = comparator.type,
            let rightSide = expression() {
            return Comparison(leftSide: leftSide, comparison: comparator, rightSide: rightSide)
        }
        
        return nil
    }
}
