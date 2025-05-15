//
//  ContentView.swift
//  Feather
//
//  Created by samara on 10.04.2025.
//

import SwiftUI
import CoreData
import NimbleViews

// MARK: - View
struct LibraryView: View {
	@StateObject var downloadManager = DownloadManager.shared
	
	@State private var _selectedInfoAppPresenting: AnyApp?
	@State private var _selectedSigningAppPresenting: AnyApp?
	@State private var _selectedInstallAppPresenting: AnyApp?
	@State private var _isImportingPresenting = false
	@State private var _isDownloadingPresenting = false
	@State private var _isImporting = false // for Loading Overlay
	@State private var _alertDownloadString: String = "" // for _isDownloadingPresenting
	
	@State private var _searchText = ""
	@State private var _selectedScope: Scope = .all
	
	@Namespace private var _namespace
	
	// horror
	private func filteredAndSortedApps<T>(from apps: FetchedResults<T>) -> [T] where T: NSManagedObject {
		apps.filter {
			_searchText.isEmpty ||
			(($0.value(forKey: "name") as? String)?.localizedCaseInsensitiveContains(_searchText) ?? false)
		}
	}
	
	private var _filteredSignedApps: [Signed] {
		filteredAndSortedApps(from: _signedApps)
	}
	
	private var _filteredImportedApps: [Imported] {
		filteredAndSortedApps(from: _importedApps)
	}
	
	// MARK: Fetch
	@FetchRequest(
		entity: Signed.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \Signed.date, ascending: false)],
		animation: .snappy
	) private var _signedApps: FetchedResults<Signed>
	
	@FetchRequest(
		entity: Imported.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \Imported.date, ascending: false)],
		animation: .snappy
	) private var _importedApps: FetchedResults<Imported>
	
	// MARK: Body
    	var body: some View {
		NBNavigationView(.localized("Library")) {
			ZStack {
				NBListAdaptable {
					if
						_selectedScope == .all ||
						_selectedScope == .signed
					{
						NBSection(
							.localized("Signed"),
							secondary: _filteredSignedApps.count.description
						) {
							ForEach(_filteredSignedApps, id: \.uuid) { app in
								LibraryCellView(
									app: app,
									selectedInfoAppPresenting: $_selectedInfoAppPresenting,
									selectedSigningAppPresenting: $_selectedSigningAppPresenting,
									selectedInstallAppPresenting: $_selectedInstallAppPresenting
								)
								.compatMatchedTransitionSource(id: app.uuid ?? "", ns: _namespace)
							}
						}
					}
					
					if
						_selectedScope == .all ||
						_selectedScope == .imported
					{
						NBSection(
							.localized("Imported"),
							secondary: _filteredImportedApps.count.description
						) {
							ForEach(_filteredImportedApps, id: \.uuid) { app in
								LibraryCellView(
									app: app,
									selectedInfoAppPresenting: $_selectedInfoAppPresenting,
									selectedSigningAppPresenting: $_selectedSigningAppPresenting,
									selectedInstallAppPresenting: $_selectedInstallAppPresenting
								)
								.compatMatchedTransitionSource(id: app.uuid ?? "", ns: _namespace)
							}
						}
					}
				}
				.searchable(text: $_searchText, placement: .platform())
				.compatSearchScopes($_selectedScope) {
					ForEach(Scope.allCases, id: \.displayName) { scope in
						Text(scope.displayName).tag(scope)
					}
				}
				.toolbar {
					NBToolbarMenu(
						systemImage: "plus",
						style: .icon,
						placement: .topBarTrailing
					) {
						Button(.localized("Import from Files")) {
							_isImportingPresenting = true
						}
						Button(.localized("Import from URL")) {
							_isDownloadingPresenting = true
						}
					}
				}
				
				// Loading overlay while importing
				if _isImporting {
					LoadingOverlayView()
				}
			}
			.sheet(item: $_selectedInfoAppPresenting) { app in
				LibraryInfoView(app: app.base)
			}
			.sheet(item: $_selectedInstallAppPresenting) { app in
				InstallPreviewView(app: app.base, isSharing: app.archive)
					.presentationDetents([.height(200)])
					.presentationDragIndicator(.visible)
					.compatPresentationRadius(21)
			}
			.fullScreenCover(item: $_selectedSigningAppPresenting) { app in
				SigningView(app: app.base)
					.compatNavigationTransition(id: app.base.uuid ?? "", ns: _namespace)
			}
			.sheet(isPresented: $_isImportingPresenting) {
				FileImporterRepresentableView(
					allowedContentTypes: [.ipa, .tipa],
					onDocumentsPicked: { urls in
						guard let selectedFileURL = urls.first else { return }
						_isImporting = true // Start showing loading
						FR.handlePackageFile(selectedFileURL) { _ in
							_isImporting = false // Finish loading when import is complete
						}
					}
				)
			}
			.alert(.localized("Import from URL"), isPresented: $_isDownloadingPresenting) {
				TextField(.localized("URL"), text: $_alertDownloadString)
				Button(.localized("Cancel"), role: .cancel) {
					_alertDownloadString = ""
				}
				Button(.localized("OK")) {
					if let url = URL(string: _alertDownloadString) {
						_ = downloadManager.startDownload(from: url)
					}
				}
			}
        }
    }
}

// MARK: - Extension: View (Sort)
extension LibraryView {
	enum Scope: CaseIterable {
		case all
		case signed
		case imported
		
		var displayName: String {
			switch self {
			case .all: return .localized("All")
			case .signed: return .localized("Signed")
			case .imported: return .localized("Imported")
			}
		}
	}
}

// MARK: - Loading Overlay
struct LoadingOverlayView: View {
	var body: some View {
		ZStack {
			Color.black.opacity(0.4)
				.edgesIgnoringSafeArea(.all)
			
			VStack(spacing: 16) {
				ProgressView()
					.scaleEffect(1.2)
					.tint(.white)
			}
			.padding(24)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.fill(Color.gray.opacity(0.7))
			)
		}
		.transition(.opacity)
	}
}
