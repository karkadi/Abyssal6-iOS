//
//  DependencyKey.swift
//  DIContainer
//
//  Created by Arkadiy KAZAZYAN on 31/05/2026.
//

import Foundation

// MARK: - DependencyKey Protocol

/// A key that associates a concrete value type with a dependency.
public protocol DependencyKey {
    associatedtype Value: Sendable
    static var liveValue: Value { get }
}

// MARK: - DependencyValues

/// A structured storage for all dependencies.
public struct DependencyValues: Sendable {
    private var storage: [ObjectIdentifier: any Sendable] = [:]

    public subscript<K: DependencyKey>(key: K.Type) -> K.Value {
        get { storage[ObjectIdentifier(key)] as? K.Value ?? K.liveValue }
        set { storage[ObjectIdentifier(key)] = newValue }
    }

    public init() {}
}
