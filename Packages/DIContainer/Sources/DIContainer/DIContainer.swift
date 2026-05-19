//
//  AboutInfo.swift
//  RickAndMorty
//
//  Created by Arkadiy KAZAZYAN on 06/03/2026.
//

import Foundation

// MARK: - DIContainer

/// A simple thread-safe dependency injection container.
public final class DIContainer: @unchecked Sendable {
    
    /// The shared singleton instance. Can be replaced in tests for mock injection.
    /// - Note: Marked `nonisolated(unsafe)` because:
    ///   • Internal mutable state (`registry`) is protected by `lock`
    ///   • Swapping `shared` should only occur during test setup (single-threaded)
    ///   • Pointer assignment is atomic on all supported Apple platforms
    public nonisolated(unsafe) static var shared = DIContainer()
    
    private var registry: [ObjectIdentifier: () -> Any] = [:]
    private let lock = NSRecursiveLock()

    public init() {}

    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        lock.lock(); defer { lock.unlock() }
        registry[ObjectIdentifier(type)] = factory
    }

    public func resolve<T>(_ type: T.Type) -> T {
        lock.lock(); defer { lock.unlock() }
        guard let factory = registry[ObjectIdentifier(type)],
              let instance = factory() as? T else {
            fatalError("No registration for \(type)")
        }
        return instance
    }
    
    public func isRegistered<T>(_ type: T.Type) -> Bool {
        lock.lock(); defer { lock.unlock() }
        return registry[ObjectIdentifier(type)] != nil
    }
    
    public func reset() {
        lock.lock(); defer { lock.unlock() }
        registry.removeAll()
    }
}
