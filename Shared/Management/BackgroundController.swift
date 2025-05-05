//
//  BackgroundController.swift
//  feather
//
//  Created by @brynts on 22/04/25.
//

import UIKit
import AVFoundation

final class BackgroundController {
    static let shared = BackgroundController()

    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var engine: AVAudioEngine?
    private var idleTimer: Timer?
    private var hardTimeoutTimer: Timer?
    private var activeCount = 0

    private init() {}

    // MARK: - Start Background Task + Silent Audio + Idle Timeout
    func begin() {
        if activeCount == 0 {
            backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "FeatherTask") {
                self.end()
            }

            startSilentAudioEngine()
            startHardTimeout()
        }
        activeCount += 1
        resetIdleTimer()
    }

    // MARK: - End Background Task
    func end(force: Bool = false) {
        if force {
            cleanup()
        } else {
            activeCount -= 1
            if activeCount == 0 {
                cleanup()
            }
        }
    }

    private func cleanup() {
        stopSilentAudioEngine()
        idleTimer?.invalidate()
        idleTimer = nil
        hardTimeoutTimer?.invalidate()
        hardTimeoutTimer = nil

        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }

        print("Background task ended")
    }

    // MARK: - Start Silent Audio Engine
    private func startSilentAudioEngine() {
        guard engine == nil else { return }

        let engine = AVAudioEngine()
        let output = engine.outputNode
        let format = output.inputFormat(forBus: 0)

        let silentNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for buffer in ablPointer {
                memset(buffer.mData, 0, Int(buffer.mDataByteSize))
            }
            return noErr
        }

        engine.attach(silentNode)
        engine.connect(silentNode, to: output, format: format)

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            try engine.start()
            self.engine = engine

            print("Silent audio engine started")
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    // MARK: - Stop Silent Audio
    private func stopSilentAudioEngine() {
        engine?.stop()
        engine = nil
        print("Silent audio engine stopped")
    }

    // MARK: - Idle Timeout
    private func resetIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { [weak self] _ in
            print("Idle timeout reached. Ending background task.")
            self?.end()
        }
    }
    
    // MARK: - Engine Hard Stop
    private func startHardTimeout() {
    hardTimeoutTimer?.invalidate()
    hardTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: false) { [weak self] _ in
        print("Hard timeout reached. Ending background task.")
        self?.end(force: true)
        }
    }
    
    // MARK: - Ping to Reset Idle Timer
    /// Call this to reset the idle timer, e.g. when there is activity to prevent idle timeout.
    func ping() {
        guard activeCount > 0 else {
            print("Ignored ping: no active task")
            return
        }
        resetIdleTimer()
    }
}
