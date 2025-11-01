//
//  MockAgeRangeProvider.swift
//  AgeRangeKit
//
//  Created by Muthu L on 01/11/25.
//

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

// MARK: - MockAgeRangeProvider

/// A simple mock provider that allows developers to simulate all possible responses and errors.
public class MockAgeRangeProvider: AgeRangeProviderProtocol {
    /// Enum covering all possible responses and errors for the mock.
    public enum MockScenario {
        /// The person declined to share their age range.
        case declinedSharing
        /// The person shared as a child (e.g., under 13).
        case sharingChild
        /// The person shared as a teen (e.g., 13-17).
        case sharingTeen
        /// The person shared as an adult (e.g., 18+).
        case sharingAdult
        /// The system was unable to share the person's age.
        case errorNotAvailable
        /// The request is invalid.
        case errorInvalidRequest
        /// An unknown error occurred.
        case errorUnknown
    }

    /// The current scenario to simulate.
    public var currentScenario: MockScenario

    /// The default scenario is declinedSharing.
    public init(initialScenario: MockScenario = .declinedSharing) {
        self.currentScenario = initialScenario
    }

    #if canImport(UIKit)
    public func requestAgeRange(ageGates threshold1: Int, _ threshold2: Int?, _ threshold3: Int?, in viewController: UIViewController) async throws -> AgeRangeService.Response {
        return try await requestAgeRange(ageGates: threshold1, threshold2, threshold3)
    }
    #elseif canImport(AppKit)
    public func requestAgeRange(ageGates threshold1: Int, _ threshold2: Int?, _ threshold3: Int?, in window: NSWindow) async throws -> AgeRangeService.Response {
        return try await requestAgeRange(ageGates: threshold1, threshold2, threshold3)
    }
    #endif
    
    private func requestAgeRange(ageGates threshold1: Int, _ threshold2: Int?, _ threshold3: Int?) async throws -> AgeRangeService.Response {
        switch currentScenario {
        case .declinedSharing:
            return .declinedSharing
        case .sharingChild:
            let range = AgeRangeService.AgeRange(
                lowerBound: 8,
                upperBound: 12,
                ageRangeDeclaration: .selfDeclared,
                activeParentalControls: [.contentRestrictions, .screenTimeLimits]
            )
            return .sharing(range: range)
        case .sharingTeen:
            let range = AgeRangeService.AgeRange(
                lowerBound: 14,
                upperBound: 17,
                ageRangeDeclaration: .selfDeclared,
                activeParentalControls: []
            )
            return .sharing(range: range)
        case .sharingAdult:
            let range = AgeRangeService.AgeRange(
                lowerBound: 18,
                upperBound: nil,
                ageRangeDeclaration: .selfDeclared,
                activeParentalControls: []
            )
            return .sharing(range: range)
        case .errorNotAvailable:
            throw AgeRangeService.Error.notAvailable
        case .errorInvalidRequest:
            throw AgeRangeService.Error.invalidRequest
        case .errorUnknown:
            throw AgeRangeService.Error.unknown
        }
    }

    /// Resets the mock scenario to the default value (.declinedSharing).
    public func resetMockData() {
        currentScenario = .declinedSharing
    }
}

private class AlternateMockAgeRangeProvider: AgeRangeProviderProtocol {
    private struct MockUserDefaults: Codable {
        var isSetupCompleted: Bool
        var dateOfBirth: Date?
        var sharingPreference: SharingPreference
//        var activeParentalControls: AgeRangeService.ParentalControls
        
        enum SharingPreference: String, Codable {
            case alwaysShare
            case askFirst
            case never
        }
    }
    
    private let userDefaultsKey = "com.agerangekit.mock.preferences"
    private var preferences: MockUserDefaults {
        get {
            guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
                  let prefs = try? JSONDecoder().decode(MockUserDefaults.self, from: data) else {
                return MockUserDefaults(
                    isSetupCompleted: false,
                    dateOfBirth: nil,
                    sharingPreference: .askFirst,
//                    activeParentalControls: []
                )
            }
            return prefs
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: userDefaultsKey)
            }
        }
    }
    
    #if canImport(UIKit)
    public func requestAgeRange(ageGates threshold1: Int, _ threshold2: Int?, _ threshold3: Int?, in viewController: UIViewController) async throws -> AgeRangeService.Response {
        try await requestAgeRange(ageGates: threshold1, threshold2, threshold3)
    }
    #elseif canImport(AppKit)
    public func requestAgeRange(ageGates threshold1: Int, _ threshold2: Int?, _ threshold3: Int?, in window: NSWindow) async throws -> AgeRangeService.Response {
        try await requestAgeRange(ageGates: threshold1, threshold2, threshold3)
    }
    #endif
    
    private func requestAgeRange(ageGates threshold1: Int, _ threshold2: Int?, _ threshold3: Int?) async throws -> AgeRangeService.Response {
        return try await withCheckedThrowingContinuation { continuation in
            let prefs = self.preferences
            
            if !prefs.isSetupCompleted {
                self.presentSetupIfNeeded { success in
                    if success {
                        self.handleResponse(continuation: continuation)
                    } else {
                        continuation.resume(throwing: AgeRangeService.Error.notAvailable)
                    }
                }
            } else {
                switch prefs.sharingPreference {
                case .alwaysShare:
                    self.handleResponse(continuation: continuation)
                case .askFirst:
                    self.presentPermissionPrompt { allowed in
                        if allowed {
                            self.handleResponse(continuation: continuation)
                        } else {
                            continuation.resume(returning: .declinedSharing)
                        }
                    }
                case .never:
                    continuation.resume(returning: .declinedSharing)
                }
            }
        }
    }
    
    private func handleResponse(continuation: CheckedContinuation<AgeRangeService.Response, Error>) {
        let prefs = self.preferences
        guard let dob = prefs.dateOfBirth else {
            continuation.resume(returning: .declinedSharing)
            return
        }
        
        // Calculate age range from DOB
        let calendar = Calendar.current
        let now = Date()
        let age = calendar.dateComponents([.year], from: dob, to: now).year ?? 0
        
        let ageRange = AgeRangeService.AgeRange(
            lowerBound: age,
            upperBound: age,
            ageRangeDeclaration: .selfDeclared,
//            activeParentalControls: prefs.activeParentalControls
        )
        continuation.resume(returning: .sharing(range: ageRange))
    }
    
    private func presentPermissionPrompt(completion: @escaping (Bool) -> Void) {
        // TODO: Present an alert asking for permission to share age
        // For now, simulate user allowing
        completion(true)
    }
    
    func presentSetupIfNeeded(_ completion: @escaping (Bool) -> Void) {
        var prefs = preferences
        // TODO: Present the actual setup UI
        // For now, simulate a successful setup with sample data
        prefs.isSetupCompleted = true
        prefs.dateOfBirth = Calendar.current.date(byAdding: .year, value: -16, to: Date())
        prefs.sharingPreference = .askFirst
//        prefs.activeParentalControls = []
        preferences = prefs
        completion(true)
    }
    
    public init() {}
    
    public func resetMockData() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

//    public func updateMockSettings(dateOfBirth: Date?, sharingPreference: SharingPreference) {
//        var prefs = preferences
//        prefs.dateOfBirth = dateOfBirth
//        prefs.sharingPreference = sharingPreference
//        preferences = prefs
//    }
//
//    public func currentMockSettings() -> (dateOfBirth: Date?, sharingPreference: SharingPreference) {
//        let prefs = preferences
//        return (prefs.dateOfBirth, prefs.sharingPreference)
//    }
}
