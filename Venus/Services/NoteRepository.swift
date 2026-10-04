import SwiftData

/// Operasi data yang bukan urusan tampilan (saat ini: hapus note).
enum NoteRepository {
    /// Hapus note beserta file-file foto di dalamnya.
    @MainActor
    static func delete(_ note: Note, from context: ModelContext) {
        for block in note.blocks {
            if let file = block.imageFile { ImageStore.delete(file) }
        }
        context.delete(note)
        try? context.save()
    }
}
