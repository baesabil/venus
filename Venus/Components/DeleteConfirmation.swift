import SwiftUI

/// Dialog "Hapus note?" yang dipakai di Home DAN Archive.
/// Pakai: `.deleteConfirmation(note: $noteToDelete)`
struct DeleteConfirmation: ViewModifier {
    @Environment(\.modelContext) private var context
    @Binding var note: Note?

    func body(content: Content) -> some View {
        content.confirmationDialog(
            "Delete this note?",
            isPresented: Binding(get: { note != nil }, set: { if !$0 { note = nil } }),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let target = note {
                    NoteRepository.delete(target, from: context)
                }
                note = nil
            }
        } message: {
            Text("This can't be undone.")
        }
    }
}

extension View {
    func deleteConfirmation(note: Binding<Note?>) -> some View {
        modifier(DeleteConfirmation(note: note))
    }
}
