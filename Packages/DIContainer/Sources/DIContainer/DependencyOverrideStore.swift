//
//  DependencyOverrideStore.swift
//  DIContainer
//
//  Created by Arkadiy KAZAZYAN on 31/05/2026.
//


// MARK: - Override store isolated to MainActor

@MainActor
public final class DependencyOverrideStore {
    public static let shared = DependencyOverrideStore()
    private var storage: [ObjectIdentifier: any Sendable] = [:]
    private init() {}

    public func set<V: Sendable>(for keyPath: KeyPath<DependencyValues, V>, value: V) {
        storage[ObjectIdentifier(keyPath)] = value
    }

    public func get<V: Sendable>(for keyPath: KeyPath<DependencyValues, V>) -> V? {
        storage[ObjectIdentifier(keyPath)] as? V
    }

    public func reset() { storage.removeAll() }
    
    public func override<V: Sendable>(_ keyPath: KeyPath<DependencyValues, V>, with value: V) {
        set(for: keyPath, value: value)
    }
}
