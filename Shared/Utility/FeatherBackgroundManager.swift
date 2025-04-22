//
//  FeatherBackgroundManager.swift
//  feather
//
//  Created by Bryan Saputra on 22/04/25.
//

import UIKit
import AVFoundation

final class FeatherBackgroundManager {
    static let shared = FeatherBackgroundManager()

    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var audioPlayer: AVAudioPlayer?

    private init() {}

    // MARK: - Start Background Task + Silent Audio
    func begin() {
        guard backgroundTaskID == .invalid else { return }

        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "FeatherTask") {
            // Expired
            self.end()
        }

        startSilentAudio()
    }

    // MARK: - End Task + Stop Audio
    func end() {
        stopSilentAudio()

        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }

    // MARK: - Silent Audio Setup
    private func startSilentAudio() {
        guard audioPlayer == nil else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)

            if let url = Bundle.main.url(forResource: "blank", withExtension: "mp3") {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.play()
            } else {
                print("blank.mp3 not found in bundle")
            }
        } catch {
            print("Failed to play silent audio: \(error)")
        }
    }

    private func stopSilentAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
