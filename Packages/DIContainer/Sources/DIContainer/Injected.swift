//
//  Injected.swift
//  DIContainer
//
//  Created by Arkadiy KAZAZYAN on 12/03/2026.
//

// MARK: - Injected Property Wrapper

/// A property wrapper that lazily resolves dependencies from `DIContainer.shared`.
///
/// Usage:
/// ```swift
/// class UserService {
///     @Injected var apiClient: APIClient
/// }
/// ```
/// The dependency is resolved on first access and cached thereafter.
@propertyWrapper
public struct Injected<T> {
    private var value: T?
    
    /// Creates a new injected property wrapper.
    public init() {}
    
    /// The wrapped value, resolved lazily from the DI container on first access.
    public var wrappedValue: T {
        mutating get {
            if let value = value { return value }
            let resolved = DIContainer.shared.resolve(T.self)
            self.value = resolved
            return resolved
        }
        set { value = newValue }
    }
    
    /// Access the projected value (the wrapper itself) for manual control.
    public var projectedValue: Injected<T> {
        get { self }
        set { self = newValue }
    }
}
