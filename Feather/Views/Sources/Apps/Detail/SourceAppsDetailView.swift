//
//  SourceAppsDetailView.swift
//  Feather
//
//  Created by samsam on 7/25/25.
//

import SwiftUI
import Combine
import AltSourceKit
import NimbleViews
import NukeUI

// MARK: - SourceAppsDetailView
struct SourceAppsDetailView: View {
	@ObservedObject var downloadManager = DownloadManager.shared
	@State private var _downloadProgress: Double = 0
	@State var cancellable: AnyCancellable? // Combine
	@State private var _isScreenshotPreviewPresented: Bool = false
	@State private var _selectedScreenshotIndex: Int = 0
	
	var currentDownload: Download? {
		downloadManager.getDownload(by: app.currentUniqueId)
	}
	
	var source: ASRepository
	var app: ASRepository.App
	
    var body: some View {
		ScrollView {
			if #available(iOS 18, *) {
				_header().flexibleHeaderContent()
			}
			
			VStack(alignment: .leading, spacing: 10) {
				HStack(spacing: 10) {
					if let iconURL = app.iconURL {
						LazyImage(url: iconURL) { state in
							if let image = state.image {
								image.appIconStyle(size: 111, isCircle: false)
							} else {
								standardIcon
							}
						}
					} else {
						standardIcon
					}

					VStack(alignment: .leading, spacing: 2) {
						Text(app.currentName)
							.font(.title2)
							.fontWeight(.semibold)
							.foregroundColor(.primary)
						Text(app.currentDescription ?? .localized("An awesome application"))
							.font(.subheadline)
							.foregroundColor(.secondary)
						
						Spacer()
						
						DownloadButtonView(app: app)
					}
					.lineLimit(2)
					.frame(maxWidth: .infinity, alignment: .leading)
				}
				
				Divider()
				_infoPills(app: app)
				Divider()
                
                if let screenshotURLs = app.screenshotURLs {
                    NBSection(.localized("Screenshots")) {
                        _screenshots(screenshotURLs: screenshotURLs)
                    }
                    
                    Divider()
                }
				
				if
					let currentVer = app.currentVersion,
					let whatsNewDesc = app.currentAppVersion?.localizedDescription
				{
					NBSection(.localized("What's New")) {
						AppVersionInfo(
							version: currentVer,
							date: app.currentDate?.date,
							description: whatsNewDesc
						)
                        if let versions = app.versions {
                            NavigationLink(
                                destination: VersionHistoryView(app: app, versions: versions)
                                    .navigationTitle(.localized("Version History"))
                                    .navigationBarTitleDisplayMode(.large)
                            ) {
                                Text(.localized("Version History"))
                            }
                        }
					}
					
					Divider()
				}
				
				if let appDesc = app.localizedDescription {
					NBSection(.localized("Description")) {
						VStack(alignment: .leading, spacing: 2) {
							ExpandableText(text: appDesc, lineLimit: 3)
						}
						.frame(maxWidth: .infinity, alignment: .leading)
					}
					
					Divider()
				}
                
                NBSection(.localized("Information")) {
                    VStack(spacing: 12) {
                        if let sourceName = source.name {
                            _infoRow(title: .localized("Source"), value: sourceName)
                        }
                        
						if let developer = app.developer {
							_infoRow(title: .localized("Developer"), value: developer)
						}
						
						if let size = app.size {
							_infoRow(title: .localized("Size"), value: size.formattedByteCount)
						}
						
						if let category = app.category {
                            _infoRow(title: .localized("Category"), value: category.capitalized)
						}
						
						if let version = app.currentVersion {
							_infoRow(title: .localized("Version"), value: version)
						}
						
						if let date = app.currentDate?.date {
							_infoRow(title: .localized("Updated"), value: DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none))
						}
						
						if let bundleId = app.id {
							_infoRow(title: .localized("Identifier"), value: bundleId)
						}
					}
                }
				
				if let appPermissions = app.appPermissions {
					NBSection(.localized("Permissions")) {
						Group {
							if let entitlements = appPermissions.entitlements {
								NBTitleWithSubtitleView(
									title: .localized("Entitlements"),
									subtitle: entitlements.map(\.name).joined(separator: "\n")
								)
							} else {
								Text(.localized("No Entitlements listed."))
									.font(.subheadline)
									.foregroundStyle(.secondary)
							}
							if let privacyItems = appPermissions.privacy {
								ForEach(privacyItems, id: \.self) { item in
									NBTitleWithSubtitleView(
										title: item.name,
										subtitle: item.usageDescription
									)
								}
							} else {
								Text(.localized("No Privacy Permissions listed."))
									.font(.subheadline)
									.foregroundStyle(.secondary)
							}
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 18, style: .continuous)
								.fill(Color(.quaternarySystemFill))
						)
					}
				}
			}
			.padding([.horizontal, .bottom])
			.padding(.top, {
				if #available(iOS 18, *) {
					8
				} else {
					0
				}
			}())
		}
		.flexibleHeaderScrollView()
		.shouldSetInset()
		.toolbar {
			NBToolbarButton(
				systemImage: "square.and.arrow.up",
				placement: .topBarTrailing
			) {
				let sharedString = """
				\(app.currentName) - \(app.currentVersion ?? "0")
				\(app.currentDescription ?? .localized("An awesome application"))
				---
				\(source.website?.absoluteString ?? source.name ?? "")
				"""
				UIActivityViewController.show(activityItems: [sharedString])
			}
		}
		.fullScreenCover(isPresented: $_isScreenshotPreviewPresented) {
			if let screenshotURLs = app.screenshotURLs {
				ScreenshotPreviewView(
					screenshotURLs: screenshotURLs,
					initialIndex: _selectedScreenshotIndex
				)
			}
		}
    }
	
	var standardIcon: some View {
		Image("App_Unknown").appIconStyle(size: 111, isCircle: false)
	}
	
	var standardHeader: some View {
		Image("App_Unknown")
			.resizable()
			.aspectRatio(contentMode: .fill)
			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
			.clipped()
	}
}

// MARK: - SourceAppsDetailView (Extension): Builders
extension SourceAppsDetailView {
	@available(iOS 18.0, *)
	@ViewBuilder
	private func _header() -> some View {
		ZStack {
			if let iconURL = source.currentIconURL {
				LazyImage(url: iconURL) { state in
					if let image = state.image {
						image.resizable()
							.aspectRatio(contentMode: .fill)
							.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
							.clipped()
					} else {
						standardHeader
					}
				}
			} else {
				standardHeader
			}
			
			NBVariableBlurView()
				.rotationEffect(.degrees(-180))
				.overlay(
					LinearGradient(
						gradient: Gradient(colors: [
							Color.black.opacity(0.8),
							Color.black.opacity(0)
						]),
						startPoint: .top,
						endPoint: .bottom
					)
				)
		}
	}
	
	@ViewBuilder
	private func _infoPills(app: ASRepository.App) -> some View {
		let pillItems = _buildPills(from: app)
		HStack(spacing: 6) {
			ForEach(pillItems.indices, id: \.hashValue) { index in
				let pill = pillItems[index]
				NBPillView(
					title: pill.title,
					icon: pill.icon,
					color: pill.color,
					index: index,
					count: pillItems.count
				)
			}
		}
	}
	
	private func _buildPills(from app: ASRepository.App) -> [NBPillItem] {
		var pills: [NBPillItem] = []
		
		if let version = app.currentVersion {
			pills.append(NBPillItem(title: version, icon: "tag", color: Color.accentColor))
		}
		
		if let size = app.size {
			pills.append(NBPillItem(title: size.formattedByteCount, icon: "archivebox", color: .secondary))
		}
		
		return pills
	}
	
	@ViewBuilder
	private func _infoRow(title: String, value: String) -> some View {
		LabeledContent(title, value: value)
		Divider()
	}
	
	@ViewBuilder
	private func _screenshots(screenshotURLs: [URL]) -> some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 12) {
				ForEach(screenshotURLs.indices, id: \.self) { index in
					let url = screenshotURLs[index]
					LazyImage(url: url) { state in
						if let image = state.image {
							image
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(
									maxWidth: UIScreen.main.bounds.width - 32,
									maxHeight: 400
								)
								.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
								.overlay {
									RoundedRectangle(cornerRadius: 16, style: .continuous)
										.strokeBorder(.gray.opacity(0.3), lineWidth: 1)
								}
								.onTapGesture {
									_selectedScreenshotIndex = index
									_isScreenshotPreviewPresented = true
								}
						}
					}
				}
			}
			.padding(.horizontal)
			.compatScrollTargetLayout()
		}
		.compatScrollTargetBehavior()
		.padding(.horizontal, -16)
	}
}
