//
//  BookItem.swift
//  Example
//
//  Created by Jonathan Menard on 2024-01-28.
//

import Foundation
import ListInserter

struct BookItem: Hashable, ValueKindIdentifiable {
    
    enum Details: Hashable {
        case fantasy(String)
        case horror(String, Int)
    }
    
    enum Kind: Hashable {
        case fantasy
        case horror
    }
        
    let id = UUID() // allows duplicate entries of the exact same item
    let valueKind: Kind
    let details: Details
    
    init(_ details: Details) {
        self.details = details
        self.valueKind = Kind(details)
    }
}

extension BookItem.Kind {
    init(_ details: BookItem.Details) {
        switch details {
        case .fantasy:
            self = .fantasy
        case .horror:
            self = .horror
        }
    }
}

extension [BookItem] {
    static func generateRandom(count: Int = 10) -> [Element] {
        return (0..<count).map { index in
            if Bool.random() {
                return Element(.fantasy("Fantasy book \(Int.random(in: 1..<1_000))"))
            } else {
                return Element(.horror("Horror book", Int.random(in: 100..<1_000)))
            }
        }
    }
}
