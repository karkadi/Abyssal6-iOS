//
//  DIContainerTests.swift
//  DIContainer
//
//  Created by Arkadiy KAZAZYAN on 12/03/2026.
//
import XCTest
@testable import DIContainer

// MARK: - Mock Services for Testing

protocol ServiceProtocol {
    var name: String { get }
}

class MockService: ServiceProtocol {
    let name: String
    init(name: String = "MockService") { self.name = name }
}

class TestViewModel {
    @Injected var service: MockService
    init() {}
}

// MARK: - Tests

final class DIContainerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        DIContainer.shared.reset()
    }
    
    func testRegisterAndResolve() {
        DIContainer.shared.register(MockService.self) {
            MockService(name: "TestInstance")
        }
        
        let service = DIContainer.shared.resolve(MockService.self)
        XCTAssertEqual(service.name, "TestInstance")
    }
    
    func testResolveUnregisteredType_FatalError() {
        // We can't easily test fatalError in XCTest, but we verify
        // isRegistered returns false for unregistered types
        XCTAssertFalse(DIContainer.shared.isRegistered(MockService.self))
    }
    
    func testIsRegistered() {
        XCTAssertFalse(DIContainer.shared.isRegistered(MockService.self))
        
        DIContainer.shared.register(MockService.self) { MockService() }
        
        XCTAssertTrue(DIContainer.shared.isRegistered(MockService.self))
    }
    
    func testInjectedPropertyWrapper_LazyResolution() {
        var factoryCallCount = 0
        DIContainer.shared.register(MockService.self) {
            factoryCallCount += 1
            return MockService(name: "LazyInstance")
        }
        
        // Factory should not be called during registration
        XCTAssertEqual(factoryCallCount, 0)
        
        let viewModel = TestViewModel()
        
        // Factory should still not be called until property access
        XCTAssertEqual(factoryCallCount, 0)
        
        // First access triggers resolution
        let service = viewModel.service
        XCTAssertEqual(service.name, "LazyInstance")
        XCTAssertEqual(factoryCallCount, 1)
        
        // Subsequent accesses use cached value
        _ = viewModel.service
        XCTAssertEqual(factoryCallCount, 1)
    }
    
    func testInjectedPropertyWrapper_SetValue() {
        DIContainer.shared.register(MockService.self) { MockService(name: "Original") }
        
        var wrapper = Injected<MockService>()
        let customService = MockService(name: "Custom")
        wrapper.wrappedValue = customService
        
        XCTAssertEqual(wrapper.wrappedValue.name, "Custom")
    }
    
    func testThreadSafety() {
        let expectation = XCTestExpectation(description: "Concurrent access")
        DIContainer.shared.register(MockService.self) { MockService() }
        
        let queue = DispatchQueue(label: "test", attributes: .concurrent)
        var results: [String] = []
        let lock = NSLock()
        
        for _ in 0..<100 {
            queue.async {
                let service = DIContainer.shared.resolve(MockService.self)
                lock.lock()
                results.append(service.name)
                lock.unlock()
            }
        }
        
        queue.async(flags: .barrier) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(results.count, 100)
    }
    
    func testSharedInstanceReplacement() {
        // Save original
        let original = DIContainer.shared
        
        // Replace with test container
        let testContainer = DIContainer()
        testContainer.register(MockService.self) { MockService(name: "Test") }
        DIContainer.shared = testContainer
        
        let service = DIContainer.shared.resolve(MockService.self)
        XCTAssertEqual(service.name, "Test")
        
        // Restore original
        DIContainer.shared = original
    }
}
