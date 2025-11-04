//
//  SwiftUI_SampleApp.swift
//  SwiftUI-Sample
//
//  Created by Muthu L on 02/11/25.
//

import SwiftUI
import SwiftData
import AgeRangeKit

@main
struct SwiftUI_SampleApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LandmarkDetail()
        }
        .modelContainer(sharedModelContainer)
        .environment(\.requestAgeRange, AgeRangeService(MockAgeRangeProvider(initialScenario: .sharingAdult)))
    }
}
