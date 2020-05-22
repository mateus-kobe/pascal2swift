//
//  Token.swift
//  Pascal2Swift
//
//  Created by Mateus Kamoei on 16/05/20.
//  Copyright © 2020 Kobethon. All rights reserved.
//

import Foundation

enum LiteralType {
    case string
    case integer
}

enum Type {
    case keyword
    case identifier
    case separator
    case operation
    case comparison
    case assignment
    case literal(LiteralType)
    case comment
}

struct Token {
    let type: Type
    let value: String
}
