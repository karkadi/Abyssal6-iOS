# DIContainer

A lightweight, thread-safe dependency injection container for Swift with property wrapper support.

## Features

- ✅ Type-safe registration and resolution
- ✅ Thread-safe with `NSRecursiveLock`
- ✅ Lazy resolution via `@Injected` property wrapper
- ✅ Test-friendly: replace `shared` instance for mocking
- ✅ Zero external dependencies
- ✅ Supports all Apple platforms (iOS 13+, macOS 10.15+, etc.)

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/karkadi/DIContainer.git", from: "1.0.0")
]
