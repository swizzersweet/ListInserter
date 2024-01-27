import XCTest
@testable import ListInserter

import SwiftUI

final class ListInserterTests: XCTestCase {
    typealias TestInserter = Inserter<NoSection<BookItem, EmptyView>>
    typealias Item = ListInserter.Item<BookItem, EmptyView>
    
    func testNoSections_inserts_whenOneIndexInserterThreeFromTopActive() throws {
        let injectThreeFromTop = TestInserter.InsertionRequest(
            requestType: .index(
                .init(embed: EmptyView(),
                    position: .top(3))))
        
        let listInserter = TestInserter(itemInsertionRequests: [injectThreeFromTop])
        
        let bookItems: [BookItem] = [
            .init(valueKind: .fantasy("Fantasy Book 1")),
            .init(valueKind: .fantasy("Fantasy Book 2")),
            .init(valueKind: .fantasy("Fantasy Book 3")),
            .init(valueKind: .fantasy("Fantasy Book 4"))
        ]
        
        let items: [Item] = bookItems.map { Item.value($0) }
        
        var expectedItemKindsAfterInsertion: [ItemKind<BookItem>] = bookItems
            .map { .value($0) }
        expectedItemKindsAfterInsertion.insert(.inserted, at: 3)
        
        let itemsWithInsertions = listInserter.insert(into: items)
        
        XCTAssertEqual(itemsWithInsertions.map { $0.itemKindId }, expectedItemKindsAfterInsertion)
    }
    
    func testNoSections_inserts_whenOneIndexInserterThreeFromBottomActive() throws {
        let injectThreeFromBottom = TestInserter.InsertionRequest(
            requestType: .index(
                .init(embed: EmptyView(),
                    position: .bottom(3))))
        
        let listInserter = TestInserter(itemInsertionRequests: [injectThreeFromBottom])
        
        let bookItems: [BookItem] = [
            .init(valueKind: .fantasy("foo1")),
            .init(valueKind: .fantasy("foo2")),
            .init(valueKind: .fantasy("foo3")),
            .init(valueKind: .fantasy("foo4"))
        ]
        
        let items: [Item] = bookItems.map { Item.value($0) }
        
        var expectedItemKindsAfterInsertion: [ItemKind<BookItem>] = bookItems
            .map { .value($0) }
        expectedItemKindsAfterInsertion.insert(.inserted, at: 1)
        
        let itemsWithInsertions = listInserter.insert(into: items)
        XCTAssertEqual(itemsWithInsertions.map { $0.itemKindId }, expectedItemKindsAfterInsertion)
    }
}
