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
        var w = try WUID(step: .by4, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 4, "First ID should be 4")
        XCTAssertEqual(w.next(), (1 << 36) + 8, "Second ID should be 8")
    }
    
    func testStep_by8_IdShouldIncreaseBy8() throws {
        var w = try WUID(step: .by8, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 8, "First ID should be 8")
        XCTAssertEqual(w.next(), (1 << 36) + 16, "Second ID should be 16")
    }
    
    func testStep_by16_IdShouldIncreaseBy16() throws {
        var w = try WUID(step: .by16, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 16, "First ID should be 16")
        XCTAssertEqual(w.next(), (1 << 36) + 32, "Second ID should be 32")
    }
    
    func testStep_by32_IdShouldIncreaseBy32() throws {
        var w = try WUID(step: .by32, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 32, "First ID should be 32")
        XCTAssertEqual(w.next(), (1 << 36) + 64, "Second ID should be 64")
    }
    
    func testStep_by64_IdShouldIncreaseBy64() throws {
        var w = try WUID(step: .by64, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 64, "First ID should be 64")
        XCTAssertEqual(w.next(), (1 << 36) + 128, "Second ID should be 128")
    }
    
    func testStep_by128_IdShouldIncreaseBy128() throws {
        var w = try WUID(step: .by128, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 128, "First ID should be 128")
        XCTAssertEqual(w.next(), (1 << 36) + 256, "Second ID should be 256")
    }
    
    func testStep_by256_IdShouldIncreaseBy256() throws {
        var w = try WUID(step: .by256, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 256, "First ID should be 256")
        XCTAssertEqual(w.next(), (1 << 36) + 512, "Second ID should be 512")
    }
    
    func testStep_by512_IdShouldIncreaseBy512() throws {
        var w = try WUID(step: .by512, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 512, "First ID should be 512")
        XCTAssertEqual(w.next(), (1 << 36) + 1024, "Second ID should be 1024")
    }
    
    func testStep_by1024_IdShouldIncreaseBy1024() throws {
        var w = try WUID(step: .by1024, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 1024, "First ID should be 1024")
        XCTAssertEqual(w.next(), (1 << 36) + 2048, "Second ID should be 2048")
    }
    
    func testReservedDecimalDigits_by16WithOneReservedDigit_IdShouldIncreaseBy10() throws {
        var w = try WUID(
            step: .by16,
            reservedDecimalDigits: .one,
            name: "by 2 with reserved digits",
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
}


//
//func TestWithSection_Reset(t *testing.T) {
//    for i := 0; i < 28; i++ {
//        n := int64(1) << (uint(i) + 36)
//        func() {
//            defer func() {
//                if r := recover(); r != nil {
//                    if i != 27 {
//                        t.Fatal(r)
//                    }
//                }
//            }()
//            for j := int8(1); j < 8; j++ {
//                w := NewWUID("alpha", nil, WithSection(j))
//                w.Reset(n)
//                v := atomic.LoadInt64(&w.N)
//                if v>>60 != int64(j) {
//                    t.Fatalf("w.Section does not work as expected. w.N: %x, n: %x, i: %d, j: %d", v, n, i, j)
//                }
//            }
//        }()
//    }
//
//    func() {
//        defer func() {
//            _ = recover()
//        }()
//        w := NewWUID("alpha", nil)
//        w.Reset((1 << 36) | PanicValue)
//        t.Fatal("Reset should have panicked")
//    }()
//}
//
//func TestWithH28Verifier(t *testing.T) {
//    w := NewWUID("alpha", nil, WithH28Verifier(func(h28 int64) error {
//        if h28 >= 20 {
//            return errors.New("bomb")
//        }
//        return nil
//    }))
//    if err := w.VerifyH28(10); err != nil {
//        t.Fatal("the H28Verifier should not return error")
//    }
//    if err := w.VerifyH28(20); err == nil || err.Error() != "bomb" {
//        t.Fatal("the H28Verifier was not called")
//    }
//}
//
////gocyclo:ignore
//func TestWithObfuscation(t *testing.T) {
//    w1 := NewWUID("alpha", nil, WithObfuscation(1))
//    if w1.Flags != 1 {
//        t.Fatal(`w1.Flags != 1`)
//    }
//    if w1.ObfuscationMask == 0 {
//        t.Fatal(`w1.ObfuscationMask == 0`)
//    }
//
//    w1.Reset(1 << 36)
//    for i := 1; i < 100; i++ {
//        v := w1.Next()
//        if v&H28Mask != 1<<36 {
//            t.Fatal(`v&H28Mask != 1<<36`)
//        }
//        tmp := v ^ w1.ObfuscationMask
//        if tmp&L36Mask != int64(i) {
//            t.Fatal(`tmp&L36Mask != int64(i)`)
//        }
//    }
//
//    w2 := NewWUID("alpha", nil, WithObfuscation(1), WithStep(128, 100))
//    if w2.Flags != 3 {
//        t.Fatal(`w2.Flags != 3`)
//    }
//    if w2.ObfuscationMask == 0 {
//        t.Fatal(`w2.ObfuscationMask == 0`)
//    }
//
//    w2.Reset(1 << 36)
//    for i := 1; i < 100; i++ {
//        v := w2.Next()
//        if v%w2.Floor != 0 {
//            t.Fatal(`v%w2.Floor != 0`)
//        }
//        if v&H28Mask != 1<<36 {
//            t.Fatal(`v&H28Mask != 1<<36`)
//        }
//        tmp := v ^ w2.ObfuscationMask
//        if tmp&L36Mask&^(w2.Step-1) != w2.Step*int64(i) {
//            t.Fatal(`tmp&L36Mask&^(w2.Step-1) != w2.Step*int64(i)`)
//        }
//    }
//
//    w3 := NewWUID("alpha", nil, WithObfuscation(1), WithStep(1024, 659))
//    if w3.Flags != 3 {
//        t.Fatal(`w3.Flags != 3`)
//    }
//    if w3.ObfuscationMask == 0 {
//        t.Fatal(`w3.ObfuscationMask == 0`)
//    }
//
//    w3.Reset(1<<36 + 1)
//    for i := 1; i < 100; i++ {
//        v := w3.Next()
//        if v%w3.Floor != 0 {
//            t.Fatal(`v%w3.Floor != 0`)
//        }
//        if v&H28Mask != 1<<36 {
//            t.Fatal(`v&H28Mask != 1<<36`)
//        }
//        tmp := v ^ w3.ObfuscationMask
//        if tmp&L36Mask&^(w3.Step-1) != w3.Step*int64(i+1) {
//            t.Fatal(`tmp&L36Mask&^(w3.Step-1) != w3.Step*int64(i+1)`)
//        }
//    }
//
//    func() {
//        defer func() {
//            _ = recover()
//        }()
//        NewWUID("alpha", nil, WithObfuscation(0))
//        t.Fatal("WithObfuscation should have panicked")
//    }()
