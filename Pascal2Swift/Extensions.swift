//
//  Extensions.swift
//  Pascal2Swift
//
//  Created by Mateus Kamoei on 20/05/20.
//  Copyright © 2020 Kobethon. All rights reserved.
//

import Foundation

extension String {
    
    func characterAt(index i: Int) -> Character? {
        if self.count > i + 1 {
            let start = self.index(self.startIndex, offsetBy: i)
            let end = self.index(self.startIndex, offsetBy: i + 1)
            return Character(String(self[start..<end]))
        }
        return nil
    }
}
