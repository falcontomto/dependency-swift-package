//
//  Denpendency.swift
//
//
//  Created by Yat To on 03/02/2024.
//

import Foundation

@propertyWrapper
public struct Dependency<Value> {
    private let keyPath: KeyPath<DependencyContainer, Value>
    private let container: DependencyContainer
    
    public init(
        _ keyPath: KeyPath<DependencyContainer, Value>,
        container: DependencyContainer = DependencyContainer.shared
    ) {
        self.keyPath = keyPath
        self.container = container
    }
    
    public var wrappedValue: Value {
        container[keyPath: keyPath]
    }
}

extension Dependency: @unchecked Sendable where Value: Sendable {}
