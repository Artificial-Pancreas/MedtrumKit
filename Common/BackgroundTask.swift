import AVFoundation

/// A trick used to keep the app alive
class BackgroundTask {
    // MARK: - Vars

    var player = AVAudioPlayer()
    var timer = Timer()
    private let queue = DispatchQueue(label: "com.iaps.backgroundtask.medtrumkit", qos: .userInitiated)

    // MARK: - Methods

    func startBackgroundTask() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(interruptedAudio),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
        playAudio()
    }

    func stopBackgroundTask() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        queue.async { [weak self] in
            self?.player.stop()
        }
    }

    @objc private func interruptedAudio(_ notification: Notification) {
        if notification.name == AVAudioSession.interruptionNotification, notification.userInfo != nil {
            let info = notification.userInfo!
            var intValue = 0
            (info[AVAudioSessionInterruptionTypeKey]! as AnyObject).getValue(&intValue)
            if intValue == 1 { playAudio() }
        }
    }

    private func playAudio() {
        queue.async { [weak self] in
            guard let self = self else { return }
            do {
                guard let bundlePath = Bundle(for: MedtrumKitHUDProvider.self).path(forResource: "blank", ofType: "wav") else { return }
                let alertSound = URL(fileURLWithPath: bundlePath)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)
                let newPlayer = try AVAudioPlayer(contentsOf: alertSound)
                newPlayer.numberOfLoops = -1
                newPlayer.volume = 0.01
                newPlayer.prepareToPlay()
                newPlayer.play()
                self.player = newPlayer
            } catch {
                print(error)
            }
        }
    }
}
