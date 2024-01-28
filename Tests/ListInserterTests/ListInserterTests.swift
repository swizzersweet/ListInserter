import XCTest
@testable import ListInserter

import SwiftUI

final class ListInserterTests: XCTestCase {
    typealias TestInserter = Inserter<NoSection<BookItem, EmptyView>>
    typealias Item = ListInserter.Item<BookItem, EmptyView>
    
    func testNoSectionsInsert_shouldInsert_whenThreeFromTop() throws {
        let injectThreeFromTop = TestInserter.InsertionRequest(
            requestType: .index(
                .init(embed: EmptyView(),
                    position: .top(3))))
        
        let listInserter = TestInserter(itemInsertionRequests: [injectThreeFromTop])
        
        let bookItems: [BookItem] = [
            .init(valueKind: .fantasy("foo1")),
            .init(valueKind: .fantasy("foo2")),
            .init(valueKind: .fantasy("foo3")),
            .init(valueKind: .fantasy("foo4"))
        ]
        
        let items: [Item] = bookItems.map { Item.value($0) }
        
        var expectedItemKindsAfterInsertion: [ItemKind<BookItem>] = bookItems
            .map { .value($0) }
        expectedItemKindsAfterInsertion.insert(.inserted, at: 3)
        
        let itemsWithInsertions = listInserter.insert(into: items)
        
        XCTAssertEqual(itemsWithInsertions.map { $0.itemKindId }, expectedItemKindsAfterInsertion)
    }
    
    func testNoSectionsInsert_shouldInsert_whenThreeFromBottom() throws {
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
    
    func testNoSectionsInsert_shouldPreservePosition_whenItemDeleted() throws {
        let injectThreeFromTop = TestInserter.InsertionRequest(
            requestType: .index(
                .init(embed: EmptyView(),
                    position: .top(3))))
        
        let listInserter = TestInserter(itemInsertionRequests: [injectThreeFromTop])
        
        var bookItems: [BookItem] = [
            .init(valueKind: .fantasy("foo1")),
            .init(valueKind: .fantasy("foo2")),
            .init(valueKind: .fantasy("foo3")),
            .init(valueKind: .fantasy("foo4"))
        ]
        
        let items: [Item] = bookItems.map { Item.value($0) }
        
        var expectedItemKindsAfterInsertion: [ItemKind<BookItem>] = bookItems
            .map { .value($0) }
        expectedItemKindsAfterInsertion.insert(.inserted, at: 3)
        
        let itemsWithInsertions = listInserter.insert(into: items)
        
        XCTAssertEqual(itemsWithInsertions.count, 5)
        XCTAssertEqual(itemsWithInsertions.map { $0.itemKindId }, expectedItemKindsAfterInsertion)
        
        bookItems.removeFirst()
        
        let items2: [Item] = bookItems.map { Item.value($0) }
        var expectedItemKindsAfterInsertion2: [ItemKind<BookItem>] = bookItems.map { .value($0) }
        expectedItemKindsAfterInsertion2.insert(.inserted, at: 2)
        
        let itemsWithInsertions2 = listInserter.insert(into: items2)
        
        XCTAssertEqual(itemsWithInsertions2.count, 4)
        XCTAssertEqual(itemsWithInsertions2.map { $0.itemKindId }, expectedItemKindsAfterInsertion2)
    }
    
    func testNoSectionsInsert_shouldReinsert_whenAllItemsDeleted() throws {
        let injectThreeFromTop = TestInserter.InsertionRequest(
            requestType: .index(
                .init(embed: EmptyView(),
                    position: .top(3))))
        
        let listInserter = TestInserter(itemInsertionRequests: [injectThreeFromTop])
        
        var bookItems: [BookItem] = [
            .init(valueKind: .fantasy("foo1")),
            .init(valueKind: .fantasy("foo2")),
            .init(valueKind: .fantasy("foo3")),
            .init(valueKind: .fantasy("foo4"))
        ]
        
        let items: [Item] = bookItems.map { Item.value($0) }
        
        var expectedItemKindsAfterInsertion: [ItemKind<BookItem>] = bookItems
            .map { .value($0) }
        expectedItemKindsAfterInsertion.insert(.inserted, at: 3)
        
        let itemsWithInsertions = listInserter.insert(into: items)
        
        XCTAssertEqual(itemsWithInsertions.count, 5)
        XCTAssertEqual(itemsWithInsertions.map { $0.itemKindId }, expectedItemKindsAfterInsertion)
        
        bookItems.removeAll()
        
        bookItems.append(contentsOf: [
            .init(valueKind: .fantasy("foo1")),
            .init(valueKind: .fantasy("foo2")),
            .init(valueKind: .fantasy("foo3")),
            .init(valueKind: .fantasy("foo4")),
        ])
        
        let items2: [Item] = bookItems.map { Item.value($0) }
        var expectedItemKindsAfterInsertion2: [ItemKind<BookItem>] = bookItems.map { .value($0) }
        expectedItemKindsAfterInsertion2.insert(.inserted, at: 3)
        
        let itemsWithInsertions2 = listInserter.insert(into: items2, forceReinsert: true)
        
        XCTAssertEqual(itemsWithInsertions2.count, 5)
        XCTAssertEqual(itemsWithInsertions2.map { $0.itemKindId }, expectedItemKindsAfterInsertion2)
    }
}
