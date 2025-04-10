//
//  ContentView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI
import CoreData

struct LibraryView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
		NavigationViewWrapper("Library") {
            List {
				
            }
        }
    }
}
