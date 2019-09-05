//
//  Results.swift
//  Q&A
//
//  Created by lawliet on 2019/9/2.
//  Copyright © 2019 lawliet. All rights reserved.
//

import Foundation

struct Results: Codable {
    var results : [Questions]
}

struct Questions: Codable {
    var category: String
    var difficulty: String
    var question: String
    var correct_answer: String
    var incorrect_answers: [String]
}
