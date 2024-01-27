@testable import ListInserter
import Foundation

struct BookItem: Hashable, ValueKindIdentifiable {
    
    enum Kind: Hashable {
        case fantasy(String)
        case horror(String, Int)
    }
        
    let id = UUID() // allows duplicate entries of the exact same item
    let valueKind: Kind
}
