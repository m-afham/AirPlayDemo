//
//  ViewController.swift
//  AirplayNativeIOS
//
//  Created by Human on 5/30/23.
//

import AVKit
import AVFoundation
import AVKit
import CallKit
import MediaPlayer // MPRemoteCommandCenter.shared

// IMP: Capability is important to allow running in background along with code

class VideoPlayerViewController: AVPlayerViewController {
    
    // Add local video first in your project
    private var localVideoURL: URL {
        return Bundle.main.url(forResource: "video1", withExtension: "mp4")!
    }
    
    private var remoteVideoURL: URL {
        return URL.init(string: "https://media.w3.org/2010/05/sintel/trailer.mp4")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create an AVPlayer instance with the video URL
        let player = AVPlayer(url: remoteVideoURL)
        
        // Set the AVPlayer to the player property of AVPlayerViewController
        self.player = player
    
        // IMP: Configure the AVAudioSession to allow playback when the screen is locked
        self.allowPlaybackInScreenLockState()
        
        // IMP
        self.handleBackgroundModeInterruptions()
        
        // IMP
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil)

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Show the AirPlay route button
        if #available(iOS 11.0, *) {
            self.showsPlaybackControls = true
            self.entersFullScreenWhenPlaybackBegins = true
        }
    }
    
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeInt) else {
                return
        }

        switch type {
        case .began: break
            // Pause your player

        case .ended:
            if let optionInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionInt)
                if options.contains(.shouldResume) {
                    // Resume your player
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.player?.play()
                    } 
                }
            }
        default: break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension VideoPlayerViewController {
    func allowPlaybackInScreenLockState() {
        // Configure the AVAudioSession to allow playback when the screen is locked
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: .allowAirPlay)
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    func handleBackgroundModeInterruptions() {
        // Setup remote command center
        let remoteCommandCenter = MPRemoteCommandCenter.shared()
        
        // Play command
        remoteCommandCenter.playCommand.addTarget { [weak self] event in
            self?.player?.play()
            return .success
        }
        
        // Pause command
        remoteCommandCenter.pauseCommand.addTarget { [weak self] event in
            self?.player?.pause()
            return .success
        }
        
        // Next track command
        remoteCommandCenter.nextTrackCommand.addTarget { [weak self] event in
            // Handle next track action
            return .success
        }
        
        // Previous track command
        remoteCommandCenter.previousTrackCommand.addTarget { [weak self] event in
            // Handle previous track action
            return .success
        }
        
        // Skip forward command
        remoteCommandCenter.skipForwardCommand.preferredIntervals = [15]
        remoteCommandCenter.skipForwardCommand.addTarget { [weak self] event in
            // Handle skip forward action (e.g., skip 15 seconds forward)
            return .success
        }
        
        // Skip backward command
        remoteCommandCenter.skipBackwardCommand.preferredIntervals = [15]
        remoteCommandCenter.skipBackwardCommand.addTarget { [weak self] event in
            // Handle skip backward action (e.g., skip 15 seconds backward)
            return .success
        }
        
    }
}
