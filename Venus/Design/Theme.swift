import SwiftUI

/// "Design tokens": semua warna & ukuran dasar ada di satu tempat.
/// Mau ganti nuansa app? Cukup ubah file ini.
enum Theme {
    static let background   = Color(red: 0.953, green: 0.953, blue: 0.945) // abu hangat (Home, Archive)
    static let paper        = Color(red: 0.965, green: 0.922, blue: 0.784) // krem (halaman note)
    static let paperSurface = Color(red: 0.875, green: 0.835, blue: 0.690) // tombol di atas krem
    static let surface      = Color(red: 0.910, green: 0.910, blue: 0.900) // kartu/chip abu
    static let ink          = Color(red: 0.070, green: 0.070, blue: 0.070) // hitam utama

    enum Radius {
        static let card: CGFloat = 28
        static let small: CGFloat = 16
    }
}
