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
    
    func testStep_by4_IdShouldIncreaseBy2() throws {
        var w = try WUID(step: .by4, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 4, "First ID should be 4")
        XCTAssertEqual(w.next(), (1 << 36) + 8, "Second ID should be 8")
    }
    
    func testStep_by8_IdShouldIncreaseBy2() throws {
        var w = try WUID(step: .by8, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 8, "First ID should be 8")
        XCTAssertEqual(w.next(), (1 << 36) + 16, "Second ID should be 16")
    }
    
    func testStep_by16_IdShouldIncreaseBy2() throws {
        var w = try WUID(step: .by16, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 16, "First ID should be 16")
        XCTAssertEqual(w.next(), (1 << 36) + 32, "Second ID should be 32")
    }
    
    func testStep_by32_IdShouldIncreaseBy2() throws {
        var w = try WUID(step: .by32, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 32, "First ID should be 32")
        XCTAssertEqual(w.next(), (1 << 36) + 64, "Second ID should be 64")
    }
    
    func testStep_by64_IdShouldIncreaseBy2() throws {
        var w = try WUID(step: .by64, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 64, "First ID should be 64")
        XCTAssertEqual(w.next(), (1 << 36) + 128, "Second ID should be 128")
    }
    
    func testStep_by128_IdShouldIncreaseBy2() throws {
        var w = try WUID(step: .by128, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 128, "First ID should be 128")
        XCTAssertEqual(w.next(), (1 << 36) + 256, "Second ID should be 256")
    }
    
    func testStep_by256_IdShouldIncreaseBy2() throws {
        var w = try WUID(step: .by256, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 256, "First ID should be 256")
        XCTAssertEqual(w.next(), (1 << 36) + 512, "Second ID should be 512")
    }
    
    func testStep_by512_IdShouldIncreaseBy2() throws {
        var w = try WUID(step: .by512, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 512, "First ID should be 512")
        XCTAssertEqual(w.next(), (1 << 36) + 1024, "Second ID should be 1024")
    }
    
    func testStep_by1024_IdShouldIncreaseBy2() throws {
        var w = try WUID(step: .by1024, name: "by 2", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 1024, "First ID should be 1024")
        XCTAssertEqual(w.next(), (1 << 36) + 2048, "Second ID should be 2048")
    }
    
    func testFloor_by2_IdShouldStartAtFloorAndIncreaseBy2() throws {
        var w = try WUID(step: .by2, floor: 1, name: "by 2 with floor", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), (1 << 36) + 2, "When floor is 1 value is simply incremented")
        XCTAssertEqual(w.next(), (1 << 36) + 4, "When floor is 1 value is simply incremented")
    }
    
    func testFloor_by1024_IdShouldStartAtFloorAndIncreaseBy1024() throws {
        var w = try WUID(step: .by1024, floor: 897, name: "by 1024 with floor", h28: { 1 << 36 })
        XCTAssertEqual(w.next(), 0x00000010000003a7) // values produced by original WUID implementation in Go
        XCTAssertEqual(w.next(), 0x0000001000000728)
        XCTAssertEqual(w.next(), 0x0000001000000aa9)
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
        
}

//
//func TestWUID_Next_Panic(t *testing.T) {
//    const total = 100
//    w := NewWUID("alpha", nil)
//    atomic.StoreInt64(&w.N, PanicValue)
//
//    ch := make(chan int64, total)
//    for i := 0; i < total; i++ {
//        go func() {
//            defer func() {
//                if r := recover(); r != nil {
//                    ch <- 0
//                }
//            }()
//
//            ch <- w.Next()
//        }()
//    }
//
//    for i := 0; i < total; i++ {
//        v := <-ch
//        if v != 0 {
//            t.Fatal("something is wrong with Next()")
//        }
//    }
//}
//
//func waitUntilNumRenewAttemptsReaches(t *testing.T, w *WUID, expected int64) {
//    t.Helper()
//    startTime := time.Now()
//    for time.Since(startTime) < time.Second {
//        if atomic.LoadInt64(&w.Stats.NumRenewAttempts) == expected {
//            return
//        }
//        time.Sleep(time.Millisecond * 10)
//    }
//    t.Fatal("timeout")
//}
//
//func waitUntilNumRenewedReaches(t *testing.T, w *WUID, expected int64) {
//    t.Helper()
//    startTime := time.Now()
//    for time.Since(startTime) < time.Second {
//        if atomic.LoadInt64(&w.Stats.NumRenewed) == expected {
//            return
//        }
//        time.Sleep(time.Millisecond * 10)
//    }
//    t.Fatal("timeout")
//}
//
//func TestWUID_Renew(t *testing.T) {
//    w := NewWUID("alpha", slog.NewScavenger())
//    w.Renew = func() error {
//        w.Reset(((atomic.LoadInt64(&w.N) >> 36) + 1) << 36)
//        return nil
//    }
//
//    w.Reset(Bye)
//    n1a := w.Next()
//    if n1a>>36 != 0 {
//        t.Fatal(`n1a>>36 != 0`)
//    }
//
//    waitUntilNumRenewedReaches(t, w, 1)
//    n1b := w.Next()
//    if n1b != 1<<36+1 {
//        t.Fatal(`n1b != 1<<36+1`)
//    }
//
//    w.Reset(1<<36 | Bye)
//    n2a := w.Next()
//    if n2a>>36 != 1 {
//        t.Fatal(`n2a>>36 != 1`)
//    }
//
//    waitUntilNumRenewedReaches(t, w, 2)
//    n2b := w.Next()
//    if n2b != 2<<36+1 {
//        t.Fatal(`n2b != 2<<36+1`)
//    }
//
//    w.Reset(2<<36 | Bye + RenewIntervalMask + 1)
//    n3a := w.Next()
//    if n3a>>36 != 2 {
//        t.Fatal(`n3a>>36 != 2`)
//    }
//
//    waitUntilNumRenewedReaches(t, w, 3)
//    n3b := w.Next()
//    if n3b != 3<<36+1 {
//        t.Fatal(`n3b != 3<<36+1`)
//    }
//
//    w.Reset(Bye + 1)
//    for i := 0; i < 100; i++ {
//        w.Next()
//    }
//    if atomic.LoadInt64(&w.Stats.NumRenewAttempts) != 3 {
//        t.Fatal(`atomic.LoadInt64(&w.Stats.NumRenewAttempts) != 3`)
//    }
//
//    var num int
//    w.Scavenger().Filter(func(level, msg string) bool {
//        if level == slog.LevelInfo && strings.Contains(msg, "renew succeeded") {
//            num++
//        }
//        return true
//    })
//    if num != 3 {
//        t.Fatal(`num != 3`)
//    }
//}
//
//func TestWUID_Renew_Error(t *testing.T) {
//    w := NewWUID("alpha", slog.NewScavenger())
//    w.Renew = func() error {
//        return errors.New("foo")
//    }
//
//    w.Reset((1 >> 36 << 36) | Bye)
//    w.Next()
//    waitUntilNumRenewAttemptsReaches(t, w, 1)
//    w.Next()
//
//    w.Reset((2 >> 36 << 36) | Bye)
//    w.Next()
//    waitUntilNumRenewAttemptsReaches(t, w, 2)
//
//    for i := 0; i < 100; i++ {
//        w.Next()
//    }
//    if atomic.LoadInt64(&w.Stats.NumRenewAttempts) != 2 {
//        t.Fatal(`atomic.LoadInt64(&w.Stats.NumRenewAttempts) != 2`)
//    }
//    if atomic.LoadInt64(&w.Stats.NumRenewed) != 0 {
//        t.Fatal(`atomic.LoadInt64(&w.Stats.NumRenewed) != 0`)
//    }
//
//    var num int
//    w.Scavenger().Filter(func(level, msg string) bool {
//        if level == slog.LevelWarn && strings.Contains(msg, "renew failed") && strings.Contains(msg, "foo") {
//            num++
//        }
//        return true
//    })
//    if num != 2 {
//        t.Fatal(`num != 2`)
//    }
//}
//
//func TestWUID_Renew_Panic(t *testing.T) {
//    w := NewWUID("alpha", slog.NewScavenger())
//    w.Renew = func() error {
//        panic("foo")
//    }
//
//    w.Reset((1 >> 36 << 36) | Bye)
//    w.Next()
//    waitUntilNumRenewAttemptsReaches(t, w, 1)
//    w.Next()
//
//    w.Reset((2 >> 36 << 36) | Bye)
//    w.Next()
//    waitUntilNumRenewAttemptsReaches(t, w, 2)
//
//    for i := 0; i < 100; i++ {
//        w.Next()
//    }
//    if atomic.LoadInt64(&w.Stats.NumRenewAttempts) != 2 {
//        t.Fatal(`atomic.LoadInt64(&w.Stats.NumRenewAttempts) != 2`)
//    }
//    if atomic.LoadInt64(&w.Stats.NumRenewed) != 0 {
//        t.Fatal(`atomic.LoadInt64(&w.Stats.NumRenewed) != 0`)
//    }
//
//    var num int
//    w.Scavenger().Filter(func(level, msg string) bool {
//        if level == slog.LevelWarn && strings.Contains(msg, "renew failed") && strings.Contains(msg, "foo") {
//            num++
//        }
//        return true
//    })
//    if num != 2 {
//        t.Fatal(`num != 2`)
//    }
//}
//
//func TestWUID_Step(t *testing.T) {
//    const step = 16
//    w := NewWUID("alpha", slog.NewScavenger(), WithStep(step, 0))
//    w.Reset(17 << 36)
//
//    w.Renew = func() error {
//        w.Reset(((atomic.LoadInt64(&w.N) >> 36) + 1) << 36)
//        return nil
//    }
//
//    for i := int64(1); i < 100; i++ {
//        if w.Next()&L36Mask != step*i {
//            t.Fatal("w.Next()&L36Mask != step*i")
//        }
//    }
//
//    n1 := w.Next()
//    w.Reset(((n1 >> 36 << 36) | Bye) & ^(step - 1))
//    w.Next()
//    waitUntilNumRenewedReaches(t, w, 1)
//    n2 := w.Next()
//
//    w.Reset(((n2 >> 36 << 36) | Bye) & ^(step - 1))
//    w.Next()
//    waitUntilNumRenewedReaches(t, w, 2)
//    n3 := w.Next()
//
//    if n2>>36-n1>>36 != 1 || n3>>36-n2>>36 != 1 {
//        t.Fatalf("the renew mechanism does not work as expected: %x, %x, %x", n1>>36, n2>>36, n3>>36)
//    }
//
//    var num int
//    w.Scavenger().Filter(func(level, msg string) bool {
//        if level == slog.LevelInfo && strings.Contains(msg, "renew succeeded") {
//            num++
//        }
//        return true
//    })
//    if num != 2 {
//        t.Fatal(`num != 2`)
//    }
//
//    func() {
//        defer func() {
//            _ = recover()
//        }()
//        NewWUID("alpha", nil, WithStep(5, 0))
//        t.Fatal("WithStep should have panicked")
//    }()
//}
//
//func TestWUID_Floor(t *testing.T) {
//    r := rand.New(rand.NewSource(time.Now().Unix()))
//    allSteps := []int64{1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024}
//    for loop := 0; loop < 10000; loop++ {
//        step := allSteps[r.Intn(len(allSteps))]
//        var floor = r.Int63n(step)
//        w := NewWUID("alpha", slog.NewScavenger(), WithStep(step, floor))
//        if floor < 2 {
//            if w.Flags != 0 {
//                t.Fatal(`w.Flags != 0`)
//            }
//        } else {
//            if w.Flags != 2 {
//                t.Fatal(`w.Flags != 2`)
//            }
//        }
//
//        w.Reset(r.Int63n(100) << 36)
//        baseValue := atomic.LoadInt64(&w.N)
//
//        for i := int64(1); i < 100; i++ {
//            x := w.Next()
//            if floor != 0 {
//                if reminder := x % floor; reminder != 0 {
//                    t.Fatal("reminder != 0")
//                }
//            }
//            if x <= baseValue+i*step-step || x > baseValue+i*step {
//                t.Fatal("x <= baseValue+i*step-step || x > baseValue+i*step")
//            }
//        }
//    }
//
//    func() {
//        defer func() {
//            _ = recover()
//        }()
//        NewWUID("alpha", nil, WithStep(1024, 2000))
//        t.Fatal("WithStep should have panicked")
//    }()
//
//    func() {
//        defer func() {
//            _ = recover()
//        }()
//        NewWUID("alpha", nil, WithStep(1024, 0), WithStep(128, 0))
//        t.Fatal("WithStep should have panicked")
//    }()
//}
//
//func TestWUID_VerifyH28(t *testing.T) {
//    w1 := NewWUID("alpha", nil)
//    w1.Reset(H28Mask)
//    if err := w1.VerifyH28(100); err != nil {
//        t.Fatalf("VerifyH28 does not work as expected. n: 100, error: %s", err)
//    }
//    if err := w1.VerifyH28(0); err == nil {
//        t.Fatalf("VerifyH28 does not work as expected. n: 0")
//    }
//    if err := w1.VerifyH28(0x08000000); err == nil {
//        t.Fatalf("VerifyH28 does not work as expected. n: 0x08000000")
//    }
//    if err := w1.VerifyH28(0x07FFFFFF); err == nil {
//        t.Fatalf("VerifyH28 does not work as expected. n: 0x07FFFFFF")
//    }
//
//    w2 := NewWUID("alpha", nil, WithSection(1))
//    w2.Reset(H28Mask)
//    if err := w2.VerifyH28(100); err != nil {
//        t.Fatalf("VerifyH28 does not work as expected. section: 1, n: 100, error: %s", err)
//    }
//    if err := w2.VerifyH28(0); err == nil {
//        t.Fatalf("VerifyH28 does not work as expected. section: 1, n: 0")
//    }
//    if err := w2.VerifyH28(0x01000000); err == nil {
//        t.Fatalf("VerifyH28 does not work as expected. section: 1, n: 0x01000000")
//    }
//    if err := w2.VerifyH28(0x00FFFFFF); err == nil {
//        t.Fatalf("VerifyH28 does not work as expected. section: 1, n: 0x00FFFFFF")
//    }
//}
//
//func TestWithSection_Panic(t *testing.T) {
//    for i := -100; i <= 100; i++ {
//        func(j int8) {
//            defer func() {
//                _ = recover()
//            }()
//            WithSection(j)
//            if j >= 8 {
//                t.Fatalf("WithSection should only accept the values in [0, 7]. j: %d", j)
//            }
//        }(int8(i))
//    }
//}
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
