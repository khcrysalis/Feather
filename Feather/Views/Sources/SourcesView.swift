//
//  SourcesView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI
import CoreData

struct SourcesView: View {
    @Environment(\.managedObjectContext) private var viewContext
	
	@FetchRequest(entity: AltSource.entity(),
				  sortDescriptors: [NSSortDescriptor(keyPath: \AltSource.name, ascending: false)],
				  animation: .snappy
	) private var sources: FetchedResults<AltSource>

    var body: some View {
		FRNavigationView("Sources") {
            List {
				ForEach(sources, id: \.identifier) { source in
					Text(source.name ?? "")
				}
            }
        }
    }
}
