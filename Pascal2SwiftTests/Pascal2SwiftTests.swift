//
//  Pascal2SwiftTests.swift
//  Pascal2SwiftTests
//
//  Created by Mateus Kamoei on 16/05/20.
//  Copyright © 2020 Kobethon. All rights reserved.
//

import XCTest
@testable import Pascal2Swift

class Pascal2SwiftTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLexicalAnalyzer_returnsKeywordToken() throws {
        let lexicalAnalyzer = LexicalAnalyzer(text: "program")
        XCTAssertEqual(lexicalAnalyzer.tokens.count, 1)
        if let token = lexicalAnalyzer.tokens.first, case .keyword = token.type {
            XCTAssertTrue(true)
        } else {
            XCTFail()
        }
    }
    
    func testLexicalAnalyzer_returnsIdentifierToken() throws {
        let lexicalAnalyzer = LexicalAnalyzer(text: "foo")
        XCTAssert(lexicalAnalyzer.tokens.count == 1)
        if let token = lexicalAnalyzer.tokens.first, case .identifier = token.type {
            XCTAssert(true)
        } else {
            XCTFail()
        }
    }
    
    func testLexicalAnalyzer_returnsOperatorToken() throws {
        let lexicalAnalyzer = LexicalAnalyzer(text: "+")
        XCTAssert(lexicalAnalyzer.tokens.count == 1)
        if let token = lexicalAnalyzer.tokens.first, case .operation = token.type {
            XCTAssert(true)
        } else {
            XCTFail()
        }
    }
    
    func testLexicalAnalyzer_returnsLiteralIntegerToken() throws {
        let lexicalAnalyzer = LexicalAnalyzer(text: "100")
        XCTAssert(lexicalAnalyzer.tokens.count == 1)
        if let token = lexicalAnalyzer.tokens.first,
            case let .literal(literalType) = token.type,
            literalType == .integer {
            XCTAssert(true)
        } else {
            XCTFail()
        }
    }
    
    func testLexicalAnalyzer_returnsLiteralStringToken() throws {
        let lexicalAnalyzer = LexicalAnalyzer(text: "\"100\"")
        XCTAssert(lexicalAnalyzer.tokens.count == 1)
        if let token = lexicalAnalyzer.tokens.first,
            case let .literal(literalType) = token.type,
            literalType == .string {
            XCTAssert(true)
        } else {
            XCTFail()
        }
    }
    
    func testLexicalAnalyzer_returnsCorrectTokens() throws {
        let lexicalAnalyzer = LexicalAnalyzer(text: "foo := 100;")
        let tokens = lexicalAnalyzer.tokens
        XCTAssertEqual(tokens.count, 4)
        if tokens.count == 4,
            case .identifier = tokens[0].type,
            case .assignment = tokens[1].type,
            case let .literal(literalType) = tokens[2].type, literalType == .integer,
            case .separator = tokens[3].type {
            XCTAssert(true)
        } else {
            XCTFail()
        }
    }
    
    func testLexicalAnalyzer_variableDeclaration() {
        let lexicalAnalyzer = LexicalAnalyzer(text: "var a, b: integer;")
        let tokens = lexicalAnalyzer.tokens
        XCTAssertEqual(tokens.count, 7)
        if tokens.count == 7,
            case .keyword = tokens[0].type, // var
            case .identifier = tokens[1].type, // firstNumber
            case .separator = tokens[2].type, // ,
            case .identifier = tokens[3].type, // secondNumber
            case .separator = tokens[4].type, // :
            case .keyword = tokens[5].type, // integer
            case .separator = tokens[6].type { // ;
            XCTAssert(true)
        } else {
            XCTFail()
        }
    }
    
    func testLexicalAnalyzer_prog1() {
        let program =
        """
program test;
var a, b, c: integer;
begin
a := 1;
b := 2;
if a > b then
begin
    c := 0;
end
else
begin
    c := 1;
end;
end.
"""
        let lexicalAnalyzer = LexicalAnalyzer(text: program)
        let tokens = lexicalAnalyzer.tokens
        XCTAssertEqual(tokens.count, 42)
        if tokens.count == 42,
            case .keyword = tokens[0].type, // program
            case .identifier = tokens[1].type, // test
            case .separator = tokens[2].type, // ;
            case .keyword = tokens[3].type, // var
            case .identifier = tokens[4].type, // a
            case .separator = tokens[5].type, // ,
            case .identifier = tokens[6].type, // b
            case .separator = tokens[7].type, // ,
            case .identifier = tokens[8].type, // c
            case .separator = tokens[9].type, // :
            case .keyword = tokens[10].type, // integer
            case .separator = tokens[11].type, // ;
            case .keyword = tokens[12].type, // begin
            case .identifier = tokens[13].type, // a
            case .assignment = tokens[14].type, // :=
            case let .literal(l1) = tokens[15].type, l1 == .integer, // 1
            case .separator = tokens[16].type, // ;
            case .identifier = tokens[17].type, // b
            case .assignment = tokens[18].type, // :=
            case let .literal(l2) = tokens[19].type, l2 == . integer, // 2
            case .separator = tokens[20].type, // ;
            case .keyword = tokens[21].type, // if
            case .identifier = tokens[22].type, // a
            case .comparison = tokens[23].type, // >
            case .identifier = tokens[24].type, // b
            case .keyword = tokens[25].type, // then
            case .keyword = tokens[26].type, // begin
            case .identifier = tokens[27].type, // c
            case .assignment = tokens[28].type, // :=
            case let .literal(l3) = tokens[29].type, l3 == .integer, // 0
            case .separator = tokens[30].type, // ;
            case .keyword = tokens[31].type, // end
            case .keyword = tokens[32].type, // else
            case .keyword = tokens[33].type, // begin
            case .identifier = tokens[34].type, // c
            case .assignment = tokens[35].type, // :=
            case let .literal(l4) = tokens[36].type, l4 == .integer, // 1
            case .separator = tokens[37].type, // ;
            case .keyword = tokens[38].type, // end
            case .separator = tokens[39].type, // ;
            case .keyword = tokens[40].type, // end
            case .separator = tokens[41].type { // .
            XCTAssert(true)
        } else {
            XCTFail()
        }
    }
    
    func testLexicalAnalyzer_function() {
        let lexicalAnalyzer = LexicalAnalyzer(text: "write(\"foo\");")
        let tokens = lexicalAnalyzer.tokens
        XCTAssertEqual(tokens.count, 5)
        if tokens.count == 5,
            case .identifier = tokens[0].type, // write
            case .separator = tokens[1].type, // (
            case .literal(.string) = tokens[2].type, // "foo"
            case .separator = tokens[3].type, // )
            case .separator = tokens[4].type { // ;
            XCTAssert(true)
        } else {
            XCTFail()
        }
    }

}
