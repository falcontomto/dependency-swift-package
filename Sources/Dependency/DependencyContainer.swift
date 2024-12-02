//
//  DependencyContainer.swift
//  
//
//  Created by Yat To on 03/02/2024.
//

import Foundation

public struct DependencyContainer: @unchecked Sendable {
    public static nonisolated(unsafe) var shared = DependencyContainer()
    
    private var store = [ObjectIdentifier: AnySendable]()
    
    public init() {}
    
    public subscript<Key>(key: Key.Type) -> Key.Value where Key: DependencyKey {
        get {
            getValue(key)
        }
        set {
            setValue(newValue, forKey: key)
        }
    }
    
    private func getValue<Key>(_ key: Key.Type) -> Key.Value where Key: DependencyKey {
        let objId = ObjectIdentifier(key)
        if let existingValue = store[objId]?.base as? Key.Value {
            return existingValue
        } else {
            return Key.defaultValue
        }
    }
    
    private mutating func setValue<Key>(_ value: Key.Value, forKey key: Key.Type) where Key: DependencyKey {
        let objId = ObjectIdentifier(key)
        store[objId] = AnySendable(value)
    }
    
    private func withValues(overrideValues: (inout DependencyContainer) throws -> Void) rethrows -> DependencyContainer {
        var newContainer = self
        try overrideValues(&newContainer)
        return newContainer
    }
    
    public static func withDependencies<R>(
        _ overrideValues: (inout DependencyContainer) throws -> Void,
        operation: () throws -> R
    ) rethrows -> R {
        let shared = DependencyContainer.shared
        DependencyContainer.shared = try shared.withValues(overrideValues: overrideValues)
        let result = try operation()
        DependencyContainer.shared = shared
        return result
    }
}

private struct AnySendable: @unchecked Sendable {
    let base: Any
    
    @inlinable init(_ base: Any) {
        self.base = base
    }
}
