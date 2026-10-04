import SwiftUI
import SwiftData

/// Titik masuk aplikasi. Di sini kita menyiapkan database SwiftData
/// (`modelContainer`) supaya semua view bisa baca/tulis `Note`.
@main
struct VenusApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                // Desain Venus dibuat untuk tema terang (PencilKit & warna cover ikut stabil).
                .preferredColorScheme(.light)
        }
        .modelContainer(for: Note.self)
    }
}
