@testable import ListInserter
import Foundation

struct BookItem: Hashable, Identifiable, ItemKindIdentifiable {
    
    enum Kind: Hashable {
        case fantasy(String)
        case horror(String, Int)
    }
    
    var itemKindId: ItemKind {
        switch kind {
        case .fantasy: return .value("fantasy")
        case .horror: return .value("horror")
        }
    }
    
    let id = UUID()
    let kind: Kind
}
