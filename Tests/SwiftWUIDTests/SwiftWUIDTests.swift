// SwiftWUID
//
// Created by Dave Poirier on 2023-06-11
// Copyright © 2023 Dave Poirier. Distributed under MIT License

import XCTest
@testable import SwiftWUID

final class SwiftWUIDTests: XCTestCase {
    
    func testNext_firstValueIsNotZero() throws {
        var w = try WUID(name: "Test first value", h28: { 1 << 36 })
        XCTAssertNotEqual(w.next(), 0, "No ID should ever be assigned 0")
    }
    
    func testResetThenNext_firstValueIsNotZero() throws {
        var w = try WUID(name: "reset then next value is not zero", h28: { 1 << 36 })
        try w.reset(to: (0x377 << 36) + 0)
        XCTAssertEqual(w.next(), (0x377 << 36) + 1, "First ID should never be zero")
    }
    
    func testReset_zeroH28_throws() throws {
        var w = try WUID(name: "reset with value 0", h28: { 1 << 36})
        XCTAssertThrowsError(try w.reset(to: (0 << 36) + 77))
    }
    
    func testStep_by1_IdShouldIncreaseBy1() throws {
        var w = try WUID(step: .by1, name: "by 1", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 1, "First ID should be 1")
        XCTAssertEqual(w.next(), (1 << 36) + 2, "Second ID should be 2")
    }
    
    func testStep_by2_IdShouldIncreaseBy2() throws {
        var w = try WUID(step: .by2, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 2, "First ID should be 2")
        XCTAssertEqual(w.next(), (1 << 36) + 4, "Second ID should be 4")
    }
    
    func testStep_by4_IdShouldIncreaseBy4() throws {
        var w = try WUID(step: .by4, name: "by 4", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 4, "First ID should be 4")
        XCTAssertEqual(w.next(), (1 << 36) + 8, "Second ID should be 8")
    }
    
    func testStep_by8_IdShouldIncreaseBy8() throws {
        var w = try WUID(step: .by8, name: "by 8", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 8, "First ID should be 8")
        XCTAssertEqual(w.next(), (1 << 36) + 16, "Second ID should be 16")
    }
    
    func testStep_by16_IdShouldIncreaseBy16() throws {
        var w = try WUID(step: .by16, name: "by 16", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 16, "First ID should be 16")
        XCTAssertEqual(w.next(), (1 << 36) + 32, "Second ID should be 32")
    }
    
    func testStep_by32_IdShouldIncreaseBy32() throws {
        var w = try WUID(step: .by32, name: "by 32", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 32, "First ID should be 32")
        XCTAssertEqual(w.next(), (1 << 36) + 64, "Second ID should be 64")
    }
    
    func testStep_by64_IdShouldIncreaseBy64() throws {
        var w = try WUID(step: .by64, name: "by 64", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 64, "First ID should be 64")
        XCTAssertEqual(w.next(), (1 << 36) + 128, "Second ID should be 128")
    }
    
    func testStep_by128_IdShouldIncreaseBy128() throws {
        var w = try WUID(step: .by128, name: "by 128", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 128, "First ID should be 128")
        XCTAssertEqual(w.next(), (1 << 36) + 256, "Second ID should be 256")
    }
    
    func testStep_by256_IdShouldIncreaseBy256() throws {
        var w = try WUID(step: .by256, name: "by 256", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 256, "First ID should be 256")
        XCTAssertEqual(w.next(), (1 << 36) + 512, "Second ID should be 512")
    }
    
    func testStep_by512_IdShouldIncreaseBy512() throws {
        var w = try WUID(step: .by512, name: "by 512", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 512, "First ID should be 512")
        XCTAssertEqual(w.next(), (1 << 36) + 1024, "Second ID should be 1024")
    }
    
    func testStep_by1024_IdShouldIncreaseBy1024() throws {
        var w = try WUID(step: .by1024, name: "by 1024", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 1024, "First ID should be 1024")
        XCTAssertEqual(w.next(), (1 << 36) + 2048, "Second ID should be 2048")
    }
    
    func testReservedDecimalDigits_by16WithOneReservedDigit_IdShouldIncreaseBy10() throws {
        var w = try WUID(
            step: .by16,
            reservedDecimalDigits: .one,
            name: "by 16 with reserved digits",
            h28: { 1 << 36 })
        XCTAssertEqual(w.next(), 68719476750, "With one reserved digit last decimal digit should be 0")
        XCTAssertEqual(w.next(), 68719476760, "With one reserved digit last decimal digit should be 0")
    }
    
    func testReservedDecimalDigits_by1024WithThreeReservedDigits_IdShouldIncreaseBy1000() throws {
        var w = try WUID(
            step: .by1024,
            reservedDecimalDigits: .three,
            name: "by 1024 with reserved digits",
            h28: { 1 << 36 })
        XCTAssertEqual(w.next(), 68719477000, "With three reserved digits last 3 decimal digits should be 000")
        XCTAssertEqual(w.next(), 68719478000, "With three reserved digits last 3 decimal digits should be 000")
        XCTAssertEqual(w.next(), 68719479000, "With three reserved digits last 3 decimal digits should be 000")
    }
    
    func testWUID_next() throws {
        for i in 0..<100 {
            var w = try WUID(name: "alpha", h28: { 1 << 36 })
            try w.reset(to: Int64(i+1) << 36)
            var v = w.n
            for _ in 0..<100 {
                v += 1
                let id = w.next()
                XCTAssert(id == v, "the id is \(id), while it should be \(v)")
            }
        }
    }
    
    func testNext_withCriticalValue_h28renewed() throws {
        var expectingRenew = false
        var w = try WUID(step: .by1, name: "Renewed on critical", h28: {
            if expectingRenew {
                return (2 << 36)
            }
            return (1 << 36)
        })
        try w.reset(to: (1 << 36) + (WUID.criticalValue - 1))
        expectingRenew = true
        XCTAssertEqual(w.next(), (2 << 36) + 1)
    }
    
    func testNext_withStep1CriticalValueAndH28RenewFailure_willRetryAfterInterval() throws {
        let originalRenewInterval = WUID.renewInterval
        WUID.renewInterval = 1 << 4
        enum Errors: Error {
            case simulatedFailure
        }
        var expectingRenew = false
        var shouldFail = true
        var w = try WUID(step: .by1, name: "Renewed on critical", h28: {
            if expectingRenew {
                if shouldFail {
                    throw Errors.simulatedFailure
                }
                return (2 << 36)
            }
            return (1 << 36)
        })
        try w.reset(to: (1 << 36) + WUID.criticalValue - 1)
        expectingRenew = true
        for i in 0..<WUID.renewInterval {
            XCTAssertEqual(w.next(), (1 << 36) + WUID.criticalValue + i,
                           "When H28 renew fails, ID should be incremented as usual")
        }
        shouldFail = false
        XCTAssertEqual(w.next(), (2 << 36) + 1, "H28 renewal should be re-attempted after renewInterval/step IDs are generated")
        WUID.renewInterval = originalRenewInterval
    }
    
    func testSection_highestBitsShouldMatchSection() throws {
        for i in 0...7 {
            var w = try WUID(section: .value(UInt8(i)), name: "With section", h28: { 1 << 36 })
            XCTAssertEqual(w.next(), ( Int64(i) << 60 | 1 << 36 | 1 ), "Section bits should be in bit positions 61-63")
            XCTAssertEqual(w.next(), ( Int64(i) << 60 | 1 << 36 | 2 ), "Section bits should be in bit positions 61-63")
        }
    }
    
    func testSectionAndReservedDigits_shouldThrow() throws {
        XCTAssertThrowsError(try WUID(
            step: .by1024,
            reservedDecimalDigits: .two,
            section: .value(5),
            name: "Invalid configuration",
            h28: { 1 << 36 }))
    }
    
    func testSection_valueOutOfRange_shouldThrow() throws {
        XCTAssertThrowsError(try WUID(
            step: .by1024,
            section: .value(22),
            name: "Invalid configuration",
            h28: { 1 << 36 }))
    }
    
    func testObfuscation_withoutReservedDecimalDigits() throws {
        // values based on
        // wuid.NewWUID("Obfuscated", slog.NewScavenger(), wuid.WithObfuscation(0x1234567890ABCDEF))
        var w = try WUID(
            obfuscation: .v1(seed: 0x1234567890ABCDEF),
            name: "Obfuscated",
            h28: { 1 << 36 })
        XCTAssertEqual(w.next(), 0x00000012e5aefe5d)
        XCTAssertEqual(w.next(), 0x00000012e5aefe5e)
    }
    
    func testObfuscation_withReservedDecimalDigits() throws {
        // values based on
        // wuid.NewWUID("Obfuscated", slog.NewScavenger(), wuid.WithStep(1024, 1000), wuid.WithObfuscation(0x1234567890ABCDEF))
        var w = try WUID(
            step: .by1024,
            reservedDecimalDigits: .three,
            obfuscation: .v1(seed: 0x1234567890ABCDEF),
            name: "Obfuscated",
            h28: { 1 << 36 })
        XCTAssertEqual(w.next(), 81162861000)
        XCTAssertEqual(w.next(), 81162860000)
        XCTAssertEqual(w.next(), 81162859000)
    }
    
    func testPerformanceUUID() {
        measure {
            for _ in 0...100_000 {
                _ = UUID()
            }
        }
    }
    
    func testPerformanceWUID() {
        measure {
            var w = try! WUID(name: "Performance", h28: { 1 << 36 })
            for _ in 0...100_000 {
                _ = w.next()
            }
        }
    }
    
    func testPerformanceWUID_obfuscated() {
        measure {
            var w = try! WUID(
                obfuscation: .v1(seed: .random(in: UInt64.min...UInt64.max)),
                name: "Performance",
                h28: { 1 << 36 })
            for _ in 0...100_000 {
                _ = w.next()
            }
        }
    }
}
