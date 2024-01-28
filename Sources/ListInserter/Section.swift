import Foundation


/// `Sectionable` is a protocol that defines the requirements for ListInserter compatible data.
/// It requires a unique section identifier, a value type, and an embed type.
///
/// - Parameters:
///     - SectionIdentifier: The identifier for a section that must be `Hashable`.
///     - Value: The kind of values in the list. Must be `ValueKindIdentifiable` and `Hashable`.
///     - Embed: The type of which we want our inserted items to embed. Eg, this could be a particular SwiftUI view or UIKitView.
///
public protocol Sectionable<SectionIdentifier, Value, Embed>: Identifiable, Hashable {
    associatedtype SectionIdentifier where SectionIdentifier: Hashable
    associatedtype Value where Value: ValueKindIdentifiable, Value: Hashable
    associatedtype Embed
    
    var id: SectionIdentifier { get }
    var items: [Item<Value, Embed>] { get set }
}

/// `Sectionable`s that can be initialized with an array of `Item<Value,Embed>`.
public protocol SectionableInitable: Sectionable {
    init(items: [Item<Value, Embed>])
}

/// Represents sections that are compatible with the `Inserter`.
/// See also `Sectionable`.
public struct Section<SectionIdentifier, Value, Embed> : Sectionable
where
SectionIdentifier: Hashable,
Value: ValueKindIdentifiable,
Value: Hashable
{
    public var id: SectionIdentifier
    
    public var items: [Item<Value, Embed>]
    
    public init(sectionIdentifer: SectionIdentifier, items: [Item<Value, Embed>]) {
        self.id = sectionIdentifer
        self.items = items
    }
}

/// Used to represent lists without sections. Similar to `Section`, but does not require section information.
/// See also: `Sectionable`.
public struct NoSection<Value, Embed> : SectionableInitable
where
Value: ValueKindIdentifiable,
Value: Hashable
{
    public var id: String
    
    public var items: [Item<Value, Embed>]
    
    public init(items: [Item<Value, Embed>]) {
        self.id = "SingleInternalSection"
        self.items = items
    }
}
