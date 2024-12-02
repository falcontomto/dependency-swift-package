#  <#Title#>

# ICDependency

## Description
This package provides a property wrapper for dependency injection. It is basically `@Environment` but for places you don't have or need SwiftUI.

## Usage
### Defining Dependencies
Implement a `DependencyKey` and provide a default value for that type, then add accessors for reading and writing object on a Dependency Container.
```swift
private enum FooDependencyKey: DependencyKey {
    static let defaultValue: any FooProtocol = Foo()
}

extension DependencyContainer {
    var foo: any FooProtocol {
        get { self[FooKey.self] }
        set { self[FooKey.self] = newValue }
    }
}
```

### Registering Dependencies
If a different value is required for a dependency, you can change the stored value on the Dependency Container.
```swift
DependencyContainer.shared.foo = OtherFoo()
```

Alternatively, you can also define a new Dependency Container all together.
```swift
class OtherDependencyContainer: DependencyContainer {
    static let shared = OtherDependencyContainer()
    
    private var store = [String: Any]()
    
    subscript<Key>(key: Key.Type) -> Key.Value where Key: DependencyKey {
        get { getValue(key) }
        set { setValue(newValue, forKey: key) }
    }
    
    private func getValue<Key>(_ key: Key.Type) -> Key.Value where Key: DependencyKey {
        let objId = String(describing: key)
        if let existingValue = store[objId] as? Key.Value {
            return existingValue
        } else {
            let newValue = Key.defaultValue
            setValue(newValue, forKey: key)
            return newValue
        }
    }
    
    private func setValue<Key>(_ value: Key.Value, forKey key: Key.Type) where Key: DependencyKey {
        let objId = String(describing: key)
        store[objId] = value
    }
}
```

### Injecting Dependencies
To inject a dependency, simply apply the properly wrapper with a suitable keypath.
```swift
struct FooBar {
    @Dependency(\.foo)
    var foo
    
    @Dependency(\.bar, container: OtherDependencyContainer.shared)
    var bar
}
```

### Known issues
- `DependencyContainer` is not really Sendable and is at risk of data race. Currently, it is explicitly `@unchecked` to suppress warnings and errors from Swift Concurrency in Swift 6. This is unlikely to be resolved as `@propertyWrapper` currently does not support async getter in `wrappedValue`.
