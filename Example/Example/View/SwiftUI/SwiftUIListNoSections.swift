import SwiftUI
import ListInserter

struct SwiftUIListNoSections: View {
    
    typealias Inserter = ListInserter.Inserter<NoSection<BookItem, PromotionalView>>
    typealias Item = ListInserter.Item<BookItem, PromotionalView>
    
    class Model: ObservableObject {
        private var rawEntries = [BookItem]()
        @Published var entries = [Item]()
               
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
        
        private var listInserter: Inserter!
        
        init() {
            let injectThreeFromTop = Inserter.InsertionRequest(requestType: .index(.init(embed: PromotionalView(text: "3 from top", colors: (.blue, .green)), position: .top(3)))) { [weak self] in
                self?.isInserterFromTopOn ?? false
            }
            
            let injectBelowHorror = Inserter.InsertionRequest(requestType: .pinToItem(.init(embed: PromotionalView(text: "2 below last textAndNumber", colors: (.orange, .red)), itemTargetIdentifier: "horror", offset: .below(2), occurrence: .last))) { [weak self] in
                self?.isInserterAfterTypeOn ?? false
            }
            
            listInserter = Inserter(itemInsertionRequests: [injectThreeFromTop, injectBelowHorror], shouldInsertItems: {
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
//            entries.remove(atOffsets: indexSet)
        }
        
        private func applyInsertions() {
            let entries: [Item] = self.rawEntries.map { .value($0) }
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
                        insertedItemInfo.embed
                    case let .value(bookItem):
                        switch bookItem.details {
                        case let .fantasy(text):
                            Text("text only. text: \(text)")
                                .foregroundColor(.green)
                        case let .horror(text, num):
                            Text("text and num. text:\(text) and num:\(num)")
                                .foregroundColor(.blue)
                        }
                    }
                }
//                .onDelete(perform: model.deleteItem)
            }
        }
    }
}

#Preview {
    SwiftUIListNoSections()
}
