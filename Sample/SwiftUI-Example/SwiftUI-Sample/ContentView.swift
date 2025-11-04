//
//  ContentView.swift
//  DeclaredAppRange
//
//  Created by Muthu L on 25/10/25.
//

// Request an age range

import SwiftUI
import AgeRangeKit
import SwiftData

struct LandmarkDetail: View {
    // ...
    @State var photoSharingEnabled = false
    @Environment(\.requestAgeRange) var requestAgeRange
    
    var body: some View {
        ScrollView {
            // ...
            Button("Share Photos") {}
                .disabled(!photoSharingEnabled)
        }
        .task {
            await requestAgeRangeHelper()
        }
    }

    func requestAgeRangeHelper() async {
        do {
            // TODO: Check user region
            let ageRangeResponse = try await requestAgeRange(ageGates: 16)
            switch ageRangeResponse {
            case let .sharing(range):
                 // Age range shared
                if let lowerBound = range.lowerBound, lowerBound >= 16 {
                    photoSharingEnabled = true
                }
                // guardianDeclared, selfDeclared
                print(range.ageRangeDeclaration ?? .selfDeclared)
            case .declinedSharing:
                // Declined to share
                print("Declined to share")
            @unknown default:
                print("Default to share")
            }
        } catch AgeRangeService.Error.invalidRequest {
            print("Handle invalid request error")
        } catch AgeRangeService.Error.notAvailable {
            print("Handle not available error")
        } catch {
            print("Unhandled error: \(error)")
        }
    }
}

#Preview {
    LandmarkDetail()
        .modelContainer(for: Item.self, inMemory: true)
        .environment(\.requestAgeRange, AgeRangeService(MockAgeRangeProvider(initialScenario: .sharingAdult)))
}
