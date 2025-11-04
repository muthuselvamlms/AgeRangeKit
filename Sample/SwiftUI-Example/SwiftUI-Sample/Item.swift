//
//  Item.swift
//  SwiftUI-Sample
//
//  Created by Muthu L on 02/11/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
