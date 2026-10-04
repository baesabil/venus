import SwiftUI

/// Splash screen. Gambar diambil dari Assets dengan nama "SplashImage".
/// Kalau gambarnya belum kamu tambahkan, otomatis tampil naga + tulisan "Venus"
/// (jadi tidak error).
struct SplashView: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 20) {
                if UIImage(named: "SplashImage") != nil {
                    Image("SplashImage")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 280, maxHeight: 280)
                } else {
                    // Belum ada SplashImage -> pakai naga.
                    MascotView(height: 220, restingAngle: 0)
                }
                Text("Venus")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Theme.ink)
            }
        }
    }
}
