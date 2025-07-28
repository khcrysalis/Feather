//
//  VersionHistoryView.swift
//  Feather
//
//  Created by Nagata Asami on 27/7/25.
//

import SwiftUI
import AltSourceKit

// MARK: - VersionHistoryView
struct VersionHistoryView: View {
    let app: ASRepository.App
    let versions: [ASRepository.App.Version]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(versions) { version in
                    AppVersionInfo(
                        version: version.version,
                        date: version.date?.date,
                        description: version.localizedDescription ?? .localized("No release notes available")
                    )
                    .padding(.horizontal)
                    .background(Color(.systemBackground))
                    .contextMenu {
                        if let downloadURL = version.downloadURL {
                            Button {
                                _ = DownloadManager.shared.startDownload(
                                    from: downloadURL,
                                    id: app.currentUniqueId
                                )
                            } label: {
                                Label(.localized("Download Version \(version.version)" ), systemImage: "arrow.down.circle")
                            }
                            
                            Button {
                                UIPasteboard.general.string = downloadURL.absoluteString
                            } label: {
                                Label(.localized("Copy Download URL"), systemImage: "doc.on.clipboard")
                            }
                        }
                    }
                    
                    Divider().padding(.horizontal)
                }
            }
//            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
}

