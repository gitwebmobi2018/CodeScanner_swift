//
//  File.swift
//  CodeTaker
//
//  Created by Ivan.
//  Copyright © 2019 Ivan. All rights reserved.
//

import Foundation

struct Code: Codable {
    
    var index : Int
    var isChecked : Bool = false
    var isArchive : Bool = false
    var code : String
    var date = Date()
    
    enum MatchKeys : String, CodingKey {
        case index               = "CODE_index"
        case isChecked           = "CODE_isChecked"
        case code                = "CODE_code"
        case date                = "CODE_date"
        case isArchive           = "CODE_isArchive"
    }
    
    init(index: Int, code: String) {
        self.index = index
        self.code = code
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MatchKeys.self)
        index = try container.decode(Int.self, forKey: .index)
        isChecked = try container.decode(Bool.self, forKey: .isChecked)
        isArchive = (try? container.decode(Bool.self, forKey: .isArchive)) ?? false
        code = try container.decode(String.self, forKey: .code)
        date = try container.decode(Date.self, forKey: .date)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MatchKeys.self)
        try container.encode(index, forKey: .index)
        try container.encode(isChecked, forKey: .isChecked)
        try container.encode(isArchive, forKey: .isArchive)
        try container.encode(code, forKey: .code)
        try container.encode(date, forKey: .date)
    }
    
    func getDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
}
