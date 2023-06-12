# SwiftWUID
Swift implementation of WUID

Based on the Go implementation from https://github.com/edwingeng/wuid

## Basic usage:
```
    var w = try WUID(name: "My WUID generator", h28: { Int64.random(in: 0x0000000...0x7FFFFFF) << 36 })
    let firstId = w.next()
    let secondId = w.next()
```

## Introduction

SwiftWUID is a compatible implementation of WUID with interfaces optimized for Swift.  This universal identifier
generator is several times faster than UUID even on Apple hardware.

## Supported features

* Custom H28 (highest 28-bits of identifier)
* Section identifier (0 to 7 inclusive)
* Obfuscation with seed
* Customizable increments (1, 2, 4, 8, 16, 32, 64, 128, 256, 512 and 1024)
* Reserved decimal digits (1, 2 or 3 digits)

Out of scope:
* Redis, PostgreSQL, MySQL support
* Built-in concurrency support

## Performance

All values measured on M2 Max, from Unit Test target with debugging on

* Generating 100k UUID: 62ms, 620ns/op
* Generating 100k WUID: 27ms, 270ns/op
* Generating 100k WUID with Obfuscation: 27ms, 270ns/op

## Custom H28
When generating identifiers from non-coordinated systems, each system can either have a fixed H28 (27 bits usable,
24 bits if using Section) or a randomly generated H28.

The H28 value must be greater than 0 &ltl;&lt; 36 and lower than or equal to 0x7FFFFFF &lt;&lt; 36.

Note that eventually after generating around 80% of the (2^36/step) identifiers, the algorithm will enter into a H28
renewal mode expecting a different H28 value to be returned.  If unable to return a value immediately, you may throw
an error and the algorithm will retry every (0x20000000/step) identifiers generated until it eventually fatalError()
or the H28 function returns a new value.

## Section identifier

To use:
```
    var w = try WUID(section: .value(3), name: "My generator", h28: { 1 << 36 })
    let firstId = w.next()
```

The section will be encoded in bits 61-63 of the generated identifier. When this feature is enabled, the top four
bits of H28 will be ignored and replaced with the Section value.

Can be used with obfuscation, but may not be used with reserved decimal digits.

## Obfuscation

To use:
```
    var w = try WUID(
        obfuscation: .v1(seed: 0x1234567890ABCDEF),
        name: "Obfuscated",
        h28: { 1 << 36 })
    let firstId = w.next()
```

**WARNING: The obfuscation is not intended to be cryptographically secure and is relatively easy to reverse engineer
after collecting several identifiers.**

In practice, because the obfuscation is performed via a simple XOR using a mask computed once per WUID generator, the
end result are quite predictable with values decreasing instead of increasing for bits that are set, and increasing
as usual for bits that are not set.  It may temporarily mislead attackers but is my no mean a secure mechanism.

If you require secure identifiers, they should be encrypted using industry recommended best practices.

Examples using H28 of 1, step of 1 and obfuscation seed of 0x1234567890ABCDEF:
* Non-obfuscated first Id: 0x0000001000000001
* Obfuscated first Id: 0x00000012e5aefe5d

Note: because the obfuscation is using a simple bitwise XOR there will not be any collisions between two identifiers
generated within the same H28 sequence or from other H28 sequences.

## Customizable increments

By default the identifiers generated increase by 1 until the generator reaches its critical value and requests a new
H28.  It is possible to provide a different increment using:

```
    var w = try WUID(step: .by16, name: "by 16", h28: { 1 << 36 })
    let firstId = w.next()
```

Available increments are: 1, 2, 4, 8, 16, 32, 64, 128, 256, 512 and 1024

## Reserved decimal digits

The `Reserved Decimal Digits` is used to zero-out the lowest decimal digits of an identifier's decimal
representation by the specified number of decimal digits.  The main purpose of this is to allow the caller to
set the lowest decimal digits to a custom value that may represent a specific type so when looking at an
identifier's decimal representation you can quickly identify the type of object represented by this identifier.

For example, using a step of .by1024 and h28 of 1, the first ID generated would have a value of
68719477760, by setting `reservedDecimalDigits` to .three, the generated identifier would be 68719477000.
Assuming you want to track a custom object class and assign it a 3 digit value of 169, once the ID is
produced by next() you can then add 169 to the final result obtaining a final value of 68719477169.

To use:
```
    var w = try WUID(
        step: .by16,
        reservedDecimalDigits: .one,
        name: "by 16 with reserved digits",
        h28: { 1 << 36 })
    let firstId = w.next()
```

## Swift Concurrency support
If you require concurrent access to the generator, you will want to create a Swift `actor` to host the WUID struct
and request identifiers via this actor.

```
actor ConcurrentWUID {
   static let shared: ConcurrentWUID = .init()

   private var w: WUID
   
   init() {
      w = try! WUID(name: "Concurrent!", h28: { Int64.random(in: 0x0000000...0x7FFFFFF) << 36 })
   }
   
   func next() -> Int64 {
      w.next()
   }
}

// Initialize the shared instance prior to usage:
_ = ConcurrentWUID.shared

// Request an identifier:
Task {   
   let myId = await ConcurrentWUID.shared.next()
}
```

Or you may also wrap the generator in a class behind a NSLock:
```
class MultiThreadSafeWUID {
   static let shared: MultiThreadSafeWUID = .init()
    
   private var w: WUID
   private let lock = NSLock()
    
   init() {
      w = try! WUID(name: "Thread safe!", h28: { Int64.random(in: 0x0000000...0x7FFFFFF) << 36 })
   }
   
   func next() -> Int64 {
      lock.withLock { w.next() }
   }
}

// Initialize the shared instance prior to usage:
_ = MultiThreadSafeWUID.shared

DispatchQueue.global.async { 
   let myId = MultiThreadSafeWUID.shared.next()
}
```
