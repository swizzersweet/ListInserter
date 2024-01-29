@testable import ListInserter
import Foundation

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
        (self.details, self.valueKind) = (details, Kind(details))
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
