import Testing
import XCTest
@testable import Dependency

@Suite
struct DependencyTests {
    init() {
        DependencyContainer.shared = .init()
    }
    
    @Test func testWrappedValue_WithNoInitialValue_ShouldReturnDefaultValue() throws {
        // given
        // no initial value for Foo
        
        // when
        let bar = Bar()
        
        // then
        #expect(bar.foo.value == 1)
    }
    
    @Test func testWrappedValue_WithInitialValue_ShouldReturnNewValue() throws {
        // given
        DependencyContainer.shared.foo = Foo(value: 2)
        
        // when
        let bar = Bar()
        
        // then
        #expect(bar.foo.value == 2)
    }
    
    @Test func testWrappedValue_WithOverrideValue_ShouldReturnNewValue() throws {
        // given
        let bar0 = Bar()
        let bar1 = DependencyContainer.withDependencies {
            $0.foo = Foo(value: 100)
        } operation: {
            Bar()
        }
        let bar2 = DependencyContainer.withDependencies {
            $0.foo = Foo(value: 200)
        } operation: {
            Bar()
        }
        let bar3 = Bar()
        
        
        // then
        #expect(bar0.foo.value == 1)
        #expect(bar1.foo.value == 100)
        #expect(bar2.foo.value == 200)
        #expect(bar3.foo.value == 1)
    }
    
    
    
    @Test func testContainedValue_WithNoInitialValue_ShouldReturnDefaultValue() throws {
        #expect(DependencyContainer.shared.foo.value == 1)
    }
}

@Suite
struct OtherDependencyTests {
    @Test func testWrappedValue_WithDifferentContainer_ShouldReturnAssignedValue() throws {
        // given
        OtherDependencyContainer.shared.foo = Foo(value: 99)
        
        // when
        let bar = OtherBar()
        
        #expect(bar.otherFoo.value == 99)
    }
}

// MARK: Dummies
protocol FooProtocol: Equatable {
    var value: Int { get }
}

struct Foo: FooProtocol {
    var value: Int
}

struct Bar {
    @Dependency(\.foo) var foo
}

struct OtherBar {
    @Dependency(\.foo, container: OtherDependencyContainer.shared) var otherFoo
}

// MARK: Dependency Key
private struct FooKey: DependencyKey {
    nonisolated(unsafe) static var defaultValue: any FooProtocol = Foo(value: 1)
}

extension DependencyContainer {
    var foo: any FooProtocol {
        get { self[FooKey.self] }
        set { self[FooKey.self] = newValue }
    }
}

enum OtherDependencyContainer {
    nonisolated(unsafe) static var shared = DependencyContainer()
}
