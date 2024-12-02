//
//  DependencyKey.swift
//
//
//  Created by Yat To on 03/02/2024.
//

import Foundation

public protocol DependencyKey {
    associatedtype Value

    static var defaultValue: Self.Value { get }
}
