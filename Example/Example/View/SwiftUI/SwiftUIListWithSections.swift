import SwiftUI
import ListInserter

struct SwiftUIListWithSections: View {
       
    struct BookSection: Hashable {
        let items: [BookItem]
    }
    
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
    
    class Model: ObservableObject {
        @Published var sections = [ListInserter.Section<String, BookItem>]()
        
        @Published var isInserterFromTopOn: Bool = true {
            didSet {
                applyInsertions()
            }
        }
        
        @Published var isInserterAfterTypeOn: Bool = true {
            didSet {
                applyInsertions()
            }
        }
        
        private var listInserter: Inserter<String, BookItem>!
        
        init() {
            let injectThreeFromTop = Inserter<String, BookItem>.InsertionRequest(requestType: .index(.init(view: AnyView(PromotionalView(text: "3 from top", colors: (.blue, .green))), position: .top(3)))) { [weak self] in
                self?.isInserterFromTopOn ?? false
            }
            
            let injectTwoBelowHorror = Inserter<String, BookItem>.InsertionRequest(requestType: .pinToItem(.init(view: AnyView(PromotionalView(text: "2 below last textAndNumber", colors: (.orange, .red))), itemTargetIdentifier: "horror", offset: .below(2), occurrence: .last))) { [weak self] in
                self?.isInserterAfterTypeOn ?? false
            }
            
            listInserter = Inserter<String, BookItem>(itemInsertionRequests: [injectThreeFromTop, injectTwoBelowHorror], shouldInsertItems: {
                return true
            })
            
            appendSections(count: 5)
        }
        
        func appendSections(count: Int = 1) {
            Task { @MainActor in
                for _ in 0..<count {
                    let rawEntries: [BookItem] = [BookItem].generateRandom()
                    let itemEntries: [ListInserter.Item<BookItem>] = rawEntries.map { .value($0) }
                    
                    sections.append(.init(id: UUID().uuidString, items: itemEntries))
                }

                applyInsertions()
            }
        }
        
        func deleteItem(_ indexSet: IndexSet) {
            //            entries.remove(atOffsets: indexSet)
        }
        
        private func applyInsertions() {
            Task { @MainActor in
                sections = listInserter.insert(into: sections)
            }
        }
    }
    
    @ObservedObject private var model = Model()
    
    init() {}
    
    var body: some View {
        VStack {
            VStack {
                Toggle("3 from top", isOn: $model.isInserterFromTopOn)
                Toggle("2 below last horror", isOn: $model.isInserterAfterTypeOn)
                
                Button("Load new section") {
                    model.appendSections(count: 1)
                }
            }
            
            List {
                ForEach(model.sections, id: \.self) { section in
                    Section(header: Text("Book section: \(section.id)")) {
                        ForEach(section.items, id: \.self) { entry in
                            switch entry {
                            case let .value(value):
                                
                                switch value.kind {
                                case let .fantasy(text):
                                    Text("text only. text: \(text)")
                                        .foregroundColor(.green)
                                case let .horror(text, num):
                                    Text("text and num. text:\(text) and num:\(num)")
                                        .foregroundColor(.blue)
                                }
                                
                            case let .inserted(injectedItemInfo):
                                injectedItemInfo.view
                            }
                        }
                    }
                }
            }
        }
    }
}

private extension [SwiftUIListWithSections.BookItem] {
    static func generateRandom(count: Int = 10) -> [Element] {
        return (0..<count).map { index in
            if Bool.random() {
                return Element(kind: .fantasy("Fantasy book \(Int.random(in: 1..<1_000))"))
            } else {
                return Element(kind: .horror("Horror book:", Int.random(in: 100..<1_000)))
            }
        }
    }
}

#Preview {
    SwiftUIListWithSections()
}
