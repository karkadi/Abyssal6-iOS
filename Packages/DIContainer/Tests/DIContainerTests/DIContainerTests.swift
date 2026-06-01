//
//  DIContainerTests.swift
//  DIContainer
//
//  Created by Arkadiy KAZAZYAN on 12/03/2026.
//
import XCTest
@testable import DIContainer

// MARK: - Mock Service

protocol MockServiceProtocol: Sendable {
    var name: String { get }
}

struct MockService: MockServiceProtocol, Sendable {
    let name: String
    init(name: String = "MockService") { self.name = name }
}

// MARK: - DependencyKey

enum MockServiceKey: DependencyKey {
    static let liveValue: any MockServiceProtocol = MockService(name: "LiveService")
}

extension DependencyValues {
    var mockService: any MockServiceProtocol {
        get { self[MockServiceKey.self] }
        set { self[MockServiceKey.self] = newValue }
    }
}

// MARK: - Test ViewModel

@MainActor
final class TestViewModel {
    @Injected(\.mockService) var service
}

// MARK: - Tests

@MainActor
final class DIContainerTests: XCTestCase {

    override func tearDown() async throws {
        try await super.tearDown()
        DependencyOverrideStore.shared.reset()
    }

    // Live value is returned when no override is set
    func testLiveValueResolution() {
        let values = DependencyValues()
        XCTAssertEqual(values.mockService.name, "LiveService")
    }

    // Override store replaces live value
    func testOverrideReplacesDependency() {
        DependencyOverrideStore.shared.override(\.mockService, with: MockService(name: "Overridden"))

        let viewModel = TestViewModel()
        XCTAssertEqual(viewModel.service.name, "Overridden")
    }

    // Reset clears overrides and falls back to live value
    func testResetRestoresLiveValue() {
        DependencyOverrideStore.shared.override(\.mockService, with: MockService(name: "Overridden"))
        DependencyOverrideStore.shared.reset()

        let viewModel = TestViewModel()
        XCTAssertEqual(viewModel.service.name, "LiveService")
    }

    // Each keyPath override is independent
    func testMultipleOverridesAreIndependent() {
        DependencyOverrideStore.shared.override(\.mockService, with: MockService(name: "Mock1"))

        let viewModel = TestViewModel()
        XCTAssertEqual(viewModel.service.name, "Mock1")
    }

    // DependencyValues subscript reads liveValue when nothing stored
    func testDependencyValuesSubscriptFallsBackToLiveValue() {
        var values = DependencyValues()
        XCTAssertEqual(values.mockService.name, "LiveService")

        values.mockService = MockService(name: "Local")
        XCTAssertEqual(values.mockService.name, "Local")
    }

    // Override store is keyed per keyPath — resetting clears all
    func testResetClearsAllOverrides() {
        DependencyOverrideStore.shared.override(\.mockService, with: MockService(name: "X"))
        DependencyOverrideStore.shared.reset()
        XCTAssertNil(DependencyOverrideStore.shared.get(for: \.mockService))
    }
}
