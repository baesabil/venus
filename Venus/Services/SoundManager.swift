import AVFoundation
import AudioToolbox

/// Suara swipe kartu: desir angin (whoosh) dari file `swipe.wav`.
/// - Mau suara sendiri? Ganti file `swipe.wav` (atau .caf / .mp3 / .m4a) di project, namanya tetap "swipe".
/// - Setiap swipe kecepatannya sedikit diacak (0.92x - 1.08x) supaya tidak terdengar monoton.
final class SoundManager {
    static let shared = SoundManager()

    private var player: AVAudioPlayer?

    private init() {
        // .ambient = ikut tombol silent & tidak mematikan musik yang sedang jalan.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        for ext in ["wav", "caf", "mp3", "m4a"] {
            if let url = Bundle.main.url(forResource: "swipe", withExtension: ext) {
                player = try? AVAudioPlayer(contentsOf: url)
                player?.enableRate = true     // supaya kecepatan bisa diubah
                player?.volume = 0.1
                player?.prepareToPlay()       // preload sekali -> tanpa delay saat dimainkan
                break
            }
        }
    }

    func playSwipe() {
        if let player {
            player.currentTime = 0
            player.rate = Float.random(in: 0.80...1.08)
            player.play()
        } else {
            AudioServicesPlaySystemSound(1104)   // cadangan kalau file suara tidak ditemukan
        }
    }
}
