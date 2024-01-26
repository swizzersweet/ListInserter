// The Swift Programming Language
// https://docs.swift.org/swift-book


import SwiftUI

private typealias SectionHash = (sectionHash: AnyHashable, itemHashes: [AnyHashable])

/// Used to insert items in sectioned data provided requests which describe what to insert, and where to insert the item.
public class Inserter<S: Sectionable>
//    where
//    SectionIdentifier: Hashable,
//    Value: Hashable,
//    Value: ItemKindIdentifiable
{
//    public typealias SectionType = Section<SectionIdentifier, Value, Embed>
//    public typealias ItemType = Item<Value, Embed>
    public typealias SectionType = S
    public typealias ItemType = Item<S.Value, S.Embed>
    
    private var previousSectionHashes: [SectionHash]?
    private let insertionRequests: [InsertionRequest]
    private let shouldInsertItems: () -> Bool

    private var indexItemBuilderCache = [InsertionRequestIndex: ItemType]()
    private var pinItemBuilderCache = [InsertionRequestPinToItem: ItemType]()
    private var itemInfoIdGenerator: () -> String
    
    public init(
        itemInsertionRequests: [InsertionRequest],
        shouldInsertItems: @escaping () -> Bool = { true },
        itemInfoIdGenerator: @escaping () -> String = { UUID().uuidString }
    ) {
        self.insertionRequests = itemInsertionRequests
        self.shouldInsertItems = shouldInsertItems
        self.itemInfoIdGenerator = itemInfoIdGenerator
    }

    public init(
        insertionRequests: [InsertionRequest],
        shouldInsertItems: @escaping () -> Bool = { true },
        itemInfoIdGenerator: @escaping () -> String = { UUID().uuidString }
    )
//        where SectionIdentifier == Int
    {
        self.insertionRequests = insertionRequests
        self.shouldInsertItems = shouldInsertItems
        self.itemInfoIdGenerator = itemInfoIdGenerator
    }

//    public func insert(into newItems: [ItemType]) -> [ItemType]
//        where SectionIdentifier == NoSections
//    {
//        let section = SectionType(id: NoSections(), items: newItems)
//        let insertedSections = insert(into: [section])
//        return insertedSections[0].items
//    }

    public func insert(into newSections: [SectionType]) -> [SectionType] {
        guard shouldInsertItems() else {
            return newSections
                .map { section in
                    var section = section
                    section.items = section.items.filter { element in
                        guard case .value = element else { return false }
                        return true
                    }
                    return section
                }
        }

        let isNewDataSet: Bool = {
            // If we have none of the previous section hashes, we assume it's new data
            guard let previousItemsHashes = previousSectionHashes else { return true }
            let newSectionHashesSet = Set(itemHashes(sections: newSections).map { $0.sectionHash })
            let previousSectionHashesSet = Set(previousItemsHashes.map { $0.sectionHash })
            return previousSectionHashesSet.isDisjoint(with: newSectionHashesSet)
        }()

        if isNewDataSet {
            previousSectionHashes?.removeAll()
        }

        var mutatedItems = newSections
        
        insertionRequests.forEach { request in
            guard request.isEnabled() else {
                mutatedItems = removeItemFromInsertion(insertionRequest: request, sections: mutatedItems)
                return
            }
            
            // If items already contains the item, don't re-insert another copy
            guard !insertedItemExistsInSection(insertionRequest: request, sections: mutatedItems) else {
                return
            }
           
            switch request.requestType {
            case let .index(requestIndex):
                mutatedItems = applyInsertion(requestIndex: requestIndex, sections: mutatedItems)
            case let .pinToItem(requestPinToItem):
                mutatedItems = applyInsertion(requestPin: requestPinToItem, sections: mutatedItems)
            }
        }

        previousSectionHashes = itemHashes(sections: mutatedItems)
        return mutatedItems
    }
    
    private func removeItemFromInsertion(insertionRequest: InsertionRequest, sections: [SectionType]) -> [SectionType] {
        var sections = sections
        
        let item = {
            switch insertionRequest.requestType {
            case let .index(insertionRequestIndex):
                return indexItemBuilderCache[insertionRequestIndex]
            case let .pinToItem(insertionRequestPinToItem):
                return pinItemBuilderCache[insertionRequestPinToItem]
            }
        }()
  
        guard let item, let indexPathOfItem = indexPathOf(item: item, sections: sections) else {
            // item does not exist
            return sections
        }
        
        sections[indexPathOfItem.section].items.remove(at: indexPathOfItem.row)
        
        return sections
    }
    
    private func insertedItemExistsInSection(insertionRequest: InsertionRequest, sections: [SectionType]) -> Bool {
        let item = {
            switch insertionRequest.requestType {
            case let .index(insertionRequestIndex):
                return indexItemBuilderCache[insertionRequestIndex]
            case let .pinToItem(insertionRequestPinToItem):
                return pinItemBuilderCache[insertionRequestPinToItem]
            }
        }()
        
        guard let item, let _ = indexPathOf(item: item, sections: sections) else {
            return false
        }
        
        return true
    }
    
    private func indexPathOf(item: ItemType, sections: [SectionType]) -> IndexPath? {
        for (sectionIndex, sectionValue) in sections.enumerated() {
            for (itemIndex, itemValue) in sectionValue.items.enumerated() {
                if itemValue == item {
                    return IndexPath(row: itemIndex, section: sectionIndex)
                }
            }
        }
        
        return nil
    }

    private func itemHashes(sections: [SectionType]) -> [SectionHash] {
        sections.map { (AnyHashable($0.id), $0.items.map { $0.hashValue }) }
    }

    private func applyInsertion(requestIndex request: InsertionRequestIndex, sections: [SectionType]) -> [SectionType] {
        var sections = sections

        let item = indexItemBuilderCache[request] ?? { () -> ItemType in
            let newItem = ItemType.inserted(InsertedItemInfo(embed: request.embed, id: itemInfoIdGenerator()))
            indexItemBuilderCache[request] = newItem
            return newItem
        }()

        // If we have a previous hashes, check to see if we have inserted the item in there already
        if let previousIndexPathOfItem = indexPathOfPreviousInserted(item: item) {
            reinsertItem(item, indexPath: previousIndexPathOfItem, sections: &sections)
        } else {
            let totalItemCount = sections.reduce(0) { partial, section -> Int in partial + section.items.count }
            // If we have no previous items, or the previous list did not contain the item to insert, then insert the item
            switch request.placement {
            case let .top(offset):
                let clampedOffset = min(max(UInt(offset), 0), UInt(totalItemCount))
                var subItemCount = 0
                for i in 0 ..< sections.count {
                    let itemCountInSection = sections[i].items.count
                    subItemCount += sections[i].items.count
                    if subItemCount >= clampedOffset {
                        let insertionIndex = itemCountInSection - subItemCount + Int(clampedOffset)
                        sections[i].items.insert(item, at: insertionIndex)
                        break
                    }
                }
            case let .bottom(offset):
                let clampedOffset = min(max(UInt(offset), 0), UInt(totalItemCount))
                var subItemCount = 0
                for i in (0 ..< sections.count).reversed() {
                    let itemCountInSection = sections[i].items.count
                    subItemCount += itemCountInSection
                    if subItemCount >= clampedOffset {
                        let insertionIndex = subItemCount - Int(clampedOffset)
                        sections[i].items.insert(item, at: insertionIndex)
                        break
                    }
                }
            }
        }
        return sections
    }

    private func applyInsertion(requestPin request: InsertionRequestPinToItem, sections: [SectionType]) -> [SectionType] {
        var sections = sections

        let item = pinItemBuilderCache[request] ?? { () -> ItemType in
            let newItem = ItemType.inserted(InsertedItemInfo(embed: request.embed, id: itemInfoIdGenerator()))
            pinItemBuilderCache[request] = newItem
            return newItem
        }()

        // If we have a previous hashes, check to see if we have inserted the item in there already
        if let previousIndexPathOfItem = indexPathOfPreviousInserted(item: item) {
            reinsertItem(item, indexPath: previousIndexPathOfItem, sections: &sections)
        } else {
            /*
             We need to check if the item we're trying to pin to exists. Abort if it does not exist.
             Calculate the index based on the requests's offset. Make sure the item stays in the same section.
             The inserted item will always be in the same section as the target item's section.
             */
            let requestItemKindIdentifier = request.itemTargetKindIdentifier
            
            switch request.occurrence {
            case .first:
                for i in 0 ..< sections.count {
                    if let pinTargetItemIndex = sections[i].items.firstIndex(where: { item in
                        switch item.itemKindId {
                        case .inserted:
                            return false
                        case let .value(valueKind):
                            let x = valueKind
                            return valueKind == requestItemKindIdentifier
                        }
                    }) {
                        let insertionIndex = calculatePinnedIndex(proposedTargetIndex: pinTargetItemIndex, offset: request.offset, itemCount: sections[i].items.count)
                        sections[i].items.insert(item, at: insertionIndex)
                        break
                    }
                }
            case .last:
                for i in (0 ..< sections.count).reversed() {
                    if let pinTargetItemIndex = sections[i].items.lastIndex(where: { item in
                        switch item.itemKindId {
                        case .inserted:
                            return false
                        case let .value(valueKind):
                            return valueKind == requestItemKindIdentifier
                        }
                    }) {
                        let insertionIndex = calculatePinnedIndex(proposedTargetIndex: pinTargetItemIndex, offset: request.offset, itemCount: sections[i].items.count)
                        sections[i].items.insert(item, at: insertionIndex)
                        break
                    }
                }
            }
        }

        return sections
    }

    private func indexPathOfPreviousInserted(item: ItemType) -> IndexPath? {
        guard let previousSectionItemsHashes = previousSectionHashes else { return nil }
        for i in 0 ..< previousSectionItemsHashes.count {
            let previousSectionItemsHash = previousSectionItemsHashes[i]
            if let itemIndex = previousSectionItemsHash.itemHashes.firstIndex(of: item.hashValue) {
                return IndexPath(row: itemIndex, section: i)
            }
        }
        return nil
    }

    /// Reinserts the item by looking at the previous items. This attempt to place it beneath the item it was previously below.
    /// In situations where the previous item(s) above it have been deleted, the inejcted item will bubble up to the top of the section.
    private func reinsertItem(
        _ item: ItemType,
        indexPath: IndexPath,
        sections: inout [SectionType]
    ) {
        guard let previousSectionItemsHashes = previousSectionHashes else { return }
        // look at items in same section as index path in previous items
        var previousRowAbove = indexPath.row - 1
        var didInsert = false
        let currentItemHashes = sections[indexPath.section].items.map { AnyHashable($0.hashValue) }

        while previousRowAbove >= 0 {
            let previousItemAbove = previousSectionItemsHashes[indexPath.section].itemHashes[previousRowAbove]
            if let matchingIndexInCurrentList = currentItemHashes.firstIndex(of: previousItemAbove) {
                sections[indexPath.section].items.insert(item, at: matchingIndexInCurrentList + 1)
                didInsert = true
                break
            }
            previousRowAbove -= 1
        }

        // backup plan: put it at the top of the section if all items in section were deleted.
        if !didInsert {
            sections[indexPath.section].items.insert(item, at: 0)
        }
    }

    /// Given a proposed index, an offset, and an item count, determine the resulting index
    private func calculatePinnedIndex(
        proposedTargetIndex: Int,
        offset: InsertionRequestPinToItem.Placement,
        itemCount: Int
    ) -> Int {
        switch offset {
        case let .above(aboveIndex):
            let unclampedIndex = proposedTargetIndex - Int(aboveIndex)
            return min(max(unclampedIndex, 0), itemCount)
        case let .below(belowIndex):
            let unclampedIndex = proposedTargetIndex + Int(belowIndex) + 1
            return min(max(unclampedIndex, 0), itemCount)
        }
    }
    
    public struct InsertionRequest {
        let requestType: ItemInsertionRequestType
        let isEnabled: () -> Bool
        
        public init(requestType: ItemInsertionRequestType, isEnabled: @escaping () -> Bool = { true }) {
            self.requestType = requestType
            self.isEnabled = isEnabled
        }
    }
    
    public enum ItemInsertionRequestType: Hashable {
        case index(InsertionRequestIndex)
        case pinToItem(InsertionRequestPinToItem)
    }

    /// Describes a request to insert an item in a list of items based an an existing ItemTypeCategory
    public struct InsertionRequestPinToItem : Hashable {
        public typealias ItemKindIdentifier = Hashable

        public let embed: Embed
        public let itemTargetKindIdentifier: any Hashable
        public let offset: Placement
        public let occurrence: Occurrence

        private let identifier: String

        public enum Placement {
            case above(UInt) // 0 is above 1 item
            case below(UInt) // 0 is 1 below item
        }

        /// Should the request try to find the first instance of the kind of target, or the last?
        public enum Occurrence {
            case first
            case last
        }

        public init(embed: Embed, itemTargetIdentifier: any Hashable, offset: Placement, occurrence: Occurrence) {
            self.embed = embed
            self.itemTargetKindIdentifier = itemTargetIdentifier
            self.offset = offset
            self.occurrence = occurrence

            self.identifier = UUID().uuidString
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }

        public static func == (lhs: InsertionRequestPinToItem, rhs: InsertionRequestPinToItem) -> Bool {
            lhs.identifier == rhs.identifier
        }
    }

    /// Describes a request to insert an item in a list based on an index
    public struct InsertionRequestIndex: Hashable {
        public let embed: Embed
        public let placement: Placement

        // Do we want to place the inserted item above or below the target index?
        public enum Placement {
            case top(UInt)
            case bottom(UInt)
        }

        private let identifier: String

        public init(embed: Embed, position: Placement) {
            self.embed = embed
            self.placement = position
            self.identifier = UUID().uuidString
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }

        public static func == (lhs: InsertionRequestIndex, rhs: InsertionRequestIndex) -> Bool {
            lhs.identifier == rhs.identifier
        }
    }
}

public protocol Sectionable<SectionIdentifier, Value, Embed>: Identifiable {
    var id: SectionIdentifier { get }
    var items: [Item<Value, Embed>] { get set }
    
    associatedtype SectionIdentifier where SectionIdentifier: Hashable
    associatedtype Value where Value: ItemKindIdentifiable, Value: Hashable
    associatedtype Embed
}

public struct Section<SectionIdentifier, Value, Embed> : Sectionable
where
SectionIdentifier: Hashable,
Value: ItemKindIdentifiable,
Value: Hashable
{
    public var id: SectionIdentifier
    
    public var items: [Item<Value, Embed>]
    
    public init(sectionIdentiifer: SectionIdentifier, items: [Item<Value,Embed>]) {
        self.id = sectionIdentiifer
        self.items = items
    }
}

public struct NoSection<Value, Embed> : Sectionable
where
Value: ItemKindIdentifiable,
Value: Hashable
{
    public var id: String
    
    public var items: [Item<Value, Embed>]
    
    public init(items: [Item<Value,Embed>]) {
        self.id = UUID().uuidString
        self.items = items
    }
}
//public struct Section<SectionIdentifier, Value, Embed>: Identifiable, Hashable, Equatable
//    where
//    SectionIdentifier: Hashable,
//    Value: ItemKindIdentifiable,
//    Value: Hashable
//{
//    public let id: SectionIdentifier
//    public var items: [Item<Value, Embed>]
//
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(items)
//    }
//
//    public static func == (lhs: Self, rhs: Self) -> Bool {
//        lhs.items == rhs.items
//    }
//
//    public init(id: SectionIdentifier, items: [Item<Value, Embed>]) {
//        self.id = id
//        self.items = items
//    }
//}

extension Item: Identifiable where Value: Identifiable, Value.ID == String {
    public var id: String {
        switch self {
        case let .inserted(info):
            return info.id
        case let .value(value):
            return value.id
        }
    }
}

public enum Item<Value, Embed>: Hashable, ItemKindIdentifiable
    where
    Value: Hashable,
    Value: ItemKindIdentifiable
{
    
    public var itemKindId: ItemKind<Value> {
        switch self {
        case .inserted:
            return .inserted
        case let .value(value):
            return .value(value)
        }
    }

    case inserted(InsertedItemInfo<Embed>)
    case value(Value)
}

public struct InsertedItemInfo<Embed>: Hashable, Identifiable {
    public var id: String

    public let embed: Embed

    public init(embed: Embed, id: String) {
        self.embed = embed
        self.id = id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: InsertedItemInfo, rhs: InsertedItemInfo) -> Bool {
        lhs.id == rhs.id
    }
}

//public struct NoSections: Hashable {
//    public init() {}
//}

public protocol ItemKindIdentifiable<ValueIdentifier> {
    associatedtype ValueIdentifier where ValueIdentifier: Hashable
    
    var itemKindId: ItemKind<ValueIdentifier> { get }
}

public enum ItemKind<ItemHash: Hashable>: Hashable {
    case inserted
    case value(ItemHash)
}
