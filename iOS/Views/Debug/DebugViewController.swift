//
//  DebugViewController.swift
//  feather
//
//  Created by samara on 20.09.2024.
//

import Foundation
import SwiftUI
import UIKit

class DebugHostingController: UIHostingController<DebugViewController> {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder, rootView: DebugViewController())
	}
	
	override init(rootView: DebugViewController) {
		super.init(rootView: rootView)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.largeTitleDisplayMode = .always
	}
}
#warning 
("""
This view should never be translated, its there for debug purposes and not for the average user to see.
""")
struct DebugViewController: View {
	@State private var isOnboardingActive: Bool = Preferences.isOnboardingActive
	
	@State private var successCount = 0
	@State private var infoCount = 0
	@State private var debugCount = 0
	@State private var traceCount = 0
	@State private var warningCount = 0
	@State private var criticalCount = 0
	@State private var errorCount = 0
	@State private var basicCount = 0
	
	@State private var logContents: String = ""
	private let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
	
	@State private var showShareSheet = false

	
	var body: some View {
		List {
			Section(footer: Text("You will need to restart the app after toggling.")) {
				Toggle(isOn: $isOnboardingActive) { Text("Show Onboarding") }
				.onChange(of: isOnboardingActive) { newValue in
					Preferences.isOnboardingActive = newValue
				}
			}
			
			Section {
				Button(action: { openDirectory(named: "Signed") }) {
					Text("Open Signed Folder")
				}
				
				Button(action: { openDirectory(named: "Unsigned") }) {
					Text("Open Unsigned Folder")
				}
			}
			
			Section {
				Text("\(countToEmoji(count: successCount)) Success message(s)")
					.foregroundColor(.white)
					.listRowBackground(Color.green.opacity(0.2))
				
				Text("\(countToEmoji(count: infoCount)) Info message(s)")
					.foregroundColor(.white)
					.listRowBackground(Color.accentColor.opacity(0.2))
				
				Text("\(countToEmoji(count: debugCount)) Debug message(s)")
					.foregroundColor(.white)
					.listRowBackground(Color.blue.opacity(0.2))
				
				Text("\(countToEmoji(count: traceCount)) Trace(s)")
					.foregroundColor(.white)
					.listRowBackground(Color.indigo.opacity(0.2))
				
				Text("\(countToEmoji(count: warningCount)) Warning(s)")
					.foregroundColor(.white)
					.listRowBackground(Color.yellow.opacity(0.2))
				
				Text("\(countToEmoji(count: criticalCount)) Critical error(s)")
					.foregroundColor(.white)
					.listRowBackground(Color.red.opacity(0.2))
				
				Text("\(countToEmoji(count: errorCount)) Error(s)")
					.foregroundColor(.white)
					.listRowBackground(Color.orange.opacity(0.2))
				
				Text("\(countToEmoji(count: basicCount)) Messages(s)")
					.foregroundColor(.white)
			}
			
			Section {
				ScrollView {
					Text(logContents)
						.font(.system(.footnote, design: .monospaced))
				}
				.frame(height: 400)
				.onAppear(perform: loadLogContents)
				.onReceive(timer) { _ in
					loadLogContents()
					parseLogFile()
				}
				
				Button(action: { showShareSheet = true }) {
					HStack(spacing: .maximum(18, 18)) {
						sfGradient(systemName: "square.and.arrow.up", gradientColors: [.teal, .blue])
						CellText(text: "Share Log File")
					}
				}
			}
			
		}
		.sheet(isPresented: $showShareSheet) {
			let logFilePath = getDocumentsDirectory().appendingPathComponent("logs.txt")
			ActivityViewController(activityItems: [logFilePath])
		}
		.onAppear {
			isOnboardingActive = Preferences.isOnboardingActive
		}
	}
	
	
	private func openDirectory(named directoryName: String) {
		let directoryURL = getDocumentsDirectory().appendingPathComponent("Apps").appendingPathComponent(directoryName)
		let path = directoryURL.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
		
		UIApplication.shared.open(URL(string: path)!, options: [:]) { success in
			if success {
				Debug.shared.log(message: "File opened successfully.")
			} else {
				Debug.shared.log(message: "Failed to open file.")
			}
		}
	}
	
	private func loadLogContents() {
		let logFilePath = getDocumentsDirectory().appendingPathComponent("logs.txt")
		
		do {
			logContents = try String(contentsOf: logFilePath, encoding: .utf8)
		} catch {
			logContents = "Failed to load logs"
		}
	}
	
	func parseLogFile() {
		let logFilePath = getDocumentsDirectory().appendingPathComponent("logs.txt")
		do {
			let logContents = try String(contentsOf: logFilePath)


			successCount = 0
			infoCount = 0
			debugCount = 0
			traceCount = 0
			warningCount = 0
			criticalCount = 0
			errorCount = 0
			basicCount = 0

			let logEntries = logContents.components(separatedBy: .newlines)

			for entry in logEntries {
				if entry.contains("✅") {
					successCount += 1
				} else if entry.contains("ℹ️") {
					infoCount += 1
				} else if entry.contains("🐛") {
					debugCount += 1
				} else if entry.contains("🔍") {
					traceCount += 1
				} else if entry.contains("⚠️") {
					warningCount += 1
				} else if entry.contains("❌") {
					errorCount += 1
				} else if entry.contains("🔥") {
					criticalCount += 1
				} else if entry.contains("📝") {
					basicCount += 1
				}
			}

		} catch {
			print("Error reading log file: \(error)")
		}
	}

	
	func countToEmoji(count: Int) -> String {
		return "\(count)"
	}
	
}

extension View {
	@ViewBuilder
	func ifAvailable<T: View>(iOS17Modifier: (Self) -> T) -> some View {
		if #available(iOS 17, *) {
			iOS17Modifier(self)
		} else {
			self
		}
	}
}

func sfGradient(systemName: String, gradientColors: [Color]) -> some View {
	Image(systemName: systemName)
		.resizable()
		.aspectRatio(contentMode: .fit)
		.frame(width: 24, height: 24)
		.overlay(
			LinearGradient(
				gradient: Gradient(colors: gradientColors),
				startPoint: .trailing,
				endPoint: .leading
			)
		)
		.mask(
			Image(systemName: systemName)
				.resizable()
				.aspectRatio(contentMode: .fit)
		)
}

func CellText(text: String) -> some View {
	Text(text)
		.foregroundColor(Color(UIColor.label))
}
