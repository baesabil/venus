import Foundation

/// SEMUA tulisan (copywriting) yang tampil di app ada di sini.
/// Mau ganti kalimat sapaan? Ubah teks di file ini saja, tidak perlu cari ke view lain.
enum AppCopy {
    /// Nama bawaan. Nama bisa diganti dari app: tap tulisan sapaan di Home.
    static let defaultName = "Sabila"

    /// Sapaan di Home. `name` otomatis diisi nama yang kamu simpan.
    static func greeting(name: String) -> String { "Welcome back, \(name)" }
    static let greetingSubtitle = "What's on your mind today?"

    static let emptyHome = "Tap + to write your first note"
    static let searchPrompt = "Search by title"
    static let nameAlertTitle = "What should I call you?"
}
