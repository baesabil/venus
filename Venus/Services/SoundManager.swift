import AVFoundation
import AudioToolbox

/// Suara swipe kartu.
/// Mau suara sendiri? Masukkan file bernama "swipe" (wav / caf / mp3 / m4a)
/// ke project. Kalau tidak ada, dipakai suara klik bawaan iOS.
final class SoundManager {
    static let shared = SoundManager()

    private var player: AVAudioPlayer?

    private init() {
        // .ambient = ikut tombol silent & tidak mematikan musik yang sedang jalan.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        for ext in ["wav", "caf", "mp3", "m4a"] {
            if let url = Bundle.main.url(forResource: "swipe", withExtension: ext) {
                player = try? AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay()   // preload sekali -> tanpa delay saat dimainkan
                break
            }
        }
    }

    func playSwipe() {
        if let player {
            player.currentTime = 0
            player.play()
        } else {
            AudioServicesPlaySystemSound(1104)
        }
    }
}
