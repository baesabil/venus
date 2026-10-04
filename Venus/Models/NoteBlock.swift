import Foundation

/// Potongan teks + style-nya. Dipakai supaya bold/italic bisa disimpan ke database.
struct StyledRun: Codable, Equatable {
    var text: String
    var bold: Bool
    var italic: Bool
}

/// Isi note dibuat dari urutan "blok" (seperti app Notes / referensi UI-mu).
/// Tiap blok bisa: teks, checklist, bullet, atau foto.
struct NoteBlock: Codable, Identifiable, Equatable {
    enum Kind: String, Codable { case text, checklist, bullet, photo }

    var id = UUID()
    var kind: Kind
    var runs: [StyledRun] = []     // dipakai kind .text
    var plain: String = ""         // dipakai .checklist / .bullet
    var isChecked = false          // dipakai .checklist
    var imageFile: String?         // nama file foto (.photo)

    static func emptyText() -> NoteBlock { NoteBlock(kind: .text) }

    var isEmpty: Bool {
        switch kind {
        case .text: return runs.allSatisfy { $0.text.isEmpty }
        case .checklist, .bullet: return plain.isEmpty
        case .photo: return false
        }
    }
}
