import SwiftUI

/// 6 pilihan font untuk teks di cover.
/// Semuanya font BAWAAN iOS, jadi tidak perlu install/bundle file font.
/// (Nanti kalau mau font lain: tambahkan file .ttf ke project, daftarkan di
/// Info "Fonts provided by application", lalu ganti `fontName` di sini.)
enum CoverFont: Int, CaseIterable, Identifiable {
    case script, serif, playful, condensed, mono, handwriting

    var id: Int { rawValue }

    /// Nama PostScript font yang dipakai `Font.custom`.
    var fontName: String {
        switch self {
        case .script:      return "SnellRoundhand-Black"
        case .serif:       return "Didot-Bold"
        case .playful:     return "MarkerFelt-Wide"
        case .condensed:   return "AvenirNextCondensed-Heavy"
        case .mono:        return "Menlo-Bold"
        case .handwriting: return "BradleyHandITCTT-Bold"
        }
    }
}

/// Beberapa warna dasar untuk teks & coretan di cover.
enum CoverPalette {
    static let colors: [Color] = [
        .white,
        Color(red: 0.07, green: 0.07, blue: 0.07),
        Color(red: 0.90, green: 0.28, blue: 0.30),
        Color(red: 0.96, green: 0.77, blue: 0.26),
        Color(red: 0.25, green: 0.65, blue: 0.42),
        Color(red: 0.23, green: 0.51, blue: 0.96),
        Color(red: 0.49, green: 0.23, blue: 0.93),
        Color(red: 0.96, green: 0.45, blue: 0.71)
    ]

    static func color(_ index: Int) -> Color {
        colors[((index % colors.count) + colors.count) % colors.count]
    }
}
