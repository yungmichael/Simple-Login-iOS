//
//  UserOptions.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 10/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

struct UserOptions {
    let canCreate: Bool
    let prefixSuggestion: String
    let suffixes: [String]
    
    lazy var domains: [String] = {
        var domains: [String] = []
        
        suffixes.forEach { (suffix) in
            if let domain = RegexHelpers.firstMatch(for: #"(?<=@).*"#, inString: suffix) {
                domains.append(domain)
            }
        }
        
        return domains
    }()
    
    init(data: Data) throws {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw SLError.failedToSerializeJsonForObject(anyObject: Self.self)
        }
        
        let canCreate = jsonDictionary["can_create"] as? Bool
        let prefixSuggestion = jsonDictionary["prefix_suggestion"] as? String
        let suffixes = jsonDictionary["suffixes"] as? [String]
        
        if let canCreate = canCreate,
            let prefixSuggestion = prefixSuggestion,
            let suffixes = suffixes {
            self.canCreate = canCreate
            self.prefixSuggestion = prefixSuggestion
            self.suffixes = suffixes
        } else {
            throw SLError.failedToParse(anyObject: Self.self)
        }
    }
}
