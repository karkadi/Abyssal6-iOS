//
//  Injected.swift
//  DIContainer
//
//  Created by Arkadiy KAZAZYAN on 12/03/2026.
//

import Foundation

// MARK: - Injected

@propertyWrapper
public struct Injected<Value: Sendable>: @unchecked Sendable {
    private let keyPath: KeyPath<DependencyValues, Value>

    public init(_ keyPath: KeyPath<DependencyValues, Value>) {
        self.keyPath = keyPath
    }

    public var wrappedValue: Value {
        MainActor.assumeIsolated {
            DependencyOverrideStore.shared.get(for: keyPath)
                ?? DependencyValues()[keyPath: keyPath]
        }
    }

    public var projectedValue: Self { self }
}
