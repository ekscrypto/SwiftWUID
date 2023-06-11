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
    
    private static let sectionMask: Int64 = 0x3000000000000000
    
    internal var n: Int64
    private var step: Int64
    private var floor: Int64
    
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
    
    public struct Flags: OptionSet {
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        public static let obfuscated = Flags(rawValue: 1 << 0)
        public static let monolithic = Flags(rawValue: 1 << 1)
        public static let withSection = Flags(rawValue: 1 << 2)
    }
    
    public private(set) var flags: Flags
    private var obfuscationMask: Int64
    private let name: String
    private var numRenewed: Int64 = 0
    
    private var loadH28: () throws -> Int64
    
    private mutating func renew() throws {
        let existingH28 = n & Self.h28Mask
        let h28 = try loadH28() & Self.h28Mask
        guard h28 > 0 else {
            throw Errors.h28MustBePositiveAndNonZero
        }
        guard existingH28 != h28 else {
            throw Errors.h28ShouldBeDifferent
        }
        n = (n & Self.sectionMask) | h28 | step
        numRenewed += 1
    }
    
    public enum Errors: Error {
        case floorMustBePostiveAndLowerThanStep
        case sectionMustBePostiveAndLowerOrEqualToSeven
        case h28MustBePositiveAndNonZero
        case h28ShouldBeDifferent
        case cannotResetToNegativeValue
        case valueIsAbovePanicValue
    }
    
    /// Creates a new WUID generator
    ///
    /// When the next ID is computed, it is an increment of (step / floor * floor)
    ///
    /// - Parameters:
    ///   - step: increment for ID computations
    ///   - floor: increment base, used to inject +/- 1 variations of the final ID produced
    ///   - flags: options to enable (monolithic, obfuscation)
    ///   - section: Value for bits 61-63 of the final ID (before obfuscation)
    ///   - name: reference name to assign to this generator
    ///   - h28: function to produce bits 37-63
    public init(
        step providedStep: Step = .by1,
        floor providedFloor: Int64 = 0,
        flags providedFlags: Flags = [],
        section providedSection: Int64 = 0,
        name providedName: String,
        h28: @escaping () throws -> Int64
    ) throws {
        name = providedName
        step = providedStep.rawValue
        flags = providedFlags
        loadH28 = h28

        if !providedFlags.contains(.monolithic), providedSection != 0 {
            guard providedSection >= 0, providedSection <= 7 else {
                throw Errors.sectionMustBePostiveAndLowerOrEqualToSeven
            }
            n = providedSection << 60
        } else {
            n = 0
        }
        
        if flags.contains(.obfuscated), providedFloor == 0 {
            let ones = step - 1
            obfuscationMask = ones
        } else {
            obfuscationMask = 0
        }
        
        if providedFloor != 0, (providedFloor < 0 || providedFloor >= step) {
            throw Errors.floorMustBePostiveAndLowerThanStep
        }
        
        floor = providedFloor
        if providedFloor >= 2 {
            flags = flags.union(.monolithic)
        } else {
            flags = flags.subtracting(.monolithic)
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

        switch flags {
        case []:
            return v1
        case .obfuscated:
            let x = v1 ^ obfuscationMask
            return (v1 & Self.h28Mask) | (x & Self.l36Mask)
        case .monolithic:
            return v1 / floor * floor
        case [.monolithic, .obfuscated]:
            let x = v1 ^ obfuscationMask
            let q = (v1 & Self.h28Mask) | (x & Self.l36Mask)
            return q / floor * floor
        default:
            fatalError("Implementation incomplete")
        }
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

        if flags.contains(.monolithic) {
            updatedN |= n & Self.sectionMask
        }
        
        if floor > 1 {
            if updatedN & (step - 1) != 0 {
                updatedN = updatedN & ~(step - 1) + step
            }
        }
        n = updatedN
    }
}
