//
//  MemoFluxApp.swift
//  MemoFlux
//
//  Created by 马硕 on 2025/7/24.
//

import SwiftData
import SwiftUI

@main
struct MemoFluxApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: MemoItemModel.self)
    }
}
