import XCTest
@testable import ListInserter

import SwiftUI

final class ListInserterTests: XCTestCase {
    typealias TestInserter = Inserter<NoSections, BookItem>
    
    func testNoSections_inserts_whenOneIndexInserterThreeFromTopActive() throws {
        let injectThreeFromTop = TestInserter.InsertionRequest(
            requestType: .index(
                .init(view: AnyView(EmptyView()),
                    position: .top(3))))
        
        let listInserter = TestInserter(itemInsertionRequests: [injectThreeFromTop])
        
        let items: [Item<BookItem>] = [
            .value(.init(kind: .fantasy("foo1"))),
            .value(.init(kind: .fantasy("foo2"))),
            .value(.init(kind: .fantasy("foo3"))),
            .value(.init(kind: .fantasy("foo4")))
        ]
        
        let expectedItemKindsAfterInsertion = [
            "fantasy",
            "fantasy",
            "fantasy",
            "inserted",
            "fantasy"]
        
        let itemsWithInsertions = listInserter.insert(into: items)
        XCTAssertEqual(itemsWithInsertions.map { $0.itemKindId }, expectedItemKindsAfterInsertion)
    }
    
    func testNoSections_inserts_whenOneIndexInserterThreeFromBottomActive() throws {
        let injectThreeFromBottom = TestInserter.InsertionRequest(
            requestType: .index(
                .init(view: AnyView(EmptyView()),
                    position: .bottom(3))))
        
        let listInserter = TestInserter(itemInsertionRequests: [injectThreeFromBottom])
        
        let items: [Item<BookItem>] = [
            .value(.init(kind: .fantasy("foo1"))),
            .value(.init(kind: .fantasy("foo2"))),
            .value(.init(kind: .fantasy("foo3"))),
            .value(.init(kind: .fantasy("foo4")))
        ]
        
        let expectedItemKindsAfterInsertion = [
            "fantasy",
            "inserted",
            "fantasy",
            "fantasy",
            "fantasy"]
        
        let itemsWithInsertions = listInserter.insert(into: items)
        XCTAssertEqual(itemsWithInsertions.map { $0.itemKindId }, expectedItemKindsAfterInsertion)
    }
}
