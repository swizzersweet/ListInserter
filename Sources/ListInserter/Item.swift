import Foundation

/// Represents an item, generic over the `Value`, and it's `Embed` for inserted values.
public enum Item<Value, Embed>: Hashable, ItemKindIdentifiable
    where
    Value: Hashable,
    Value: ValueKindIdentifiable
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

/// Represents the inserted item information, generic over the `Embed` type.
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
