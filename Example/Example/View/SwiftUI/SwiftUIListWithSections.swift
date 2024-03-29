import SwiftUI
import ListInserter

struct SwiftUIListWithSections: View {
            
    typealias Inserter = ListInserter.Inserter<ListInserter.Section<String, BookItem, PromotionalView>>
    typealias ListSection = ListInserter.Section<String, BookItem, PromotionalView>
    typealias Item = ListInserter.Item<BookItem, PromotionalView>
       
    struct BookSection: Hashable {
        let items: [BookItem]
    }
    
    class Model: ObservableObject {
        @Published var sections = [ListSection]()
        
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
            
            let injectTwoBelowHorror = Inserter.InsertionRequest(requestType: .pinToItem(.init(embed: PromotionalView(text: "2 below last horror", colors: (.orange, .red)), itemTargetIdentifier: BookItem.Kind.horror, offset: .below(2), occurrence: .last))) { [weak self] in
                self?.isInserterAfterTypeOn ?? false
            }
            
            listInserter = Inserter(itemInsertionRequests: [injectThreeFromTop, injectTwoBelowHorror], shouldInsertItems: {
                return true
            })
            
            appendSections(count: 5)
        }
        
        func appendSections(count: Int = 1) {
            Task { @MainActor in
                for _ in 0..<count {
                    let rawEntries: [BookItem] = [BookItem].generateRandom()
                    
                    let itemEntries: [Item] = rawEntries.map { .value($0)}
                    let listSection = ListSection(sectionIdentifer: UUID().uuidString, items: itemEntries)
                    sections.append(listSection)
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
                    }
                }
            }
        }
    }
}

#Preview {
    SwiftUIListWithSections()
}
