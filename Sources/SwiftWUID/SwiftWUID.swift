// SwiftWUID
//
// Created by Dave Poirier on 2023-06-11
// Copyright © 2023 Dave Poirier. Distributed under MIT License

public struct WUID {
    
    /// panicValue indicates when Next starts to panic.
    internal static let criticalValue: Int64 = ((1 << 36) * 80 / 100) & ~(renewInterval - 1)
    internal static let panicValue: Int64 = ((1 << 36) * 96 / 100) & ~(renewInterval - 1)
    
    /// renewInterval is used to attempt renewal after a given number of ID requests if the
    /// renew attempt at criticalValue failed.
    ///
    /// MUST be a power of 2
    internal static var renewInterval: Int64 = 0x20000000
    
    /// highest 28-bit mask
    private static let h28Mask: Int64 = 0x07FFFFFF << 36
    
    /// lowest 36-bit mask
    private static let l36Mask: Int64 = 0x0FFFFFFFFF
    
    /// lowest 60-bit mask, used in reset()
    private static let l60Mask: Int64 = 0x0FFFFFFFFFFFFFFF
    
    private static let sectionMask: Int64 = 7 << 60
    
    internal var n: Int64
    private var step: Int64
    private var scaledReservedDecimalDigits: Int64
    
    public enum Step: Int64 {
        case by1    = 1
        case by2    = 2
        case by4    = 4
        case by8    = 8
        case by16   = 16
        case by32   = 32
        case by64   = 64
        case by128  = 128
        case by256  = 256
        case by512  = 512
        case by1024 = 1024
    }
    
    private struct Flags: OptionSet {
        let rawValue: UInt8
        
        static let withObfuscation = Flags(rawValue: 1 << 0)
        static let withReservedDecimalDigits = Flags(rawValue: 1 << 1)
        static let withSection = Flags(rawValue: 1 << 2)
    }
    
    public enum Obfuscation {
        case none
        case v1(seed: UInt64)
    }
    
    public enum ReservedDecimalDigits: Int64 {
        case none = 0
        case one = 1
        case two = 2
        case three = 3
    }
    
    public enum Section {
        case none
        case value(UInt8)
    }
    
    private var flags: Flags
    private var obfuscationMask: Int64
    private let name: String
    private var numRenewed: Int64 = 0
    
    private var loadH28: () throws -> Int64
    
    private mutating func renew() throws {
        let existingH28: Int64
        let h28: Int64
        if flags.contains(.withSection) {
            existingH28 = n & Self.h28Mask & Self.l60Mask
            h28 = try loadH28() & Self.h28Mask & Self.l60Mask
        } else {
            existingH28 = n & Self.h28Mask
            h28 = try loadH28() & Self.h28Mask
        }
        
        guard h28 > 0 else {
            throw Errors.h28MustBePositiveAndNonZero
        }
        guard existingH28 != h28 else {
            throw Errors.h28ShouldBeDifferent
        }
        
        if flags.contains(.withSection) {
            n = (n & Self.sectionMask) | h28 | step
        } else {
            n = h28 | step
        }
        
        numRenewed += 1
    }
    
    private static func pow<T: BinaryInteger>(_ base: T, _ power: T) -> T {
        func expBySq(_ y: T, _ x: T, _ n: T) -> T {
            precondition(n >= 0)
            if n == 0 {
                return y
            } else if n == 1 {
                return y * x
            } else if n.isMultiple(of: 2) {
                return expBySq(y, x * x, n / 2)
            } else { // n is odd
                return expBySq(y * x, x * x, (n - 1) / 2)
            }
        }

        return expBySq(1, base, power)
    }
    
    public enum Errors: Error {
        case floorMustBePostiveAndLowerThanStep
        case sectionMustBePostiveAndLowerOrEqualToSeven
        case h28MustBePositiveAndNonZero
        case h28ShouldBeDifferent
        case cannotResetToNegativeValue
        case valueIsAbovePanicValue
        case cannotReserveDecimalDigitsWhenUsingSection
    }
    
    /// Creates a new WUID generator
    ///
    /// The `reservedDecimalDigits` is used to zero-out the lowest decimal digits of an identifier's decimal
    /// representation by the specified number of decimal digits.  The main purpose of this is to allow the caller to
    /// set the lowest decimal digits to a custom value that may represent a specific type so when looking at an
    /// identifier's decimal representation you can quickly identify the type of object represented by this identifier.
    ///
    /// For example, using a step of .by1024 and h28 of 1, the first ID generated would have a value of
    /// 68719477760, by setting `reservedDecimalDigits` to .three, the generated identifier would be 68719477000.
    /// Assuming you want to track a custom object class and assign it a 3 digit value of 169, once the ID is
    /// produced by next() you can then add 169 to the final result obtaining a final value of 68719477169.
    ///
    /// - Parameters:
    ///   - step: increment for ID computations
    ///   - reservedDecimalDigits: how many lowest digits to zero out in the final ID decimal representation
    ///   - flags: options to enable (monolithic, obfuscation)
    ///   - section: Value for bits 61-63 of the final ID (before obfuscation)
    ///   - name: reference name to assign to this generator
    ///   - h28: function to produce bits 37-63
    public init(
        step providedStep: Step = .by1,
        reservedDecimalDigits providedReservedDecimalDigits: ReservedDecimalDigits = .none,
        obfuscation: Obfuscation = .none,
        section providedSection: Section = .none,
        name providedName: String,
        h28: @escaping () throws -> Int64
    ) throws {
        name = providedName
        step = providedStep.rawValue
        flags = []
        loadH28 = h28

        if case .value(let sectionValue) = providedSection {
            guard providedReservedDecimalDigits == .none else {
                throw Errors.cannotReserveDecimalDigitsWhenUsingSection
            }
            guard sectionValue <= 7 else {
                throw Errors.sectionMustBePostiveAndLowerOrEqualToSeven
            }
            n = Int64(sectionValue) << 60
            flags = flags.union(.withSection)
        } else {
            n = 0
        }
        
        switch obfuscation {
        case .none:
            obfuscationMask = 0
        case .v1(let seed):
            flags = flags.union(.withObfuscation)
            var x = seed
            x = (x ^ (x >> 30)) &* UInt64(0xbf58476d1ce4e5b9)
            x = (x ^ (x >> 27)) &* UInt64(0x94d049bb133111eb)
            x = (x ^ (x >> 31)) & UInt64(0x7FFFFFFFFFFFFFFF)
            if providedReservedDecimalDigits == .none {
                let ones = UInt64(step - 1)
                x |= ones
            }
            obfuscationMask = Int64(x)
        }
        
        if providedReservedDecimalDigits != .none {
            scaledReservedDecimalDigits = Self.pow(10, providedReservedDecimalDigits.rawValue)
            guard scaledReservedDecimalDigits < step else {
                throw Errors.floorMustBePostiveAndLowerThanStep
            }
            flags = flags.union(.withReservedDecimalDigits)
        } else {
            scaledReservedDecimalDigits = 1
        }
        
        try renew()
        n = (n & ~Self.l36Mask)
    }
    
    public mutating func loadH28(_ h28: Int64) {
        n = (n & Self.l36Mask) | (h28 & Self.h28Mask)
    }
    
    public mutating func next() -> Int64 {
        n += step
        var v1 = n
        let v2 = v1 & Self.l36Mask
        if v2 >= Self.panicValue {
            fatalError("Too many failed attempts at renewing h28, ID exhausted")
        }
        
        let cv = Self.criticalValue
        let renewInterval = v2 & (Self.renewInterval - 1)
        if v2 >= cv, renewInterval == 0 {
            do {
                try renew()
                v1 = n
            } catch {
                // do nothing, will eventually fatalError
            }
        }

        if flags.contains(.withObfuscation) {
            if flags.contains(.withReservedDecimalDigits) {
                let x = v1 ^ obfuscationMask
                let q = (v1 & Self.h28Mask) | (x & Self.l36Mask)
                return q / scaledReservedDecimalDigits * scaledReservedDecimalDigits
            }

            let x = v1 ^ obfuscationMask
            return (v1 & Self.h28Mask) | (x & Self.l36Mask)
        }

        if flags.contains(.withReservedDecimalDigits) {
            return v1 / scaledReservedDecimalDigits * scaledReservedDecimalDigits
        }
        
        return v1
    }
    
    public mutating func reset(to providedN: Int64) throws {
        var updatedN = providedN & Self.l60Mask
        guard (updatedN & Self.h28Mask) != 0 else {
            throw Errors.h28MustBePositiveAndNonZero
        }

        guard updatedN >= 0 else {
            throw Errors.cannotResetToNegativeValue
        }
        
        guard (updatedN & Self.l36Mask) < Self.panicValue else {
            fatalError("n is too old")
        }

        if flags.contains(.withReservedDecimalDigits) {
            updatedN |= n & Self.sectionMask
        }
        
        if scaledReservedDecimalDigits > 1 {
            if updatedN & (step - 1) != 0 {
                updatedN = updatedN & ~(step - 1) + step
            }
        }
        n = updatedN
    }
}
