//
//  SettingsDonationCellView.swift
//  Feather
//
//  Created by samara on 30.04.2025.
//

#if !NIGHTLY && !DEBUG
import SwiftUI
import NimbleViews

struct SettingsDonationCellView: View {
	var site: String
	
	var body: some View {
		Section {
			VStack(spacing: 14) {
				_title()
				_benefit(
					.localized("Remove this Alert"),
					.localized("Remove annoying alerts like these after getting beta access!"),
					systemName: "heart.text.square.fill"
				)
				_benefit(
					.localized("Show Your Support"),
					.localized("Show your support by donating! If you're unable to donate, spreading the word works too!"),
					systemName: "heart.fill"
				)
				
				Button() {
					UIApplication.open(site)
				} label: {
					_sheetButton(.localized("Donate"))
				}
				.frame(height: 45)
			}
			.padding(.vertical, 12)
			.buttonStyle(.plain)
		}
	}
	
	@ViewBuilder
	private func _title() -> some View {
		VStack(alignment: .center, spacing: 12) {
			Image(systemName: "heart")
				.font(.system(size: 38, weight: .bold))
				.foregroundStyle(.pink)
			
			Text(.localized("Donations"))
				.font(.title)
				.bold()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
	}
	
	@ViewBuilder
	private func _benefit(
		_ title: String,
		_ desc: String,
		systemName: String
	) -> some View {
		HStack(alignment: .center, spacing: 14) {
			Image(systemName: systemName)
				.font(.system(size: 32))
				.foregroundStyle(.tint)
				.frame(width: 39, alignment: .center)
			
			NBTitleWithSubtitleView(
				title: title,
				subtitle: desc
			).fixedSize(horizontal: false, vertical: true)
		}
	}
	
	@ViewBuilder
	private func _sheetButton(_ title: String) -> some View {
		Text(title)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(Color.accentColor)
			.foregroundColor(.white)
			.clipShape(
				RoundedRectangle(cornerRadius: 12, style: .continuous)
			)
			.bold()
	}
}

#endif
