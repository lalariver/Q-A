//
//  ExtString.swift
//  Q&A
//
//  Created by lawliet on 2019/9/5.
//  Copyright © 2019 lawliet. All rights reserved.
//

import Foundation

extension String { //擴充字串可解析base64
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
