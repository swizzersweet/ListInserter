import SwiftUI
import ListInserter

struct SwiftUIListNoSections: View {
   
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
        private var rawEntries = [BookItem]()
        @Published var entries = [ListInserter.Item<BookItem>]()
               
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
        
        private var listInserter: Inserter<NoSections, BookItem>!
        
        init() {
            let injectThreeFromTop = Inserter<NoSections, SwiftUIListNoSections.BookItem>.InsertionRequest(requestType: .index(.init(view: AnyView(PromotionalView(text: "3 from top", colors: (.blue, .green))), position: .top(3)))) { [weak self] in
                self?.isInserterFromTopOn ?? false
            }
            
            let injectBelowHorror = Inserter<NoSections, SwiftUIListNoSections.BookItem>.InsertionRequest(requestType: .pinToItem(.init(view: AnyView(PromotionalView(text: "2 below last textAndNumber", colors: (.orange, .red))), itemTargetIdentifier: "horror", offset: .below(2), occurrence: .last))) { [weak self] in
                self?.isInserterAfterTypeOn ?? false
            }
            
            listInserter = Inserter<NoSections, BookItem>(itemInsertionRequests: [injectThreeFromTop, injectBelowHorror], shouldInsertItems: {
                return true
            })
            
            Task {
                await loadEntries()
            }
        }
        
        func loadEntries() async {
            self.rawEntries = [BookItem].generateRandom()
            applyInsertions()
        }
        
        func loadMore() async {
            let newRawEntries = [BookItem].generateRandom()
            rawEntries.append(contentsOf: newRawEntries)
            
            applyInsertions()
        }
        
        func deleteItem(_ indexSet: IndexSet) {
            entries.remove(atOffsets: indexSet)
        }
        
        private func applyInsertions() {
            let entries: [ListInserter.Item<BookItem>] = self.rawEntries.map { .value($0) }
            Task { @MainActor in
                self.entries = listInserter.insert(into: entries)
            }
        }
    }
    
    @ObservedObject private var model = Model()
   
    init() {}
    
    var body: some View {
        VStack {
            VStack {
                Toggle("Inserter From Top Active", isOn: $model.isInserterFromTopOn)
                Toggle("Inserter From Top Active", isOn: $model.isInserterAfterTypeOn)
                
                Button("Load more") {
                    Task {
                        await model.loadMore()
                    }
                }
            }
            
            List {
                ForEach(model.entries, id: \.self) { entry in
                    
                    switch entry {
                    case let .inserted(insertedItemInfo):
                        insertedItemInfo.view
                    case let .value(value):
                        switch value.kind {
                        case let .fantasy(text):
                            Text("text only. text: \(text)")
                                .foregroundColor(.green)
                        case let .horror(text, num):
                            Text("text and num. text:\(text) and num:\(num)")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .onDelete(perform: model.deleteItem)
            }
        }
    }
}

private extension [SwiftUIListNoSections.BookItem] {
    static func generateRandom(count: Int = 10) -> [Element] {
        return (0..<count).map { index in
            if Bool.random() {
                return Element(kind: .fantasy("Lorem text: \(index)"))
            } else {
                return Element(kind: .horror("Lorem text:", Int.random(in: 100..<1000)))
            }
        }
    }
}

#Preview {
    SwiftUIListNoSections()
}
