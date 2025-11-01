//
//  AppleAgeRangeProvider.swift
//  DeclaredAgeRangeKit
//
//  Created by Muthu L on 01/11/25.
//

#if canImport(DeclaredAgeRange)
import DeclaredAgeRange
#endif
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@available(iOS 26.0, macOS 26.0, *)
@available(visionOS, unavailable)
public struct AppleAgeRangeProvider: AgeRangeProviderProtocol {
    private var ageRangeService = DeclaredAgeRange.AgeRangeService.shared
    
    #if canImport(UIKit)
    public func requestAgeRange(ageGates threshold1: Int, _ threshold2: Int?, _ threshold3: Int?, in window: UIViewController) async throws -> AgeRangeService.Response {
        do {
            let response = try await ageRangeService.requestAgeRange(ageGates: threshold1, threshold2, threshold3, in: window)
            return try handleResponse(response: response)
        } catch {
            let error = handleError(error: error)
            throw error
        }
    }
    #elseif canImport(AppKit)
    public func requestAgeRange(ageGates threshold1: Int, _ threshold2: Int?, _ threshold3: Int?, in window: NSWindow) async throws -> AgeRangeService.Response {
        do {
            let response = try await ageRangeService.requestAgeRange(ageGates: threshold1, threshold2, threshold3, in: window)
            return try handleResponse(response: response)
        } catch {
            let error = handleError(error: error)
            throw error
        }
    }
    #endif
    
    private func handleResponse(response: DeclaredAgeRange.AgeRangeService.Response) throws -> AgeRangeService.Response {
        switch response {
        case .declinedSharing:
            return .declinedSharing
        case .sharing(let range):
            return .sharing(range: AgeRangeService.AgeRange(
                lowerBound: range.lowerBound,
                upperBound: range.upperBound,
                ageRangeDeclaration: range.ageRangeDeclaration == .selfDeclared ? AgeRangeService.AgeRangeDeclaration.selfDeclared : AgeRangeService.AgeRangeDeclaration.guardianDeclared,
                activeParentalControls: AgeRangeService.ParentalControls(rawValue: range.activeParentalControls.rawValue)
            ))
        @unknown default:
            throw AgeRangeService.Error.notAvailable
        }
    }
    
    private func handleError(error: Error) -> Error {
        if let error = error as? DeclaredAgeRange.AgeRangeService.Error {
            switch error {
            case .invalidRequest:
                return AgeRangeService.Error.invalidRequest
            case .notAvailable:
                return AgeRangeService.Error.notAvailable
            @unknown default:
                return AgeRangeService.Error.unknown
            }
        } else {
            return AgeRangeService.Error.unknown
        }
    }
    
    public init() {}
    
    public func resetMockData() {
        // Apple's API does not provide a resetMockData method
        // No-op
    }
}
