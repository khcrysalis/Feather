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
                    Divider()
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
}

