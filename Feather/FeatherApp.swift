//
//  FeatherApp.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI

@main
struct FeatherApp: App {
    let storage = Storage.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, storage.context)
        }
    }
}
