import Foundation
import SwiftData

/// Satu catatan. Ini yang disimpan SwiftData di HP.
///
/// Data besar (gambar) diberi `.externalStorage` supaya disimpan sebagai file
/// terpisah, bukan di dalam database -> database tetap ringan & cepat.
@Model
final class Note {
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    var title: String

    // --- Cover ---
    /// Cover yang SUDAH digabung (foto + gambar + teks) jadi 1 gambar persegi.
    /// Ini yang ditampilkan di tumpukan kartu & grid (cepat, tanpa render ulang).
    @Attribute(.externalStorage) var coverImageData: Data?
    /// Foto asli cover (untuk diedit lagi nanti).
    @Attribute(.externalStorage) var coverBaseData: Data?
    /// Coretan tangan (PKDrawing) di cover.
    @Attribute(.externalStorage) var coverDrawingData: Data?
    var coverPhotoScale: Double
    var coverPhotoOffsetX: Double
    var coverPhotoOffsetY: Double
    /// Daftar teks di cover, disimpan sebagai JSON.
    var coverTextLayersData: Data?

    // --- Isi note ---
    /// Daftar blok (teks, checklist, foto) disimpan sebagai JSON.
    var blocksData: Data?

    // --- Lagu Spotify ---
    var songURL: String?
    var songTitle: String?
    var songThumbnailURL: String?

    init(title: String = "") {
        self.id = UUID()
        self.createdAt = .now
        self.updatedAt = .now
        self.title = title
        self.coverPhotoScale = 1
        self.coverPhotoOffsetX = 0
        self.coverPhotoOffsetY = 0
    }

    // MARK: - Helper encode/decode JSON

    var blocks: [NoteBlock] {
        get { (try? JSONDecoder().decode([NoteBlock].self, from: blocksData ?? Data())) ?? [] }
        set { blocksData = try? JSONEncoder().encode(newValue) }
    }

    var coverTextLayers: [CoverTextLayer] {
        get { (try? JSONDecoder().decode([CoverTextLayer].self, from: coverTextLayersData ?? Data())) ?? [] }
        set { coverTextLayersData = try? JSONEncoder().encode(newValue) }
    }
}
