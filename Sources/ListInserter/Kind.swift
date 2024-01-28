import Foundation

/*
 The reason that we have both ItemKind and ValueKinds, is such that we don't require values to be aware of the concepts of ItemKind. Specifically, we don't want values to have to be aware of `ItemKind.inserted` and `ItemKind.value`. This provides better ergonomics to the clients of the inserter.
 */

/// Protocol that requires conforming types to provide `ItemKind<ValueKind>`.
public protocol ItemKindIdentifiable {
    associatedtype ValueKind where ValueKind: ValueKindIdentifiable
    
    var itemKindId: ItemKind<ValueKind> { get }
}

/// Protocol that represents a value's kind.
public protocol ValueKindIdentifiable: Hashable {
    associatedtype H where H: Hashable
    
    var valueKind: H { get }
}

/// Represents the _kinds_ of items in the `Inserter`.
/// `inserted` represents inserted items, and `value(ValueKind)` represents raw values. The `ValueKind` is generic, such that each value can describe their kind.
public enum ItemKind<ValueKind: ValueKindIdentifiable>: Hashable {
    case inserted
    case value(ValueKind)
}
