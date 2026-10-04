import SwiftUI

/// View paling atas: menampilkan Home, lalu splash screen di atasnya
/// yang hilang sendiri setelah ~1.4 detik.
struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            HomeView()
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            HapticsManager.shared.prepare()
            try? await Task.sleep(for: .seconds(1.4))
            withAnimation(.easeOut(duration: 0.4)) { showSplash = false }
        }
    }
}
