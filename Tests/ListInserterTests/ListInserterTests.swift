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
        
        let items: [Item] = [
            .value(.init(kind: .fantasy("foo1"))),
            .value(.init(kind: .fantasy("foo2"))),
            .value(.init(kind: .fantasy("foo3"))),
            .value(.init(kind: .fantasy("foo4")))
        ]
        
        let expectedItemKindsAfterInsertion: [ItemKind<String>] = [
            .value("fantasy"),
            .value("fantasy"),
            .value("fantasy"),
            .inserted,
            .value("fantasy"),
        ]
        
        let itemsWithInsertions = listInserter.insertNoSection(into: items)
        
        XCTAssertEqual(itemsWithInsertions.map { $0.itemKindId }, expectedItemKindsAfterInsertion)
    }
    
    func testNoSections_inserts_whenOneIndexInserterThreeFromBottomActive() throws {
        let injectThreeFromBottom = TestInserter.InsertionRequest(
            requestType: .index(
                .init(embed: EmptyView(),
                    position: .bottom(3))))
        
        let listInserter = TestInserter(itemInsertionRequests: [injectThreeFromBottom])
        
        let items: [Item] = [
            .value(.init(kind: .fantasy("foo1"))),
            .value(.init(kind: .fantasy("foo2"))),
            .value(.init(kind: .fantasy("foo3"))),
            .value(.init(kind: .fantasy("foo4")))
        ]
        
        let expectedItemKindsAfterInsertion: [ItemKind<String>] = [
            .value("fantasy"),
            .inserted,
            .value("fantasy"),
            .value("fantasy"),
            .value("fantasy"),
        ]
        
        let itemsWithInsertions = listInserter.insertNoSection(into: items)
        XCTAssertEqual(itemsWithInsertions.map { $0.itemKindId }, expectedItemKindsAfterInsertion)
    }
}
