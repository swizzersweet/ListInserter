//
//  PlainListWithSections.swift
//  Example
//
//  Created by Jonathan Menard on 2023-12-29.
//

import SwiftUI

struct PlainListWithSections: View {
    
    struct Section: Identifiable, Hashable {
        let id = UUID()
        var items: [Item]
        
        mutating func deleteItem(index: Int) {
            self.items.remove(at: index)
        }
    }
    
    struct Item: Identifiable, Hashable {
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(kind)
        }
        
        let id = UUID()
        let kind: Kind
        
        enum Kind: Hashable {
            case one(String)
            case two(String, Int)
        }
    }
    
    class Model: ObservableObject {
        @Published var sections: [Section]
        
        init() {
            self.sections = (0..<5).map { _ in
                let items = [PlainListWithSections.Item].generate()
                return Section(items: items)
            }
        }
        
        func delete(_ section: Section, _ indexSet: IndexSet) {
            guard let indexOfSection = sections.firstIndex(of: section) else {
                print("we don't have this section")
                return
            }
            
            for index in indexSet {
                sections[indexOfSection].deleteItem(index: index)
            }
        }
    }
    
    @ObservedObject var model = Model()
    
    var body: some View {
        List {
            ForEach(model.sections, id: \.self) { sec in
                SwiftUI.Section {
                    ForEach(sec.items, id: \.self) { item in
                        viewFor(item: item)
                    }
                    .onDelete(perform: { indexSet in
                        model.delete(sec, indexSet)
                    })
                }
            }
        }
    }
    
    func viewFor(item: Item) -> some View {
        switch item.kind {
        case let .one(text):
            return Text("some text: \(text)")
                .foregroundColor(.green)
        case let .two(text, num):
            return Text("some text: \(text) num:\(num)")
                .foregroundColor(.blue)
        }
    }
}

fileprivate extension [PlainListWithSections.Item] {
    static func generate(count: Int = 5) -> [Element] {
        (0..<count).map { _ in
            let kind = Bool.random() ?
            PlainListWithSections.Item.Kind.one("one: \(Int.random(in: 0..<100_000))") :
            PlainListWithSections.Item.Kind.two("two: \(Int.random(in: 0..<100_000))", Int.random(in: 0..<100_000))
            
            return PlainListWithSections.Item(kind: kind)
        }
    }
}

#Preview {
    PlainListWithSections()
}
