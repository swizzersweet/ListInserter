@testable import ListInserter
import Foundation

struct BookItem: Hashable, Identifiable, ItemKindIdentifiable {
    
    enum Kind: Hashable {
        case fantasy(String)
        case horror(String, Int)
    }
    
    var itemKindId: String {
        switch kind {
        case .fantasy: return "fantasy"
        case .horror: return "horror"
        }
    }
    
    let id = UUID()
    let kind: Kind
}
