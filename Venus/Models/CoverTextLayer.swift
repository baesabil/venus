import SwiftUI

/// Satu teks di atas cover. Posisi & ukuran disimpan sebagai PECAHAN dari
/// lebar cover, jadi hasilnya sama di ukuran layar berapa pun.
struct CoverTextLayer: Codable, Identifiable, Equatable {
    var id = UUID()
    var text: String = "Hello"
    var fontIndex: Int = 0          // index ke CoverFont
    var colorIndex: Int = 0         // index ke CoverPalette
    var size: CGFloat = 0.14        // tinggi font = size x lebar cover
    var offsetX: CGFloat = 0        // geser dari tengah (pecahan lebar cover)
    var offsetY: CGFloat = 0
    var rotation: Double = 0        // derajat
}
