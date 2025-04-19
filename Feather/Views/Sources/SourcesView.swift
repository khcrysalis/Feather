//
//  SourcesView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import CoreData
import SwiftUI

struct SourcesView: View {
	@Environment(\.managedObjectContext) private var viewContext

	@FetchRequest(
		entity: AltSource.entity(),
		sortDescriptors: [
			NSSortDescriptor(keyPath: \AltSource.name, ascending: false)
		],
		animation: .snappy
	) private var sources: FetchedResults<AltSource>
	
	@StateObject private var vm = SourcesViewModel()

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


final class SourcesViewModel: ObservableObject {
	@Published var sources: [Repository] = []
	@Published var status: [Repository.ID: RepoStatus] = [:]
	
	func fetchSources() async {
		fatalError("Unimplemented")
	}
	
	enum RepoStatus {
		case ready
		case loading
		case error(Error)
	}
}
