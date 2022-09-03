//
//  PlayerModel.swift
//  TESTMediaPlayer
//
//  Created by Kseniya Smirnova on 2.09.22.
//

import UIKit
import AVFoundation

class PlayerModel {
    
    //MARK: - Variables
    
    var tracks = [
        Song(image: "Cozy Fireplace", name: "Cozy Fireplace", album: "Relaxing Sounds"),
        Song(image: "Heavy Rain", name: "Heavy Rain", album: "Sounds Of Nature"),
        Song(image: "Melodious Forest", name: "Sounds of the Morning Spring Forest", album: "Sounds For Meditation")
    ]
    
    enum PlaybackData {
        case currentTime, duration, leftTime
    }
    
    var player: AVAudioPlayer?
    var timerLabel: Timer?
    var timerSlider: Timer?
    var currentSelected = 0 {
        didSet {
            currentSong = tracks[currentSelected]
        }
    }
    var currentSong: Song
    var playerProgressSliderValue: Float = 0
    
    var isPlaying: Bool = false
    
    //MARK: - Init
    
    init() {
        currentSong = tracks[currentSelected]
        playback()
        preparePlayer()
    }
    
    //MARK: - Functions

    func preparePlayer() {
        player = try? AVAudioPlayer(contentsOf: currentSong.path)
        player?.numberOfLoops = -1
        player?.prepareToPlay()
    }
    
    func playPause() {
        guard isPlaying else {
            player?.pause()
            return
        }
        player?.play()
    }
    
    func getPlaybackData(_ forData: PlaybackData) -> TimeInterval {
        switch forData {
        case .currentTime:
            return player?.currentTime ?? 0
        case .duration:
            return player?.duration ?? 0
        case .leftTime:
            return (player?.duration ?? 0) - (player?.currentTime ?? 0)
        }
    }
   
    private func playback() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)))
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
            print("error")
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    func playNext() {
        currentSelected = (currentSelected != tracks.count - 1) ? (currentSelected + 1) : 0
    }
    
    func playPrevious() {
        currentSelected = (currentSelected != 0) ? (currentSelected - 1) : tracks.count - 1
    }
    
    private func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
        return input.rawValue
    }
}

extension TimeInterval {
    func formattedTime() -> String {
        let seconds: Int32 = Int32(self)%60
        let minutes: Int32 = Int32((self)/60)%60
        return String(format: "%02d:%02d", minutes,seconds)
    }
}
