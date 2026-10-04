import SwiftUI

/// Karakter ilustrasi untuk menghias UI (gaya Woset: garis hitam di atas latar polos).
/// - `name` = nama gambar di Assets.xcassets. Default: "DragonMascot" (naga buatanmu).
/// - Mau karakter lain / pose lain? Tambah gambar baru di Assets (PNG transparan),
///   lalu pakai: MascotView(name: "NamaGambarBaru", height: 140)
/// - Ditekan -> naga goyang + haptic kecil. Kalau gambarnya tidak ada, view ini kosong (tidak error).
struct MascotView: View {
    var name = "DragonMascot"
    var height: CGFloat = 110
    /// Kemiringan awal (derajat). Sedikit miring terasa lebih hidup.
    var restingAngle: Double = -4

    @State private var angle: Double?

    var body: some View {
        if UIImage(named: name) != nil {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(height: height)
                .rotationEffect(.degrees(angle ?? restingAngle), anchor: .bottom)
                .onTapGesture(perform: wiggle)
                .accessibilityHidden(true)
        }
    }

    private func wiggle() {
        HapticsManager.shared.tick()
        withAnimation(.spring(response: 0.22, dampingFraction: 0.28)) { angle = restingAngle + 14 }
        Task {
            try? await Task.sleep(for: .milliseconds(160))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.35)) { angle = restingAngle }
        }
    }
}
